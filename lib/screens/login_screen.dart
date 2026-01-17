// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import '../services/api_service.dart';
import '../services/shared_preferences_service.dart';
import 'signup_screen.dart';
import 'CustomerNavigationScreen.dart';
import 'EmployeeNavigationScreen.dart';
import 'ManagerNavigationScreen.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = "", password = "";

  int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        title: Text("Login (${widget.role})"),
        backgroundColor: AppStyles.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppStyles.standardPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: "Email"),
                onSaved: (val) => email = val!.trim(),
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? "Enter email" : null,
              ),
              const SizedBox(height: AppStyles.mediumSpacing),
              TextFormField(
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                onSaved: (val) => password = val!.trim(),
                validator: (val) => (val == null || val.trim().isEmpty)
                    ? "Enter password"
                    : null,
              ),
              const SizedBox(height: AppStyles.smallSpacing),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: Forget password logic
                  },
                  child: const Text("Forgot Password?"),
                ),
              ),
              const SizedBox(height: AppStyles.largeSpacing),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: AppStyles.primaryButtonStyle,
                  child: const Text("Login"),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    _formKey.currentState!.save();

                    try {
                      final res = await ApiService.login(email, password);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(res['message'] ?? "Done")),
                      );

                      if (res['status'] != true) return;

                      final role = (res['role'] ?? '').toString().toLowerCase();

                      // Save common data
                      await SharedPreferencesService.saveUserRole(role);
                      await SharedPreferencesService.setLoggedIn(true);

                      // Save email based on role (keep your existing keys)
                      if (role == 'employee') {
                        await SharedPreferencesService.saveEmployeeEmail(email);
                      } else {
                        await SharedPreferencesService.saveCustomerEmail(email);
                      }

                      // Save customerId if present (safe parse)
                      final userObj = res['user'];
                      final int? customerId = (userObj is Map<String, dynamic>)
                          ? _toInt(userObj['id'])
                          : null;

                      if (role == 'customer' && customerId != null) {
                        await SharedPreferencesService.saveCustomerId(
                          customerId,
                        );
                      }

                      // Navigate based on role
                      if (role == 'customer') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CustomerNavigationScreen(customerEmail: email),
                          ),
                        );
                      } else if (role == 'employee') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EmployeeNavigationScreen(),
                          ),
                        );
                      } else if (role == 'manager') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ManagerNavigationScreen(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Unknown role: $role")),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Login failed: $e")),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: AppStyles.largeSpacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SignupScreen(role: widget.role),
                        ),
                      );
                    },
                    child: const Text("Sign Up"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
