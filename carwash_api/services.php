<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include 'config.php';

$stmt = $conn->prepare("SELECT * FROM services");
$stmt->execute();

$services = $stmt->fetchAll(PDO::FETCH_ASSOC);

if($services){
    echo json_encode(["status"=>true, "services"=>$services]);
} else {
    echo json_encode(["status"=>false, "message"=>"No services found"]);
}
?>
