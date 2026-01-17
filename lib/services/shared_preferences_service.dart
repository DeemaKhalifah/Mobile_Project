// ignore_for_file: file_names

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String _keyCustomerEmail = 'customer_email';
  static const String _keyCustomerId = 'customer_id';
  static const String _keyUserRole = 'user_role';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyEmployeeEmail = 'employee_email';

  // Save customer email
  static Future<void> saveCustomerEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCustomerEmail, email);
  }

  // Get customer email
  static Future<String?> getCustomerEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCustomerEmail);
  }

  // Save customer ID
  static Future<void> saveCustomerId(int customerId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCustomerId, customerId);
  }

  // Get customer ID
  static Future<int?> getCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCustomerId);
  }

  // Save employee email
  static Future<void> saveEmployeeEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmployeeEmail, email);
  }

  // Get employee email
  static Future<String?> getEmployeeEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmployeeEmail);
  }

  // Save user role
  static Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserRole, role);
  }

  // Get user role
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole);
  }

  // Save login status
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, isLoggedIn);
  }

  // Get login status
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // Clear all preferences (logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
