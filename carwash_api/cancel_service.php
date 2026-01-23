<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'config.php';

$data = json_decode(file_get_contents("php://input"));

// Validate input
if (!isset($data->id) || !isset($data->customer_email) || !isset($data->refund_amount)) {
    echo json_encode(["status" => false, "message" => "Required data missing"]);
    exit;
}

try {
    $conn->beginTransaction();

    // 0) Make sure booking exists and can be cancelled (not completed / not already cancelled)
    $stmt = $conn->prepare("
        SELECT id, status
        FROM bookings
        WHERE id = :id AND customer_email = :email
        LIMIT 1
    ");
    $stmt->bindParam(":id", $data->id, PDO::PARAM_INT);
    $stmt->bindParam(":email", $data->customer_email);
    $stmt->execute();
    $booking = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$booking) {
        throw new Exception("Booking not found");
    }
    if ($booking['status'] === 'completed') {
        throw new Exception("Completed booking cannot be cancelled");
    }
    if ($booking['status'] === 'cancelled') {
        throw new Exception("Booking already cancelled");
    }

    // 1) Get user ID
    $stmt = $conn->prepare("SELECT id FROM users WHERE email = :email LIMIT 1");
    $stmt->bindParam(":email", $data->customer_email);
    $stmt->execute();
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user) {
        throw new Exception("User not found");
    }
    $userId = (int)$user['id'];

    // 2) Refund to wallet (create wallet if it doesn't exist)
    $refundAmount = (float)$data->refund_amount;
    if ($refundAmount <= 0) {
        throw new Exception("Invalid refund amount");
    }

    $stmt = $conn->prepare("SELECT id FROM wallets WHERE user_id = :user_id LIMIT 1");
    $stmt->bindParam(":user_id", $userId, PDO::PARAM_INT);
    $stmt->execute();
    $walletExists = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($walletExists) {
        $stmt = $conn->prepare("
            UPDATE wallets
            SET balance = balance + :amount
            WHERE user_id = :user_id
        ");
        $stmt->bindParam(":amount", $refundAmount);
        $stmt->bindParam(":user_id", $userId, PDO::PARAM_INT);
        $stmt->execute();
    } else {
        // IMPORTANT: fill NOT NULL fields
        $stmt = $conn->prepare("
            INSERT INTO wallets (user_id, card_number, card_holder, expiry_date, cvv, balance)
            VALUES (:user_id, '', '', '', '', :amount)
        ");
        $stmt->bindParam(":user_id", $userId, PDO::PARAM_INT);
        $stmt->bindParam(":amount", $refundAmount);
        $stmt->execute();
    }

    // 3) Mark booking as cancelled
    $stmt = $conn->prepare("
        UPDATE bookings
        SET status = 'cancelled'
        WHERE id = :id AND customer_email = :email
    ");
    $stmt->bindParam(":id", $data->id, PDO::PARAM_INT);
    $stmt->bindParam(":email", $data->customer_email);
    $stmt->execute();

    if ($stmt->rowCount() == 0) {
        throw new Exception("Failed to cancel booking");
    }

    // 4) Free the reserved team slot for this booking (if exists)
    $stmt = $conn->prepare("DELETE FROM team_bookings WHERE booking_id = :id");
    $stmt->bindParam(":id", $data->id, PDO::PARAM_INT);
    $stmt->execute();

    $conn->commit();

    echo json_encode(["status" => true, "message" => "Booking cancelled and money refunded"]);

} catch (Exception $e) {
    if ($conn->inTransaction()) $conn->rollBack();
    echo json_encode(["status" => false, "message" => "Cancellation failed: " . $e->getMessage()]);
}
?>
