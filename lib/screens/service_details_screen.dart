import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import '../models/service.dart';
import '../models/customerwallet.dart';
import 'bookingform.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final Service service;
  final CustomerWallet wallet;
  final String customerEmail;

  const ServiceDetailsScreen({
    super.key,
    required this.service,
    required this.wallet,
    required this.customerEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.primaryColor,
      appBar: AppBar(
        title: Text(service.name),
        backgroundColor: AppStyles.primaryVeryDarkColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppStyles.standardPadding16),
        child: Column(
          children: [
            Image.asset(
              "assets/images/${service.image.trim()}",
              height: AppStyles.imageHeight,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: AppStyles.largeSpacing),
            Text(service.name, style: AppStyles.headingStyle),
            const SizedBox(height: AppStyles.smallSpacing),
            Text("\$${service.price}", style: AppStyles.subtitleStyle),
            const SizedBox(height: AppStyles.xlargeSpacing),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => BookingForm(
                    service: service,
                    wallet: wallet,
                    customerEmail: customerEmail,
                  ),
                );
              },
              child: const Text("Book Service"),
            ),
          ],
        ),
      ),
    );
  }
}
