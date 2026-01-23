<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
include "config.php";

$data = json_decode(file_get_contents("php://input"));

if (empty($data->id)) {
    echo json_encode(["status" => false, "message" => "Service ID required"]);
    exit;
}

try {
    $stmt = $conn->prepare("DELETE FROM services WHERE id = :id");
    $stmt->bindParam(":id", $data->id);
    $stmt->execute();

    echo json_encode(["status" => true, "message" => "Service deleted"]);
} catch (Exception $e) {
    echo json_encode(["status" => false, "message" => $e->getMessage()]);
}
