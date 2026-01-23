<?php
header('Content-Type: application/json; charset=utf-8');
ini_set('display_errors', 0);
error_reporting(E_ALL);

require_once "config.php"; 

$input = json_decode(file_get_contents("php://input"), true);
$team_id = intval($input['team_id'] ?? 0);

if ($team_id <= 0) {
    http_response_code(400);
    echo json_encode(["status" => false, "message" => "team_id is required"]);
    exit;
}

try {
    $conn->beginTransaction();

    // 1) Make sure team exists
    $stmt = $conn->prepare("SELECT team_id FROM teams WHERE team_id=? LIMIT 1");
    $stmt->execute([$team_id]);
    if (!$stmt->fetch()) {
        $conn->rollBack();
        http_response_code(404);
        echo json_encode(["status" => false, "message" => "Team not found"]);
        exit;
    }

    // 2) Block deletion if team has ACTIVE bookings
    // (active = pending or assigned)
    $stmt = $conn->prepare("
        SELECT COUNT(*) AS cnt
        FROM bookings
        WHERE team_id=? AND status IN ('pending','assigned')
    ");
    $stmt->execute([$team_id]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    $active = intval($row['cnt'] ?? 0);

    if ($active > 0) {
        $conn->rollBack();
        http_response_code(400);
        echo json_encode([
            "status" => false,
            "message" => "Cannot remove team: it has active bookings (pending/assigned)"
        ]);
        exit;
    }

    // 3) Keep booking history: set team_id NULL for old bookings
    $stmt = $conn->prepare("UPDATE bookings SET team_id=NULL WHERE team_id=?");
    $stmt->execute([$team_id]);

    // 4) Remove schedule locks
    $stmt = $conn->prepare("DELETE FROM team_bookings WHERE team_id=?");
    $stmt->execute([$team_id]);

    // 5) Remove members
    $stmt = $conn->prepare("DELETE FROM team_members WHERE team_id=?");
    $stmt->execute([$team_id]);

    // 6) Remove team
    $stmt = $conn->prepare("DELETE FROM teams WHERE team_id=?");
    $stmt->execute([$team_id]);

    $conn->commit();

    echo json_encode(["status" => true, "message" => "Team removed successfully"]);
} catch (Throwable $e) {
    if (isset($conn) && $conn->inTransaction()) $conn->rollBack();
    http_response_code(500);
    echo json_encode(["status" => false, "message" => $e->getMessage()]);
}
