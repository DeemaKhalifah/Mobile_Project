<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type");

// Turn off PHP errors in output
error_reporting(0);
ini_set('display_errors', 0);

include 'config.php';

// Helper function for JSON response
function sendResponse($status, $message, $extra = []) {
    echo json_encode(array_merge([
        "status" => $status,
        "message" => $message
    ], $extra));
    exit;
}

// Car plate validation
function isValidCarPlate($plate) {
    return preg_match('/^[A-Z0-9]{6,8}$/i', $plate);
}

// Read JSON input
$input = file_get_contents("php://input");
$data = json_decode($input);

if (!$data) {
    sendResponse(false, "Invalid JSON input");
}

// Required fields check
$required = ["customer_email", "service_name", "location", "booking_date", "booking_time", "car_model", "car_plate"];
foreach ($required as $field) {
    if (empty($data->$field)) {
        sendResponse(false, "Field '$field' is required");
    }
}

// Car plate validation
if (!isValidCarPlate($data->car_plate)) {
    sendResponse(false, "Invalid car plate number. Must be 6-8 letters/numbers.");
}

try {
    $conn->beginTransaction();

    // 1️⃣ Get user ID
    $stmt = $conn->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$data->customer_email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        $conn->rollBack();
        sendResponse(false, "User not found");
    }

    $userId = $user['id'];

    // 2️⃣ Insert car
    $stmt = $conn->prepare("INSERT INTO cars (user_id, car_model, car_plate) VALUES (?, ?, ?)");
    $stmt->execute([$userId, $data->car_model, $data->car_plate]);
    $carId = $conn->lastInsertId();

    // 3️⃣ Find available team (round-robin)
    $teamStmt = $conn->prepare("
        SELECT t.team_id
        FROM teams t
        WHERE t.team_id NOT IN (
            SELECT team_id FROM team_bookings
            WHERE booking_date = ? AND booking_time = ?
        )
        ORDER BY t.team_id ASC
        LIMIT 1
    ");
    $teamStmt->execute([$data->booking_date, $data->booking_time]);
    $team = $teamStmt->fetch(PDO::FETCH_ASSOC);

    if (!$team) {
        $conn->rollBack();
        sendResponse(false, "No available teams at this time");
    }

    $teamId = $team['team_id'];

    // 4️⃣ Insert booking
    $stmt = $conn->prepare("
        INSERT INTO bookings 
        (customer_email, service_name, location, notes, booking_date, booking_time, car_id, team_id)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ");
    $notes = !empty($data->notes) ? $data->notes : '';
    $stmt->execute([
        $data->customer_email,
        $data->service_name,
        $data->location,
        $notes,
        $data->booking_date,
        $data->booking_time,
        $carId,
        $teamId
    ]);
    $bookingId = $conn->lastInsertId();

    // 5️⃣ Lock team slot
    $stmt = $conn->prepare("
        INSERT INTO team_bookings (team_id, booking_date, booking_time, booking_id)
        VALUES (?, ?, ?, ?)
    ");
    $stmt->execute([$teamId, $data->booking_date, $data->booking_time, $bookingId]);

    $conn->commit();

    sendResponse(true, "Booking created & team assigned", ["team_id" => $teamId]);

} catch (Exception $e) {
    $conn->rollBack();
    sendResponse(false, "Server error: " . $e->getMessage());
}
?>
