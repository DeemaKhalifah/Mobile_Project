<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include "config.php";

$data = json_decode(file_get_contents("php://input"));

if (empty($data->customer_email)) {
    echo json_encode([
        "status" => false,
        "message" => "Customer email is required"
    ]);
    exit;
}

$email = trim($data->customer_email);

try {
    $stmt = $conn->prepare("
        SELECT 
            b.id,
            b.customer_email,
            b.service_name,
            b.location,
            b.notes,
            b.booking_date,
            b.booking_time,
            b.car_id,
            COALESCE(b.status, 'pending') AS status,
            c.car_model,
            c.car_plate
        FROM bookings b
        LEFT JOIN cars c ON b.car_id = c.car_id
        WHERE b.customer_email = :email
        ORDER BY b.id DESC
    ");

    $stmt->bindParam(":email", $email, PDO::PARAM_STR);
    $stmt->execute();

    $bookings = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "status" => true,
        "bookings" => $bookings
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => false,
        "message" => "Failed to fetch bookings",
        "error" => $e->getMessage()
    ]);
}