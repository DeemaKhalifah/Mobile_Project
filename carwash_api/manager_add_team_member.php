<?php
header('Content-Type: application/json; charset=utf-8');
ini_set('display_errors', 0);
error_reporting(E_ALL);

require_once 'config.php'; // provides $conn

$input = json_decode(file_get_contents("php://input"), true);
$team_id = intval($input['team_id'] ?? 0);
$employee_id = intval($input['employee_id'] ?? 0);

if ($team_id <= 0 || $employee_id <= 0) {
    http_response_code(400);
    echo json_encode(["status" => false, "message" => "team_id and employee_id are required"]);
    exit;
}

try {
    // Ensure team exists + get current leader
    $stmt = $conn->prepare("SELECT team_id, employee_id AS leader_id FROM teams WHERE team_id=?");
    $stmt->execute([$team_id]);
    $team = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$team) {
        http_response_code(400);
        echo json_encode(["status" => false, "message" => "Team not found"]);
        exit;
    }

    $leader_id = $team['leader_id']; // may be NULL

    // Ensure employee exists and is role employee
    $stmt = $conn->prepare("SELECT id FROM users WHERE id=? AND role='employee' LIMIT 1");
    $stmt->execute([$employee_id]);
    if (!$stmt->fetch()) {
        http_response_code(400);
        echo json_encode(["status" => false, "message" => "Employee not found"]);
        exit;
    }

    // Ensure employee not already assigned to any team
    $stmt = $conn->prepare("SELECT id FROM team_members WHERE employee_id=? LIMIT 1");
    $stmt->execute([$employee_id]);
    if ($stmt->fetch()) {
        http_response_code(400);
        echo json_encode(["status" => false, "message" => "Employee already assigned to a team"]);
        exit;
    }

    // Ensure team has less than 4 members
    $stmt = $conn->prepare("SELECT COUNT(*) AS cnt FROM team_members WHERE team_id=?");
    $stmt->execute([$team_id]);
    $cntRow = $stmt->fetch(PDO::FETCH_ASSOC);
    $cnt = intval($cntRow['cnt'] ?? 0);

    if ($cnt >= 4) {
        http_response_code(400);
        echo json_encode(["status" => false, "message" => "Team already has 4 employees"]);
        exit;
    }

    $conn->beginTransaction();

    // Insert member
    $stmt = $conn->prepare("INSERT INTO team_members (team_id, employee_id) VALUES (?, ?)");
    $stmt->execute([$team_id, $employee_id]);

    if ($leader_id === null || intval($leader_id) === 0) {
        $stmt = $conn->prepare("UPDATE teams SET employee_id=? WHERE team_id=?");
        $stmt->execute([$employee_id, $team_id]);
    }

    $conn->commit();

    echo json_encode([
        "status" => true,
        "message" => "Added to team"
    ]);

} catch (Throwable $e) {
    if (isset($conn) && $conn->inTransaction()) $conn->rollBack();
    http_response_code(500);
    echo json_encode(["status" => false, "message" => $e->getMessage()]);
}
