class Booking {
  final int? id;
  final String customerEmail;
  final String serviceName;
  final String location;
  final String notes;
  final String bookingDate;
  final String bookingTime;

  Booking({
    this.id,
    required this.customerEmail,
    required this.serviceName,
    required this.location,
    this.notes = "",
    required this.bookingDate,
    required this.bookingTime,
  });

  /// ✅ ADD THIS (FIX)
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      customerEmail: json['customer_email'] ?? '',
      serviceName: json['service_name'] ?? '',
      location: json['location'] ?? '',
      notes: json['notes'] ?? '',
      bookingDate: json['booking_date'] ?? '',
      bookingTime: json['booking_time'] ?? '',
    );
  }

  /// ✅ KEEP THIS
  Map<String, dynamic> toJson() => {
        if (id != null) "id": id,
        "customer_email": customerEmail,
        "service_name": serviceName,
        "location": location,
        "notes": notes,
        "booking_date": bookingDate,
        "booking_time": bookingTime,
      };
}
