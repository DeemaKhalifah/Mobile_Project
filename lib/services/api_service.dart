import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/service.dart';
import '../models/booking.dart';
import '../models/customerwallet.dart';
import '../models/feedbackmodel.dart';

class ApiService {
  static const String baseUrl = "http://localhost/carwash_api";

  static const Map<String, String> headers = {
    "Content-Type": "application/json",
  };

  /* ===================== AUTH ===================== */

  static Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
    String role,
    String phone, {
    String? carNumber,
    String? carColor,
  }) async {
    final body = {
      "name": name,
      "email": email,
      "password": password,
      "role": role,
      "phone": phone,
      if (carNumber != null && carNumber.isNotEmpty) "car_number": carNumber,
      if (carColor != null && carColor.isNotEmpty) "car_color": carColor,
    };

    final response = await http.post(
      Uri.parse("$baseUrl/signup.php"),
      headers: headers,
      body: jsonEncode(body),
    );

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login.php"),
      headers: headers,
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    return jsonDecode(response.body);
  }

  /* ===================== SERVICES ===================== */

  static Future<List<Service>> getServices() async {
    final response = await http.get(
      Uri.parse("$baseUrl/services.php"),
    );

    final data = jsonDecode(response.body);

    if (data['status'] == true) {
      return (data['services'] as List)
          .map((e) => Service.fromJson(e))
          .toList();
    } else {
      throw Exception(data['message'] ?? "Failed to load services");
    }
  }

  /* ===================== BOOKINGS ===================== */

  /// ➕ Create Booking
 static Future<Map<String, dynamic>> createBookingWithCar(
    Booking booking,
    String carModel,
    String carPlate,
) async {
  final response = await http.post(
    Uri.parse("$baseUrl/booking.php"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({
      ...booking.toJson(),
      "car_model": carModel,
      "car_plate": carPlate,
    }),
  );

  return jsonDecode(response.body);
}

  /// 📄 Get Customer Bookings
  static Future<List<Booking>> getCustomerBookings(
    String customerEmail,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/get_bookings.php"),
      headers: headers,
      body: jsonEncode({
        "customer_email": customerEmail,
      }),
    );

    final data = jsonDecode(response.body);

    if (data['status'] == true) {
      return (data['bookings'] as List)
          .map((e) => Booking.fromJson(e))
          .toList();
    } else {
      return [];
    }
  }

static Future<Map<String, dynamic>> updateBooking(
  Booking booking, {
  String? carModel,
  String? carPlate,
}) async {
  final body = booking.toJson();
  if (carModel != null) body['car_model'] = carModel;
  if (carPlate != null) body['car_plate'] = carPlate;

  final response = await http.post(
    Uri.parse("$baseUrl/update_booking.php"),
    headers: headers,
    body: jsonEncode(body),
  );

  return jsonDecode(response.body);
}



  /// ❌ Cancel Booking
  static Future<Map<String, dynamic>> cancelBooking(
    int bookingId,
    String customerEmail,
    double refundAmount,
) async {
  final response = await http.post(
    Uri.parse("$baseUrl/cancel_service.php"),
    headers: headers,
    body: jsonEncode({
      "id": bookingId,
      "customer_email": customerEmail,
      "refund_amount": refundAmount,
    }),
  );

  return jsonDecode(response.body);
}



  /* ===================== WALLET ===================== */

  /// Create wallet for new user
  /// Creates a wallet with balance = 0 and all card details as NULL
  static Future<void> createWallet(
  String email, {
  int? userId,
}) async {
  final response = await http.post(
    Uri.parse("$baseUrl/create_wallet.php"),
    body: {
      'email': email,
      if (userId != null) 'user_id': userId.toString(),
    },
  );

  final data = jsonDecode(response.body);

  if (!data['status']) {
    throw data['message'];
  }
}


  static Future<CustomerWallet> getWallet(
    String email,
  ) async {
    final response = await http.get(
      Uri.parse("$baseUrl/get_wallet.php?email=$email"),
    );

    final data = jsonDecode(response.body);

    if (data['status'] == true) {
      return CustomerWallet.fromJson(data['wallet']);
    } else {
      throw Exception(data['message']);
    }
  }

  static Future<void> updateWallet(
    String email,
    double balance, {
    String? cardNumber,
    String? cardHolder,
    String? expiryDate,
    String? cvv,
  }) async {
    final body = {
      "email": email,
      "balance": balance,
    };

    // Add card details if provided
    if (cardNumber != null) body["card_number"] = cardNumber;
    if (cardHolder != null) body["card_holder"] = cardHolder;
    if (expiryDate != null) body["expiry_date"] = expiryDate;
    if (cvv != null) body["cvv"] = cvv;

    final response = await http.post(
      Uri.parse("$baseUrl/update_wallet.php"),
      headers: headers,
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);

    if (data['status'] != true) {
      throw Exception(data['message']);
    }
  }

  /// Refund money to wallet
  static Future<void> refundToWallet(String email, double amount) async {
    final response = await http.post(
      Uri.parse("$baseUrl/refund_wallet.php"),
      headers: headers,
      body: jsonEncode({
        "email": email,
        "amount": amount,
      }),
    );

    final data = jsonDecode(response.body);

    if (data['status'] != true) {
      throw Exception(data['message'] ?? "Failed to refund");
    }
  }

  /* ===================== FEEDBACK ===================== */

  static Future<bool> submitFeedback(
    FeedbackModel feedback,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/feedback.php"),
      headers: headers,
      body: jsonEncode(feedback.toJson()),
    );

    final data = jsonDecode(response.body);
    return data['status'] == true;
  }
}
