<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

include "config.php";

$data = json_decode(file_get_contents("php://input"));

if (
    empty($data->id) ||
    empty($data->location) ||
    empty($data->booking_date) ||
    empty($data->booking_time)
) {
    echo json_encode(["status" => false, "message" => "Missing required booking data"]);
    exit;
}

try {
    $conn->beginTransaction();

    $bookingId   = (int)$data->id;
    $newDate     = trim($data->booking_date);
    $newTime     = trim($data->booking_time);
    $newLocation = trim($data->location);
    $newNotes    = isset($data->notes) ? $data->notes : null;

    // 0) Fetch current booking (status + old slot)
    $stmt = $conn->prepare("
        SELECT id, status, team_id, booking_date, booking_time, car_id
        FROM bookings
        WHERE id = :id
        LIMIT 1
    ");
    $stmt->bindParam(":id", $bookingId, PDO::PARAM_INT);
    $stmt->execute();
    $oldBooking = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$oldBooking) {
        throw new Exception("Booking not found");
    }

    if ($oldBooking['status'] === 'completed') {
        throw new Exception("Completed booking cannot be updated");
    }
    if ($oldBooking['status'] === 'cancelled') {
        throw new Exception("Cancelled booking cannot be updated");
    }

    // 1) Free OLD reservation slot (remove from team_bookings)
    $stmt = $conn->prepare("DELETE FROM team_bookings WHERE booking_id = :booking_id");
    $stmt->bindParam(":booking_id", $bookingId, PDO::PARAM_INT);
    $stmt->execute();

    // 2) Find an available team for NEW date/time
    // teams table uses team_id (not id)
    $stmt = $conn->prepare("
        SELECT t.team_id
        FROM teams t
        WHERE t.team_id NOT IN (
            SELECT tb.team_id
            FROM team_bookings tb
            WHERE tb.booking_date = :bdate
              AND tb.booking_time = :btime
        )
        ORDER BY t.team_id ASC
        LIMIT 1
    ");
    $stmt->bindParam(":bdate", $newDate);
    $stmt->bindParam(":btime", $newTime);
    $stmt->execute();
    $team = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$team) {
        throw new Exception("No available team for the selected time");
    }

    $newTeamId = (int)$team['team_id'];

    // 3) Update booking info + assign new team_id
    $stmt = $conn->prepare("
        UPDATE bookings
        SET location = :location,
            notes = :notes,
            booking_date = :booking_date,
            booking_time = :booking_time,
            team_id = :team_id
        WHERE id = :id
    ");
    $stmt->bindParam(":id", $bookingId, PDO::PARAM_INT);
    $stmt->bindParam(":location", $newLocation);
    $stmt->bindParam(":notes", $newNotes);
    $stmt->bindParam(":booking_date", $newDate);
    $stmt->bindParam(":booking_time", $newTime);
    $stmt->bindParam(":team_id", $newTeamId, PDO::PARAM_INT);
    $stmt->execute();

    // 4) Insert NEW reservation slot into team_bookings
    $stmt = $conn->prepare("
        INSERT INTO team_bookings (team_id, booking_date, booking_time, booking_id)
        VALUES (:team_id, :booking_date, :booking_time, :booking_id)
    ");
    $stmt->bindParam(":team_id", $newTeamId, PDO::PARAM_INT);
    $stmt->bindParam(":booking_date", $newDate);
    $stmt->bindParam(":booking_time", $newTime);
    $stmt->bindParam(":booking_id", $bookingId, PDO::PARAM_INT);
    $stmt->execute();

    // 5) Update car info if provided
    if (!empty($data->car_model) || !empty($data->car_plate)) {

        $carId = $oldBooking['car_id'];

        if ($carId) {
            $fields = [];
            $params = [];

            if (!empty($data->car_model)) {
                $fields[] = "car_model = ?";
                $params[] = $data->car_model;
            }
            if (!empty($data->car_plate)) {
                $fields[] = "car_plate = ?";
                $params[] = $data->car_plate;
            }

            $params[] = $carId;

            $stmt = $conn->prepare("
                UPDATE cars
                SET " . implode(", ", $fields) . "
                WHERE car_id = ?
            ");
            $stmt->execute($params);
        }
    }

    $conn->commit();

    echo json_encode([
        "status" => true,
        "message" => "Booking and car info updated",
        "team_id" => $newTeamId
    ]);

} catch (Exception $e) {
    if ($conn->inTransaction()) $conn->rollBack();
    echo json_encode(["status" => false, "message" => "Update failed: " . $e->getMessage()]);
}
