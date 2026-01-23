<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
include "config.php";

$data = json_decode(file_get_contents("php://input"));

if (empty($data->employee_email) || empty($data->booking_id)) {
    echo json_encode(["status" => false, "message" => "employee_email and booking_id required"]);
    exit;
}

try {
    // employee id
    $stmt = $conn->prepare("SELECT id, role FROM users WHERE email = :email LIMIT 1");
    $stmt->bindParam(":email", $data->employee_email);
    $stmt->execute();
    $emp = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$emp || $emp['role'] !== 'employee') {
        echo json_encode(["status" => false, "message" => "Invalid employee"]);
        exit;
    }

    // employee teams
    $stmt = $conn->prepare("SELECT team_id FROM teams WHERE employee_id = :eid");
    $stmt->bindParam(":eid", $emp['id']);
    $stmt->execute();
    $teams = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if (!$teams || count($teams) == 0) {
        echo json_encode(["status" => false, "message" => "No team assigned"]);
        exit;
    }

    $placeholders = implode(",", array_fill(0, count($teams), "?"));

    // booking must belong to one of employee teams
    $sql = "SELECT b.*, c.car_model, c.car_plate
            FROM bookings b
            LEFT JOIN cars c ON c.car_id = b.car_id
            WHERE b.id = ? AND b.team_id IN ($placeholders)
            LIMIT 1";

    $params = array_merge([$data->booking_id], $teams);

    $stmt = $conn->prepare($sql);
    $stmt->execute($params);

    $order = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$order) {
        echo json_encode(["status" => false, "message" => "Order not found or not allowed"]);
        exit;
    }

    echo json_encode(["status" => true, "order" => $order]);

} catch (Exception $e) {
    echo json_encode(["status" => false, "message" => "Error: " . $e->getMessage()]);
}
?>
