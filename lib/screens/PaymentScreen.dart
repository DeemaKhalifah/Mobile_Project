// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import '../styles/strings.dart';
import '../models/customerwallet.dart';
import '../services/api_service.dart';
import 'walletscreen.dart';
import 'CustomerNavigationScreen.dart';
import 'feedbackscreen.dart';
import '../services/shared_preferences_service.dart';

class PaymentScreen extends StatefulWidget {
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
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _customerEmail;

  @override
  void initState() {
    super.initState();
    _loadCustomerEmail();
  }

  Future<void> _loadCustomerEmail() async {
    final email = await SharedPreferencesService.getCustomerEmail();
    setState(() {
      _customerEmail = email ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.primaryLightColor,
      appBar: AppBar(
        title: const Text(AppStrings.payment),
        backgroundColor: AppStyles.primaryVeryDarkColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_balance_wallet),
            onPressed: () {
              if (_customerEmail != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        WalletScreen(customerEmail: _customerEmail!),
                  ),
                );
              }
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
                  widget.serviceName,
                  style: AppStyles.headingStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppStyles.mediumSpacing),
                Text(
                  "Price: \$${widget.price.toStringAsFixed(2)}",
                  style: AppStyles.priceStyle,
                ),
                const SizedBox(height: AppStyles.smallSpacing),
                Text(
                  "Wallet balance: \$${widget.wallet.balance.toStringAsFixed(2)}",
                  style: AppStyles.subtitleStyle.copyWith(fontSize: 18),
                ),
                const SizedBox(height: AppStyles.xlargeSpacing),
                ElevatedButton(
                  style: AppStyles.whiteRoundedButtonStyle,
                  onPressed: () async {
                    if (widget.wallet.pay(widget.price)) {
                      // Update wallet balance in database
                      try {
                        await ApiService.updateWallet(
                          _customerEmail ?? '',
                          widget.wallet.balance,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Payment successful. Remaining: \$${widget.wallet.balance.toStringAsFixed(2)}",
                            ),
                          ),
                        );

                        // Navigate back to CustomerNavigationScreen to show bottom navigation
                        if (_customerEmail != null) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CustomerNavigationScreen(
                                customerEmail: _customerEmail!,
                              ),
                            ),
                            (route) => false, // Remove all previous routes
                          );

                          // Open FeedbackScreen after navigation is complete
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FeedbackScreen(
                                    customerId: widget.customerId,
                                    serviceId: widget.serviceId,
                                  ),
                                ),
                              );
                            }
                          });
                        }
                      } catch (e) {
                        // Revert the payment if database update fails
                        widget.wallet.addMoney(widget.price);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Payment failed: $e")),
                        );
                      }
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
