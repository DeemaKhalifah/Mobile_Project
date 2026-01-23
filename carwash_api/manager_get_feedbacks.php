<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
include "config.php";

try {
    $stmt = $conn->prepare("
        SELECT f.id, f.rating, f.comment, f.created_at,
               u.name AS customer_name, u.email AS customer_email,
               s.name AS service_name
        FROM feedbacks f
        JOIN users u ON u.id = f.customer_id
        JOIN services s ON s.id = f.service_id
        ORDER BY f.id DESC
    ");
    $stmt->execute();
    $feedbacks = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(["status" => true, "feedbacks" => $feedbacks]);
} catch (Exception $e) {
    echo json_encode(["status" => false, "message" => $e->getMessage()]);
}
