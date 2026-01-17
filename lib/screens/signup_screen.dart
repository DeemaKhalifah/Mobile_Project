import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import '../services/api_service.dart';
import '../services/shared_preferences_service.dart';
import 'CustomerNavigationScreen.dart';
import 'EmployeeNavigationScreen.dart';
import 'ManagerNavigationScreen.dart';

class SignupScreen extends StatefulWidget {
  final String role;
  const SignupScreen({super.key, required this.role});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String password = '';
  String phone = '';
  late String role;

  @override
  void initState() {
    super.initState();
    role = widget.role;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColorAlt,
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: AppStyles.accentColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppStyles.standardPadding16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: AppStyles.smallSpacing),

              TextFormField(
                decoration: AppStyles.standardInputDecoration.copyWith(
                  labelText: "Name",
                ),
                onSaved: (val) => name = val!.trim(),
                validator: (val) =>
                    val!.trim().isEmpty ? "Please enter your name" : null,
              ),

              const SizedBox(height: AppStyles.mediumSpacing),

              TextFormField(
                decoration: AppStyles.standardInputDecoration.copyWith(
                  labelText: "Email",
                ),
                keyboardType: TextInputType.emailAddress,
                onSaved: (val) => email = val!.trim(),
                validator: (val) =>
                    val!.trim().isEmpty ? "Please enter your email" : null,
              ),

              const SizedBox(height: AppStyles.mediumSpacing),

              TextFormField(
                decoration: AppStyles.standardInputDecoration.copyWith(
                  labelText: "Password",
                ),
                obscureText: true,
                onSaved: (val) => password = val!,
                validator: (val) =>
                    val!.isEmpty ? "Please enter your password" : null,
              ),

              const SizedBox(height: AppStyles.mediumSpacing),

              TextFormField(
                decoration: AppStyles.standardInputDecoration.copyWith(
                  labelText: "Phone",
                ),
                keyboardType: TextInputType.phone,
                onSaved: (val) => phone = (val ?? '').trim(),
              ),

              const SizedBox(height: AppStyles.largeSpacing),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: AppStyles.roleBoxDecoration,
                child: Text(
                  "Role: ${role.toUpperCase()}",
                  style: AppStyles.roleTextStyle,
                ),
              ),

              const SizedBox(height: AppStyles.xlargeSpacing),

              ElevatedButton(
                style: AppStyles.accentButtonStyle,
                child: const Text(
                  "Create Account",
                  style: AppStyles.buttonTextStyle16,
                ),
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  _formKey.currentState!.save();

                  try {
                    final res = await ApiService.signup(
                      name,
                      email,
                      password,
                      role,
                      phone,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(res['message'] ?? "Signup result"),
                      ),
                    );

                    if (res['status'] != true) return;

                    final serverRole = (res['role'] ?? role)
                        .toString()
                        .toLowerCase();

                    await SharedPreferencesService.saveUserRole(serverRole);
                    await SharedPreferencesService.setLoggedIn(true);
                    await SharedPreferencesService.saveCustomerEmail(email);

                    if (serverRole == 'employee') {
                      await SharedPreferencesService.saveEmployeeEmail(email);
                    }

                    int? customerId;
                    if (res['customerId'] != null) {
                      customerId = res['customerId'] is int
                          ? res['customerId']
                          : int.tryParse(res['customerId'].toString());
                      if (customerId != null) {
                        await SharedPreferencesService.saveCustomerId(
                          customerId,
                        );
                      }
                    }

                    if (serverRole == 'customer') {
                      // Wallet
                      try {
                        await ApiService.createWallet(
                          email,
                          userId: customerId,
                        );
                      } catch (_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Warning: Wallet creation failed"),
                          ),
                        );
                      }

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CustomerNavigationScreen(customerEmail: email),
                        ),
                      );
                    } else if (serverRole == 'employee') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EmployeeNavigationScreen(),
                        ),
                      );
                    } else if (serverRole == 'manager') {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManagerNavigationScreen(),
                        ),
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Signup failed: $e")),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
