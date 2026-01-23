<?php
header('Content-Type: application/json; charset=utf-8');
header("Access-Control-Allow-Origin: *");
ini_set('display_errors', 0);
error_reporting(E_ALL);
ob_start();

try {
    require_once "config.php"; 
    ob_end_clean();

    $sql = "
        SELECT u.id, u.name, u.email, u.phone
        FROM users u
        LEFT JOIN team_members tm ON tm.employee_id = u.id
        WHERE u.role = 'employee' AND tm.employee_id IS NULL
        ORDER BY u.name ASC
    ";
    $stmt = $conn->prepare($sql);
    $stmt->execute();

    echo json_encode([
        "status" => true,
        "employees" => $stmt->fetchAll(PDO::FETCH_ASSOC)
    ]);

} catch (Throwable $e) {
    ob_end_clean();
    http_response_code(500);
    echo json_encode(["status" => false, "message" => $e->getMessage()]);
}
