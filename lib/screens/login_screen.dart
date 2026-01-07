// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import '../services/api_service.dart';
import 'signup_screen.dart';
import 'CustomerNavigationScreen.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = "", password = "";

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
                onSaved: (val) => email = val!,
                validator: (val) => val!.isEmpty ? "Enter email" : null,
              ),
              const SizedBox(height: AppStyles.mediumSpacing),
              TextFormField(
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                onSaved: (val) => password = val!,
                validator: (val) => val!.isEmpty ? "Enter password" : null,
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
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      try {
                        final res = await ApiService.login(email, password);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(res['message'])),
                        );

                        if (res['status'] == true) {
                          if (res['role'] == 'customer') {
                            // Navigate to CustomerNavigationScreen
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CustomerNavigationScreen(
                                  customerEmail: email,
                                ),
                              ),
                            );
                          }
                          // Add similar handling for other roles if needed
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Login failed: $e")),
                        );
                      }
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
