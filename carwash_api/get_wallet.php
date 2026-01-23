<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'config.php';

$email = $_GET['email'] ?? '';

if (empty($email)) {
    echo json_encode([
        "status" => false,
        "message" => "Email required"
    ]);
    exit;
}

$stmt = $conn->prepare("
    SELECT 
        w.card_number,
        w.card_holder,
        w.expiry_date,
        w.cvv,
        w.balance
    FROM wallets w
    JOIN users u ON u.id = w.user_id
    WHERE u.email = :email
    LIMIT 1
");

$stmt->bindParam(":email", $email);
$stmt->execute();

$wallet = $stmt->fetch(PDO::FETCH_ASSOC);

if ($wallet) {
    echo json_encode([
        "status" => true,
        "wallet" => $wallet
    ]);
} else {
    echo json_encode([
        "status" => false,
        "message" => "Wallet not found"
    ]);
}
