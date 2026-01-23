<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

include 'config.php';

$data = json_decode(file_get_contents("php://input"));

if (empty($data->email) || !isset($data->balance)) {
    echo json_encode([
        "status" => false,
        "message" => "Email and balance required"
    ]);
    exit;
}

// Get user id first
$stmt = $conn->prepare(
    "SELECT id FROM users WHERE email = :email LIMIT 1"
);
$stmt->bindParam(":email", $data->email);
$stmt->execute();

$user = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$user) {
    echo json_encode([
        "status" => false,
        "message" => "User not found"
    ]);
    exit;
}

// Update wallet
$stmt = $conn->prepare(
    "UPDATE wallets SET balance = :balance WHERE user_id = :user_id"
);
$stmt->bindParam(":balance", $data->balance);
$stmt->bindParam(":user_id", $user['id']);

if ($stmt->execute()) {
    echo json_encode([
        "status" => true,
        "message" => "Wallet updated successfully"
    ]);
} else {
    echo json_encode([
        "status" => false,
        "message" => "Failed to update wallet"
    ]);
}
?>
