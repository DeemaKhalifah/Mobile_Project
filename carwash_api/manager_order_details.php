<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
include "config.php";

$data = json_decode(file_get_contents("php://input"));
if (empty($data->booking_id)) {
    echo json_encode(["status" => false, "message" => "booking_id required"]);
    exit;
}

try {
    $stmt = $conn->prepare("
        SELECT b.*,
               t.team_name, t.car_number_plate,
               c.car_model, c.car_plate
        FROM bookings b
        LEFT JOIN teams t ON t.team_id = b.team_id
        LEFT JOIN cars c ON c.car_id = b.car_id
        WHERE b.id = :id
        LIMIT 1
    ");
    $stmt->bindParam(":id", $data->booking_id);
    $stmt->execute();
    $order = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$order) {
        echo json_encode(["status" => false, "message" => "Order not found"]);
        exit;
    }

    echo json_encode(["status" => true, "order" => $order]);
} catch (Exception $e) {
    echo json_encode(["status" => false, "message" => $e->getMessage()]);
}
