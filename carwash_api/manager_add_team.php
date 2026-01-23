<?php
header('Content-Type: application/json; charset=utf-8');
header("Access-Control-Allow-Origin: *");
ini_set('display_errors', 0);
error_reporting(E_ALL);
ob_start();

try {
    require_once "config.php"; 
    ob_end_clean();

    $data = json_decode(file_get_contents("php://input"), true);
    $team_name = trim($data['team_name'] ?? '');
    $employee_id = intval($data['employee_id'] ?? 0);
    $car_plate = trim($data['car_number_plate'] ?? '');

    if ($team_name === '' || $employee_id <= 0 || $car_plate === '') {
        http_response_code(400);
        echo json_encode(["status" => false, "message" => "team_name, employee_id, car_number_plate required"]);
        exit;
    }

    $stmt = $conn->prepare("SELECT id FROM users WHERE id=? AND role='employee' LIMIT 1");
    $stmt->execute([$employee_id]);
    if (!$stmt->fetch()) {
        http_response_code(400);
        echo json_encode(["status" => false, "message" => "Employee not found"]);
        exit;
    }

    $stmt = $conn->prepare("SELECT id FROM team_members WHERE employee_id=? LIMIT 1");
    $stmt->execute([$employee_id]);
    if ($stmt->fetch()) {
        http_response_code(400);
        echo json_encode(["status" => false, "message" => "Employee already assigned to a team"]);
        exit;
    }

    $stmt = $conn->prepare("SELECT team_id FROM teams WHERE car_number_plate=? LIMIT 1");
    $stmt->execute([$car_plate]);
    if ($stmt->fetch()) {
        http_response_code(400);
        echo json_encode(["status" => false, "message" => "Car plate already used"]);
        exit;
    }

    $stmt = $conn->prepare("SELECT IFNULL(MAX(team_id),0)+1 AS next_id FROM teams");
    $stmt->execute();
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    $new_team_id = intval($row['next_id'] ?? 0);
    if ($new_team_id <= 0) $new_team_id = 1;

    $conn->beginTransaction();

    // Insert into teams
    $stmt = $conn->prepare("INSERT INTO teams (team_id, team_name, employee_id, car_number_plate) VALUES (?,?,?,?)");
    $stmt->execute([$new_team_id, $team_name, $employee_id, $car_plate]);

    $stmt = $conn->prepare("INSERT INTO team_members (team_id, employee_id) VALUES (?,?)");
    $stmt->execute([$new_team_id, $employee_id]);

    $conn->commit();

    echo json_encode([
        "status" => true,
        "message" => "Team added",
        "team_id" => $new_team_id
    ]);

} catch (Throwable $e) {
    if (isset($conn) && $conn->inTransaction()) $conn->rollBack();
    ob_end_clean();
    http_response_code(500);
    echo json_encode(["status" => false, "message" => $e->getMessage()]);
}
