<?php
header('Content-Type: application/json; charset=utf-8');
ini_set('display_errors', 0);
error_reporting(E_ALL);

try {
    require_once "config.php";

    $team_id = isset($_GET['team_id']) ? intval($_GET['team_id']) : 0;
    if ($team_id <= 0) {
        echo json_encode(["status" => false, "message" => "team_id is required"]);
        exit;
    }

    $sql = "SELECT
                tm.id AS team_member_id,
                tm.employee_id,
                u.name, u.email, u.phone
            FROM team_members tm
            JOIN users u ON u.id = tm.employee_id
            WHERE tm.team_id = ?";

    $stmt = $conn->prepare($sql);
    $stmt->execute([$team_id]);
    $members = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(["status" => true, "members" => $members]);

} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode(["status" => false, "message" => $e->getMessage()]);
}
