import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import '../models/customerwallet.dart';
import 'walletscreen.dart';

class WalletSummaryScreen extends StatelessWidget {
  final CustomerWallet wallet;

  const WalletSummaryScreen({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.primaryLightColor,
      appBar: AppBar(
        title: const Text("Wallet"),
        backgroundColor: AppStyles.primaryVeryDarkColor,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppStyles.standardPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppStyles.xlargeSpacing),
                  decoration: AppStyles.balanceBoxDecoration,
                  child: Column(
                    children: [
                      const Text(
                        "Current Balance",
                        style: TextStyle(
                          color: AppStyles.whiteColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppStyles.smallSpacing),
                      Text(
                        "\$${wallet.balance.toStringAsFixed(2)}",
                        style: AppStyles.walletBalanceStyle,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppStyles.xlargeSpacing40),
                ElevatedButton(
                  style: AppStyles.whiteRoundedButtonStyle,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
        builder: (_) => WalletScreen(customerEmail: 'lara@gmail.com'), // pass email
      ),
                    );
                  },
                  child: const Text(
                    "Add Money to Wallet",
                    style: AppStyles.buttonTextStyle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




