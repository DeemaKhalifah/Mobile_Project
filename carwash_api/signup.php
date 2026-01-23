<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: POST");

include "config.php";

/* ===============================
   Password validation
================================ */
function isStrongPassword(string $password): bool {
    return strlen($password) >= 8 &&
           preg_match('/[A-Z]/', $password) &&
           preg_match('/[a-z]/', $password) &&
           preg_match('/[0-9]/', $password) &&
           preg_match('/[\W_]/', $password);
}

/* ===============================
   Palestine phone validation 🇵🇸
================================ */
function isValidPalestinePhone(string $phone): bool {
    // Remove spaces, dashes
    $phone = preg_replace('/[\s\-]/', '', $phone);

    // +9705XXXXXXXX
    if (preg_match('/^\+9705[0-9]{8}$/', $phone)) {
        return true;
    }

    // 05XXXXXXXX
    if (preg_match('/^05[0-9]{8}$/', $phone)) {
        return true;
    }

    return false;
}

/* ===============================
   Read input
================================ */
$raw = file_get_contents("php://input");
$data = json_decode($raw, true);

if (!is_array($data)) {
    $data = $_POST;
}

$name     = trim($data["name"] ?? "");
$email    = trim($data["email"] ?? "");
$password = (string)($data["password"] ?? "");
$role     = strtolower(trim($data["role"] ?? ""));
$phone    = trim($data["phone"] ?? "");

/* ===============================
   Required fields
================================ */
if ($name === "" || $email === "" || $password === "" || $role === "" || $phone === "") {
    echo json_encode([
        "status" => false,
        "message" => "Missing required fields"
    ]);
    exit;
}

/* ===============================
   Phone validation 🇵🇸
================================ */
if (!isValidPalestinePhone($phone)) {
    echo json_encode([
        "status" => false,
        "message" => "Invalid Palestinian phone number. Use 05XXXXXXXX or +9705XXXXXXXX"
    ]);
    exit;
}

/* ===============================
   Password validation
================================ */
if (!isStrongPassword($password)) {
    echo json_encode([
        "status" => false,
        "message" => "Password must be at least 8 characters and include uppercase, lowercase, number, and special character"
    ]);
    exit;
}

/* ===============================
   Role validation
================================ */
$allowedRoles = ["customer", "employee", "manager"];
if (!in_array($role, $allowedRoles, true)) {
    echo json_encode([
        "status" => false,
        "message" => "Invalid role"
    ]);
    exit;
}

try {
    /* ===============================
       Check email exists
    ================================ */
    $chk = $conn->prepare("SELECT id FROM users WHERE email = :email LIMIT 1");
    $chk->execute([":email" => $email]);

    if ($chk->fetch()) {
        echo json_encode([
            "status" => false,
            "message" => "Email already exists"
        ]);
        exit;
    }

    /* ===============================
       Insert user
    ================================ */
    $hashed = password_hash($password, PASSWORD_DEFAULT);

    $stmt = $conn->prepare("
        INSERT INTO users (name, email, password, role, phone, created_at)
        VALUES (:name, :email, :password, :role, :phone, NOW())
    ");

    $stmt->execute([
        ":name"     => $name,
        ":email"    => $email,
        ":password" => $hashed,
        ":role"     => $role,
        ":phone"    => $phone
    ]);

    echo json_encode([
        "status" => true,
        "message" => "Signup successful"
    ]);

} catch (Exception $e) {
    echo json_encode([
        "status" => false,
        "message" => "Server error"
    ]);
}
