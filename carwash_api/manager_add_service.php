<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
  http_response_code(200);
  exit;
}

include "config.php"; 

function ok($arr){ echo json_encode($arr); exit; }
function fail($msg){ ok(["status"=>false,"message"=>$msg]); }

$name = "";
$price = "";
$description = "";
$imageValue = ""; // what we will store in DB

$isMultipart = isset($_POST['name']) || isset($_FILES['image']);

if ($isMultipart) {
  $name = trim($_POST['name'] ?? "");
  $price = trim($_POST['price'] ?? "");
  $description = trim($_POST['description'] ?? "");
  $imageValue = trim($_POST['image'] ?? "");
} else {
  $data = json_decode(file_get_contents("php://input"), true);
  $name = trim($data['name'] ?? "");
  $price = trim($data['price'] ?? "");
  $description = trim($data['description'] ?? "");
  $imageValue = trim($data['image'] ?? "");
}

if ($name === "" || $price === "" || floatval($price) <= 0) {
  fail("name and valid price are required");
}


//Upload file if exists (field name: image)
if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {

  $uploadDir = __DIR__ . "/uploads";
  if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0777, true);
  }

  $tmpName = $_FILES['image']['tmp_name'];
  $origName = $_FILES['image']['name'];

  $ext = strtolower(pathinfo($origName, PATHINFO_EXTENSION));
  $allowed = ["jpg","jpeg","png","webp"];
  if (!in_array($ext, $allowed)) {
    fail("Only jpg/jpeg/png/webp allowed");
  }

  $newName = "svc_" . time() . "_" . bin2hex(random_bytes(4)) . "." . $ext;
  $destPath = $uploadDir . "/" . $newName;

  if (!move_uploaded_file($tmpName, $destPath)) {
    fail("Failed to upload image");
  }

  $imageValue = $newName;
}

try {
  $stmt = $conn->prepare("INSERT INTO services (name, price, image, description) VALUES (:name, :price, :image, :description)");
  $stmt->execute([
    ":name" => $name,
    ":price" => $price,
    ":image" => $imageValue,
    ":description" => $description
  ]);

  ok(["status"=>true,"message"=>"Service added successfully"]);
} catch (PDOException $e) {
  ok(["status"=>false,"message"=>$e->getMessage()]);
}
