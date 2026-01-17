import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/service.dart';
import '../models/booking.dart';
import '../models/customerwallet.dart';
import '../models/feedbackmodel.dart';
import 'dart:io';

dynamic safeJsonDecode(String body, {String? url}) {
  final trimmed = body.trimLeft();
  if (trimmed.startsWith('<')) {
    throw FormatException(
      "Server returned HTML not JSON${url == null ? '' : ' ($url)'}:\n$body",
    );
  }
  return jsonDecode(body);
}

class ApiService {
  //static const String baseUrl = "http://192.168.137.1/carwash_api";

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
      body: jsonEncode({"email": email, "password": password}),
    );

    return jsonDecode(response.body);
  }

  /* ===================== SERVICES ===================== */

  static Future<List<Service>> getServices() async {
    final response = await http.get(Uri.parse("$baseUrl/services.php"));

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
  static Future<List<Booking>> getCustomerBookings(String customerEmail) async {
    final response = await http.post(
      Uri.parse("$baseUrl/get_bookings.php"),
      headers: headers,
      body: jsonEncode({"customer_email": customerEmail}),
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
  static Future<void> createWallet(String email, {int? userId}) async {
    final response = await http.post(
      Uri.parse("$baseUrl/create_wallet.php"),
      body: {'email': email, if (userId != null) 'user_id': userId.toString()},
    );

    final data = jsonDecode(response.body);

    if (!data['status']) {
      throw data['message'];
    }
  }

  static Future<CustomerWallet> getWallet(String email) async {
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
    final body = {"email": email, "balance": balance};

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
      body: jsonEncode({"email": email, "amount": amount}),
    );

    final data = jsonDecode(response.body);

    if (data['status'] != true) {
      throw Exception(data['message'] ?? "Failed to refund");
    }
  }

  /* ===================== FEEDBACK ===================== */

  static Future<bool> submitFeedback(FeedbackModel feedback) async {
    final response = await http.post(
      Uri.parse("$baseUrl/feedback.php"),
      headers: headers,
      body: jsonEncode(feedback.toJson()),
    );

    final data = jsonDecode(response.body);
    return data['status'] == true;
  }

  /* ===================== EMPLOYEE ===================== */

  static Future<List<Map<String, dynamic>>> getEmployeeOrders(
    String employeeEmail, {
    String? status,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/employee_orders.php"),
      headers: headers,
      body: jsonEncode({
        "employee_email": employeeEmail,
        if (status != null && status.isNotEmpty) "status": status,
      }),
    );

    final data = jsonDecode(response.body);
    if (data['status'] == true) {
      return List<Map<String, dynamic>>.from(data['orders'] ?? []);
    } else {
      throw Exception(data['message'] ?? "Failed to load orders");
    }
  }

  static Future<Map<String, dynamic>> getEmployeeOrderDetails(
    String employeeEmail,
    int bookingId,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/employee_order_details.php"),
      headers: headers,
      body: jsonEncode({
        "employee_email": employeeEmail,
        "booking_id": bookingId,
      }),
    );

    final data = jsonDecode(response.body);
    if (data['status'] == true) {
      return Map<String, dynamic>.from(data['order']);
    } else {
      throw Exception(data['message'] ?? "Failed to load order details");
    }
  }

  static Future<Map<String, dynamic>> updateOrderStatus(
    String employeeEmail,
    int bookingId,
    String status,
  ) async {
    final response = await http.post(
      Uri.parse("$baseUrl/update_order_status.php"),
      headers: headers,
      body: jsonEncode({
        "employee_email": employeeEmail,
        "booking_id": bookingId,
        "status": status,
      }),
    );

    return jsonDecode(response.body);
  }

  /* ===================== MANAGER ===================== */

  static Future<List<Map<String, dynamic>>> managerGetOrders() async {
    final res = await http.get(Uri.parse("$baseUrl/manager_get_orders.php"));
    final data = jsonDecode(res.body);
    if (data['status'] == true) {
      return List<Map<String, dynamic>>.from(data['orders'] ?? []);
    }
    throw Exception(data['message'] ?? "Failed to load orders");
  }

  static Future<Map<String, dynamic>> managerOrderDetails(int bookingId) async {
    final res = await http.post(
      Uri.parse("$baseUrl/manager_order_details.php"),
      headers: headers,
      body: jsonEncode({"booking_id": bookingId}),
    );
    final data = jsonDecode(res.body);
    if (data['status'] == true) return Map<String, dynamic>.from(data['order']);
    throw Exception(data['message'] ?? "Failed to load order details");
  }

  static Future<List<Map<String, dynamic>>> managerGetServices() async {
    final res = await http.get(Uri.parse("$baseUrl/manager_get_services.php"));
    final data = jsonDecode(res.body);
    if (data['status'] == true) {
      return List<Map<String, dynamic>>.from(data['services'] ?? []);
    }
    throw Exception(data['message'] ?? "Failed to load services");
  }

  static Future<Map<String, dynamic>> managerAddServiceMultipart({
    required String name,
    required double price,
    String description = '',
    File? imageFile,
  }) async {
    final url = "$baseUrl/manager_add_service.php";
    final uri = Uri.parse(url);

    final req = http.MultipartRequest('POST', uri)
      ..fields['name'] = name
      ..fields['price'] = price.toString()
      ..fields['description'] = description;

    if (imageFile != null) {
      req.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();
    return Map<String, dynamic>.from(safeJsonDecode(body, url: url));
  }

  static Future<Map<String, dynamic>> managerUpdateServiceMultipart({
    required int id,
    required String name,
    required double price,
    String description = '',
    File? imageFile,
    String imageValueIfNoFile = '',
  }) async {
    final url = "$baseUrl/manager_update_service.php";
    final uri = Uri.parse(url);

    final req = http.MultipartRequest('POST', uri)
      ..fields['id'] = id.toString()
      ..fields['name'] = name
      ..fields['price'] = price.toString()
      ..fields['description'] = description;

    if (imageFile != null) {
      req.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    } else {
      if (imageValueIfNoFile.trim().isNotEmpty) {
        req.fields['image'] = imageValueIfNoFile.trim();
      }
    }

    final streamed = await req.send();
    final body = await streamed.stream.bytesToString();
    return Map<String, dynamic>.from(safeJsonDecode(body, url: url));
  }

  static Future<Map<String, dynamic>> managerDeleteService(int id) async {
    final res = await http.post(
      Uri.parse("$baseUrl/manager_delete_service.php"),
      headers: headers,
      body: jsonEncode({"id": id}),
    );
    return jsonDecode(res.body);
  }

  static Future<List<Map<String, dynamic>>> managerGetTeams() async {
    final res = await http.get(Uri.parse("$baseUrl/manager_get_teams.php"));
    final data = jsonDecode(res.body);
    if (data['status'] == true) {
      return List<Map<String, dynamic>>.from(data['teams'] ?? []);
    }
    throw Exception(data['message'] ?? "Failed to load teams");
  }

  static Future<Map<String, dynamic>> managerAddTeam(
    String teamName,
    int employeeId,
    String carNumberPlate,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/manager_add_team.php"),
      headers: headers,
      body: jsonEncode({
        "team_name": teamName,
        "employee_id": employeeId,
        "car_number_plate": carNumberPlate,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<List<Map<String, dynamic>>>
  managerGetAvailableEmployees() async {
    final res = await http.get(
      Uri.parse("$baseUrl/manager_get_available_employees.php"),
    );
    final data = jsonDecode(res.body);
    if (data['status'] == true) {
      return List<Map<String, dynamic>>.from(data['employees'] ?? []);
    }
    throw Exception(data['message'] ?? "Failed to load available employees");
  }

  static Future<List<Map<String, dynamic>>> managerGetTeamMembers(
    int teamId,
  ) async {
    final uri = Uri.parse(
      "$baseUrl/manager_get_team_members.php?team_id=$teamId",
    );
    final res = await http.get(uri);
    try {
      final data = jsonDecode(res.body);
      if (data['status'] == true) {
        return List<Map<String, dynamic>>.from(data['members'] ?? []);
      }
      throw Exception(data['message'] ?? "Failed to load team members");
    } catch (_) {
      throw Exception("Server returned non-JSON response:\n${res.body}");
    }
  }

  static Future<Map<String, dynamic>> managerAddTeamMember(
    int teamId,
    int employeeId,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/manager_add_team_member.php"),
      headers: headers,
      body: jsonEncode({"team_id": teamId, "employee_id": employeeId}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> managerRemoveTeamMember(
    int teamMemberId,
  ) async {
    final res = await http.post(
      Uri.parse("$baseUrl/manager_remove_team_member.php"),
      headers: headers,
      body: jsonEncode({"team_member_id": teamMemberId}),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> managerRemoveTeam(int teamId) async {
    final res = await http.post(
      Uri.parse("$baseUrl/manager_remove_team.php"),
      headers: headers,
      body: jsonEncode({"team_id": teamId}),
    );

    try {
      return jsonDecode(res.body);
    } catch (_) {
      throw Exception("Server returned non-JSON response:\n${res.body}");
    }
  }

  static Future<List<Map<String, dynamic>>> managerGetFeedbacks() async {
    final res = await http.get(Uri.parse("$baseUrl/manager_get_feedbacks.php"));
    final data = jsonDecode(res.body);
    if (data['status'] == true) {
      return List<Map<String, dynamic>>.from(data['feedbacks'] ?? []);
    }
    throw Exception(data['message'] ?? "Failed to load feedbacks");
  }
}
