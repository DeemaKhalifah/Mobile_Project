<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include "config.php";

$data = json_decode(file_get_contents("php://input"));

if (empty($data->booking_id) || empty($data->customer_email)) {
    echo json_encode([
        "status" => false,
        "message" => "Booking ID and customer email are required"
    ]);
    exit;
}

$bookingId = (int)$data->booking_id;
$email = trim($data->customer_email);

try {
    // 1️⃣ Update booking status to canceled
    $stmt = $conn->prepare("
        UPDATE bookings
        SET status = 'canceled'
        WHERE id = :id AND customer_email = :email
    ");
    $stmt->bindParam(":id", $bookingId, PDO::PARAM_INT);
    $stmt->bindParam(":email", $email, PDO::PARAM_STR);
    $stmt->execute();

    if ($stmt->rowCount() === 0) {
        echo json_encode([
            "status" => false,
            "message" => "Booking not found or already canceled"
        ]);
        exit;
    }

    // 2️⃣ (Optional) refund logic here

    echo json_encode([
        "status" => true,
        "message" => "Booking canceled successfully"
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => false,
        "message" => "Failed to cancel booking",
        "error" => $e->getMessage()
    ]);
}
