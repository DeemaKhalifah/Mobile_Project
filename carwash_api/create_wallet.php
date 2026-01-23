<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'config.php';

$email = $_POST['email'] ?? null;

if (!$email) {
    echo json_encode([
        "status" => false,
        "message" => "Email required"
    ]);
    exit;
}

// get user id
$stmt = $conn->prepare("SELECT id FROM users WHERE email = :email LIMIT 1");
$stmt->bindParam(":email", $email);
$stmt->execute();
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$user) {
    echo json_encode([
        "status" => false,
        "message" => "User not found"
    ]);
    exit;
}

// prevent duplicate wallet
$stmt = $conn->prepare("SELECT id FROM wallets WHERE user_id = :user_id LIMIT 1");
$stmt->bindParam(":user_id", $user['id']);
$stmt->execute();

if ($stmt->rowCount() > 0) {
    echo json_encode([
        "status" => true,
        "message" => "Wallet already exists"
    ]);
    exit;
}

// create wallet (fill NOT NULL fields with empty strings)
$stmt = $conn->prepare("
    INSERT INTO wallets (user_id, card_number, card_holder, expiry_date, cvv, balance)
    VALUES (:user_id, '', '', '', '', 0)
");

$stmt->bindParam(":user_id", $user['id']);

if ($stmt->execute()) {
    echo json_encode([
        "status" => true,
        "message" => "Wallet created"
    ]);
} else {
    echo json_encode([
        "status" => false,
        "message" => "Failed to create wallet"
    ]);
}
