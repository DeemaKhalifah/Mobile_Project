<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
ini_set('display_errors', 0);
error_reporting(E_ALL);

require_once "config.php";

function respond($status, $message, $extra = []) {
  echo json_encode(array_merge(["status" => $status, "message" => $message], $extra));
  exit;
}


function normalizeImageToFilename($img) {
  $img = trim((string)$img);
  if ($img === "") return "";
  if (preg_match('~^https?://~i', $img)) {
    $path = parse_url($img, PHP_URL_PATH);
    if ($path) return basename($path);
    return basename($img);
  }
  if (strpos($img, '/') !== false) return basename($img);
  return $img;
}

$id = 0;
$name = "";
$price = 0;
$description = "";
$image = null; 

$contentType = $_SERVER['CONTENT_TYPE'] ?? "";

// JSON
if (stripos($contentType, "application/json") !== false) {
  $data = json_decode(file_get_contents("php://input"), true) ?: [];
  $id = intval($data["id"] ?? 0);
  $name = trim($data["name"] ?? "");
  $price = floatval($data["price"] ?? 0);
  $description = trim($data["description"] ?? "");
  $image = isset($data["image"]) ? trim($data["image"]) : null; 
}
// Multipart
else {
  $id = intval($_POST["id"] ?? 0);
  $name = trim($_POST["name"] ?? "");
  $price = floatval($_POST["price"] ?? 0);
  $description = trim($_POST["description"] ?? "");
}

if ($id <= 0 || $name === "" || $price <= 0) {
  respond(false, "id, name, and valid price are required");
}

try {
  $stmt = $conn->prepare("SELECT image FROM services WHERE id=?");
  $stmt->execute([$id]);
  $row = $stmt->fetch(PDO::FETCH_ASSOC);
  if (!$row) respond(false, "Service not found");

  $currentImage = normalizeImageToFilename($row["image"] ?? "");

  if (!empty($_FILES["image"]) && $_FILES["image"]["error"] === UPLOAD_ERR_OK) {
    $tmp = $_FILES["image"]["tmp_name"];
    $orig = $_FILES["image"]["name"];

    $ext = strtolower(pathinfo($orig, PATHINFO_EXTENSION));
    $allowed = ["jpg","jpeg","png","webp"];
    if (!in_array($ext, $allowed)) {
      respond(false, "Invalid image type. Allowed: jpg, jpeg, png, webp");
    }

    $uploadDir = __DIR__ . "/uploads";
    if (!is_dir($uploadDir)) {
      @mkdir($uploadDir, 0777, true);
    }

    $fileName = uniqid("svc_", true) . "." . $ext;
    $destPath = $uploadDir . "/" . $fileName;

    if (!move_uploaded_file($tmp, $destPath)) {
      respond(false, "Failed to upload image");
    }

    $image = $fileName;
  } else {
    if ($image === null) {
      $image = $currentImage;
    } else {
      $image = normalizeImageToFilename($image);
    }
  }

  $stmt = $conn->prepare("UPDATE services SET name=?, price=?, image=?, description=? WHERE id=?");
  $stmt->execute([$name, $price, $image, $description, $id]);

  respond(true, "Service updated successfully");
} catch (Throwable $e) {
  respond(false, $e->getMessage());
}
