<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
include "config.php";

$data = json_decode(file_get_contents("php://input"));

if (!isset($data->employee_email) || empty($data->employee_email)) {
    echo json_encode(["status" => false, "message" => "employee_email is required"]);
    exit;
}

$status = isset($data->status) ? $data->status : null;

try {
    // 1) get employee user id
    $stmt = $conn->prepare("SELECT id, role FROM users WHERE email = :email LIMIT 1");
    $stmt->bindParam(":email", $data->employee_email);
    $stmt->execute();
    $emp = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$emp) {
        echo json_encode(["status" => false, "message" => "Employee not found"]);
        exit;
    }

    if ($emp['role'] !== 'employee') {
        echo json_encode(["status" => false, "message" => "User is not employee"]);
        exit;
    }

    $employeeId = $emp['id'];

    // 2) get team(s) for this employee
    $stmt = $conn->prepare("SELECT team_id FROM teams WHERE employee_id = :eid");
    $stmt->bindParam(":eid", $employeeId);
    $stmt->execute();
    $teams = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if (!$teams || count($teams) == 0) {
        echo json_encode([
            "status" => true,
            "orders" => [],
            "message" => "No team assigned to this employee"
        ]);
        exit;
    }

    // 3) fetch bookings for these team_ids
    $placeholders = implode(",", array_fill(0, count($teams), "?"));

    $sql = "SELECT b.*
            FROM bookings b
            WHERE b.team_id IN ($placeholders)";

    $params = $teams;

    if ($status && $status !== "") {
        $sql .= " AND b.status = ?";
        $params[] = $status;
    }

    $sql .= " ORDER BY b.created_at DESC";

    $stmt = $conn->prepare($sql);
    $stmt->execute($params);

    $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode(["status" => true, "orders" => $orders]);

} catch (Exception $e) {
    echo json_encode(["status" => false, "message" => "Error: " . $e->getMessage()]);
}
?>
