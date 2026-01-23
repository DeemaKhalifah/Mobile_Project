<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
include "config.php";

$data = json_decode(file_get_contents("php://input"));

if (empty($data->employee_email) || empty($data->booking_id) || empty($data->status)) {
    echo json_encode(["status" => false, "message" => "employee_email, booking_id, status required"]);
    exit;
}

$status = $data->status;

try {
    // employee
    $stmt = $conn->prepare("SELECT id, role FROM users WHERE email = :email LIMIT 1");
    $stmt->bindParam(":email", $data->employee_email);
    $stmt->execute();
    $emp = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$emp || $emp['role'] !== 'employee') {
        echo json_encode(["status" => false, "message" => "Invalid employee"]);
        exit;
    }

    // teams
    $stmt = $conn->prepare("SELECT team_id FROM teams WHERE employee_id = :eid");
    $stmt->bindParam(":eid", $emp['id']);
    $stmt->execute();
    $teams = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if (!$teams || count($teams) == 0) {
        echo json_encode(["status" => false, "message" => "No team assigned"]);
        exit;
    }

    // make sure booking belongs to employee team
    $placeholders = implode(",", array_fill(0, count($teams), "?"));
    $sqlCheck = "SELECT id FROM bookings WHERE id = ? AND team_id IN ($placeholders) LIMIT 1";
    $paramsCheck = array_merge([$data->booking_id], $teams);

    $stmt = $conn->prepare($sqlCheck);
    $stmt->execute($paramsCheck);

    if (!$stmt->fetch()) {
        echo json_encode(["status" => false, "message" => "Not allowed"]);
        exit;
    }

    if ($status === "rejected") {
        // Return to manager: pending + team_id NULL + free slot in team_bookings
        $conn->beginTransaction();

        $stmt = $conn->prepare("UPDATE bookings SET status='pending', team_id=NULL WHERE id=:id");
        $stmt->bindParam(":id", $data->booking_id);
        $stmt->execute();

        $stmt2 = $conn->prepare("DELETE FROM team_bookings WHERE booking_id = :id");
        $stmt2->bindParam(":id", $data->booking_id);
        $stmt2->execute();

        $conn->commit();

        echo json_encode(["status" => true, "message" => "Order rejected and returned to manager"]);
        exit;
    }

    // accept/complete
    if (!in_array($status, ["assigned","completed"])) {
        echo json_encode(["status" => false, "message" => "Invalid status"]);
        exit;
    }

    $stmt = $conn->prepare("UPDATE bookings SET status=:st WHERE id=:id");
    $stmt->bindParam(":st", $status);
    $stmt->bindParam(":id", $data->booking_id);
    $stmt->execute();

    echo json_encode(["status" => true, "message" => "Status updated"]);

} catch (Exception $e) {
    echo json_encode(["status" => false, "message" => "Error: " . $e->getMessage()]);
}
?>
