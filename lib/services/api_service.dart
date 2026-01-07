import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/service.dart';
import '../models/booking.dart';
import '../models/customerwallet.dart';
import '../models/feedbackmodel.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2/carwash_api";

  static const Map<String, String> headers = {
    "Content-Type": "application/json",
  };

  /* ===================== AUTH ===================== */

  static Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
    String role,
    String phone,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/signup.php"),
      headers: headers,
      body: jsonEncode({
        "name": name,
        "email": email,
        "password": password,
        "role": role,
        "phone": phone,
      }),
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
  static Future<Map<String, dynamic>> createBooking(
    Booking booking,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/booking.php"),
      headers: headers,
      body: jsonEncode(booking.toJson()),
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

  /// ✏️ Update Booking
  static Future<Map<String, dynamic>> updateBooking(
    Booking booking,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/update_booking.php"),
      headers: headers,
      body: jsonEncode(booking.toJson()),
    );

    return jsonDecode(response.body);
  }

  /// ❌ Cancel Booking
  static Future<Map<String, dynamic>> cancelBooking(
    int bookingId,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/cancel_booking.php"),
      headers: headers,
      body: jsonEncode({
        "id": bookingId,
      }),
    );

    return jsonDecode(response.body);
  }

  /* ===================== WALLET ===================== */

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
    double balance,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/update_wallet.php"),
      headers: headers,
      body: jsonEncode({
        "email": email,
        "balance": balance,
      }),
    );

    final data = jsonDecode(response.body);

    if (data['status'] != true) {
      throw Exception(data['message']);
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
