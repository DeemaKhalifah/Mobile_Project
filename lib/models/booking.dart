class Booking {
  int? id;
  String customerEmail;
  String serviceName;
  String location;
  String notes;
  String bookingDate;
  String bookingTime;
  int? carId;
  String? carModel;  // new
  String? carPlate;  // new

  Booking({
    this.id,
    required this.customerEmail,
    required this.serviceName,
    required this.location,
    this.notes = '',
    required this.bookingDate,
    required this.bookingTime,
    this.carId,
    this.carModel,
    this.carPlate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer_email': customerEmail,
        'service_name': serviceName,
        'location': location,
        'notes': notes,
        'booking_date': bookingDate,
        'booking_time': bookingTime,
        'car_model': carModel,
        'car_plate': carPlate,
      };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'],
        customerEmail: json['customer_email'],
        serviceName: json['service_name'],
        location: json['location'],
        notes: json['notes'] ?? '',
        bookingDate: json['booking_date'],
        bookingTime: json['booking_time'],
        carId: json['car_id'],
        carModel: json['car_model'],
        carPlate: json['car_plate'],
      );
}
