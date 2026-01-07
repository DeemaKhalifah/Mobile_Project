// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import '../models/customerwallet.dart';
import 'walletscreen.dart';
import 'Customer_main_screen.dart';
import 'feedbackscreen.dart';

class PaymentScreen extends StatelessWidget {
  final String serviceName;
  final double price;
  final CustomerWallet wallet;
  final int customerId;
  final int serviceId;

  const PaymentScreen({
    super.key,
    required this.serviceName,
    required this.price,
    required this.wallet,
    required this.customerId,
    required this.serviceId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.primaryLightColor,
      appBar: AppBar(
        title: const Text("Payment"),
        backgroundColor: AppStyles.primaryVeryDarkColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
        builder: (_) => WalletScreen(customerEmail: 'lara@gmail.com'), // pass email
      ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Card(
          color: AppStyles.blue600,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppStyles.borderRadius25),
          ),
          margin: const EdgeInsets.all(AppStyles.standardPadding),
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.xlargeSpacing),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  serviceName,
                  style: AppStyles.headingStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppStyles.mediumSpacing),
                Text(
                  "Price: \$${price.toStringAsFixed(2)}",
                  style: AppStyles.priceStyle,
                ),
                const SizedBox(height: AppStyles.smallSpacing),
                Text(
                  "Wallet balance: \$${wallet.balance.toStringAsFixed(2)}",
                  style: AppStyles.subtitleStyle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppStyles.xlargeSpacing),
                ElevatedButton(
                  style: AppStyles.whiteRoundedButtonStyle,
                  onPressed: () {
                    if (wallet.pay(price)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              "Payment successful. Remaining: \$${wallet.balance.toStringAsFixed(2)}"),
                        ),
                      );

                      // بعد الدفع: العودة إلى MainScreen ثم فتح FeedbackScreen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CustomerMainScreen(
                            customerEmail: 'lara@gmail.com', // ضع بريد المستخدم إذا عندك
                          ),
                        ),
                      );

                      // افتح FeedbackScreen بعد قليل لضمان أن MainScreen قد تم تحميلها
                      Future.delayed(const Duration(milliseconds: 300), () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FeedbackScreen(
                              customerId: customerId,
                              serviceId: serviceId,
                            ),
                          ),
                        );
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Insufficient balance")),
                      );
                    }
                  },
                  child: const Text("Pay Now"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
