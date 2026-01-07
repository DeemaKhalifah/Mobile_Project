import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.primaryColor,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/carwash.png',
              height: AppStyles.imageHeight,
            ),
            const SizedBox(height: AppStyles.xlargeSpacing),
            const Text(
              "Welcome to Car Wash App",
              style: AppStyles.welcomeTitleStyle,
            ),
            const SizedBox(height: AppStyles.xlargeSpacing40),
            _roleButton(context, "Customer"),
            _roleButton(context, "Employee"),
            _roleButton(context, "Manager"),
          ],
        ),
      ),
    );
  }

  Widget _roleButton(BuildContext context, String role) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: AppStyles.whiteButtonStyle,
          child: Text(
            role,
            style: AppStyles.buttonTextStyle,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LoginScreen(role: role.toLowerCase()),
              ),
            );
          },
        ),
      ),
    );
  }
}
