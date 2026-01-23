import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import '../styles/strings.dart';
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
              AppStrings.welcomeTitle,
              style: AppStyles.welcomeTitleStyle,
            ),
            const SizedBox(height: AppStyles.xlargeSpacing40),
            _roleButton(context, AppStrings.customer),
            _roleButton(context, AppStrings.employee),
            _roleButton(context, AppStrings.manager),
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
          child: Text(role, style: AppStyles.buttonTextStyle),
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
