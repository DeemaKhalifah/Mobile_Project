<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

include 'config.php';

$data = json_decode(file_get_contents("php://input"));

if(!empty($data->email) && !empty($data->password)) {
    
    $email = $data->email;
    $password = $data->password;

    $stmt = $conn->prepare("SELECT * FROM users WHERE email=:email");
    $stmt->bindParam(':email', $email);
    $stmt->execute();

    if($stmt->rowCount() > 0) {
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        if(password_verify($password, $user['password'])) {
            echo json_encode([
                "status" => true,
                "message" => "Login successful",
                "role" => $user['role'],
                "user" => [
                    "id" => $user['id'],
                    "name" => $user['name'],
                    "email" => $user['email'],
                    "phone" => $user['phone']
                ]
            ]);
        } else {
            echo json_encode(["status" => false, "message" => "Invalid password"]);
        }
    } else {
        echo json_encode(["status" => false, "message" => "User not found"]);
    }

} else {
    echo json_encode(["status" => false, "message" => "Email and password required"]);
}
?>
