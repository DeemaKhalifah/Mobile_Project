
class Car {
  final int? carId;
  final int userId;
  final String carModel;
  final String carPlate;

  Car({
    this.carId,
    required this.userId,
    required this.carModel,
    required this.carPlate,
  });

  Map<String, dynamic> toJson() => {
        "user_id": userId,
        "car_model": carModel,
        "car_plate": carPlate,
      };
}
