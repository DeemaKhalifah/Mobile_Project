<?php
header('Content-Type: application/json; charset=utf-8');
ini_set('display_errors', 0);
error_reporting(E_ALL);
ob_start();

try {
    require_once "config.php"; 
    ob_end_clean();

    $data = json_decode(file_get_contents("php://input"), true);
    $team_member_id = intval($data['team_member_id'] ?? 0);

    if ($team_member_id <= 0) {
        http_response_code(400);
        echo json_encode(["status"=>false, "message"=>"team_member_id is required"]);
        exit;
    }

    $stmt = $conn->prepare("SELECT team_id, employee_id FROM team_members WHERE id=? LIMIT 1");
    $stmt->execute([$team_member_id]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$row) {
        http_response_code(404);
        echo json_encode(["status"=>false, "message"=>"Team member not found"]);
        exit;
    }

    $team_id = intval($row['team_id']);
    $emp_id  = intval($row['employee_id']);

    $conn->beginTransaction();

    $stmt = $conn->prepare("DELETE FROM team_members WHERE id=?");
    $stmt->execute([$team_member_id]);

    $stmt = $conn->prepare("SELECT employee_id FROM teams WHERE team_id=? LIMIT 1");
    $stmt->execute([$team_id]);
    $teamRow = $stmt->fetch(PDO::FETCH_ASSOC);

    $currentLeader = intval($teamRow['employee_id'] ?? 0);

    if ($currentLeader === $emp_id) {
        $stmt = $conn->prepare("SELECT employee_id FROM team_members WHERE team_id=? ORDER BY id ASC LIMIT 1");
        $stmt->execute([$team_id]);
        $newRow = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($newRow) {
            $newLeader = intval($newRow['employee_id']);
            $stmt = $conn->prepare("UPDATE teams SET employee_id=? WHERE team_id=?");
            $stmt->execute([$newLeader, $team_id]);
        } else {
            $stmt = $conn->prepare("UPDATE teams SET employee_id=NULL WHERE team_id=?");
            $stmt->execute([$team_id]);
        }
    }

    $conn->commit();

    echo json_encode(["status"=>true, "message"=>"Removed"]);

} catch (Throwable $e) {
    if (isset($conn) && $conn->inTransaction()) $conn->rollBack();
    ob_end_clean();
    http_response_code(500);
    echo json_encode(["status"=>false, "message"=>$e->getMessage()]);
}
