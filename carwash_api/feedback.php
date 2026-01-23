<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");

include 'config.php'; // اتصال قاعدة البيانات

class Feedback {
    public $customer_id;
    public $service_id;
    public $rating;
    public $comment;

    public function __construct($customer_id, $service_id, $rating, $comment = '') {
        $this->customer_id = $customer_id;
        $this->service_id = $service_id;
        $this->rating = $rating;
        $this->comment = $comment;
    }

    public function save($conn) {
        // تحقق من صحة التقييم
        if($this->rating < 1 || $this->rating > 5) {
            return ["status" => false, "message" => "Rating must be between 1 and 5"];
        }

        $stmt = $conn->prepare("INSERT INTO feedbacks (customer_id, service_id, rating, comment) VALUES (:customer_id, :service_id, :rating, :comment)");
        $stmt->bindParam(':customer_id', $this->customer_id);
        $stmt->bindParam(':service_id', $this->service_id);
        $stmt->bindParam(':rating', $this->rating);
        $stmt->bindParam(':comment', $this->comment);

        if($stmt->execute()) {
            return ["status" => true, "message" => "Feedback submitted successfully"];
        } else {
            return ["status" => false, "message" => "Failed to submit feedback"];
        }
    }
}

// قراءة بيانات POST
$data = json_decode(file_get_contents("php://input"));

if(!empty($data->customer_id) && !empty($data->service_id) && !empty($data->rating)) {
    $feedback = new Feedback($data->customer_id, $data->service_id, $data->rating, $data->comment ?? '');
    $result = $feedback->save($conn);
    echo json_encode($result);
} else {
    echo json_encode(["status" => false, "message" => "Customer ID, Service ID and Rating are required"]);
}
?>
