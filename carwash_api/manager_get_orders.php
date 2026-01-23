<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
include "config.php";

try {
    $stmt = $conn->prepare("
        SELECT b.id, b.customer_email, b.service_name, b.location, b.booking_date, b.booking_time, b.status,
               t.team_name, t.car_number_plate,
               c.car_model, c.car_plate
        FROM bookings b
        LEFT JOIN teams t ON t.team_id = b.team_id
        LEFT JOIN cars c ON c.car_id = b.car_id
        ORDER BY b.id DESC
    ");
    $stmt->execute();
    $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(["status" => true, "orders" => $orders]);
} catch (Exception $e) {
    echo json_encode(["status" => false, "message" => $e->getMessage()]);
}
