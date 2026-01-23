<?php
header('Content-Type: application/json; charset=utf-8');
ini_set('display_errors', 0);
error_reporting(E_ALL);

try {
    require_once "config.php"; 

    $sql = "SELECT
              t.team_id,
              t.team_name,
              t.car_number_plate,
              t.employee_id,
              u.name AS leader_name,
              u.email AS leader_email
            FROM teams t
            LEFT JOIN users u ON u.id = t.employee_id
            ORDER BY t.team_id DESC";

    $stmt = $conn->prepare($sql);
    $stmt->execute();
    $teams = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(["status" => true, "teams" => $teams]);

} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode(["status" => false, "message" => $e->getMessage()]);
}
