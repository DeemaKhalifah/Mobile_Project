class Booking {
  int? id;
  String customerEmail;
  String serviceName;
  String location;
  String notes;
  String bookingDate;
  String bookingTime;
  int? carId;
  String? carModel;
  String? carPlate;

  // ✅ NEW
  String status;

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
    this.status = 'pending', // default
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

        // ✅ NEW (اختياري إذا بدك تبعتيه)
        'status': status,
      };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'],
        customerEmail: (json['customer_email'] ?? '').toString(),
        serviceName: (json['service_name'] ?? '').toString(),
        location: (json['location'] ?? '').toString(),
        notes: (json['notes'] ?? '').toString(),
        bookingDate: (json['booking_date'] ?? '').toString(),
        bookingTime: (json['booking_time'] ?? '').toString(),
        carId: json['car_id'] == null ? null : int.tryParse(json['car_id'].toString()),
        carModel: json['car_model']?.toString(),
        carPlate: json['car_plate']?.toString(),

        // ✅ NEW
        status: (json['status'] ?? 'pending').toString(),
      );
}