import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import '../models/customerwallet.dart';
import '../services/api_service.dart';
import 'walletscreen.dart';

class WalletSummaryScreen extends StatefulWidget {
  final String customerEmail;

  const WalletSummaryScreen({super.key, required this.customerEmail});

  @override
  State<WalletSummaryScreen> createState() => _WalletSummaryScreenState();
}

class _WalletSummaryScreenState extends State<WalletSummaryScreen> {
  CustomerWallet? _currentWallet;
  bool _isRefreshing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshWallet();
  }

  Future<void> _refreshWallet() async {
    setState(() {
      _isRefreshing = true;
      _isLoading = true;
    });

    try {
      final refreshedWallet = await ApiService.getWallet(widget.customerEmail);
      setState(() {
        _currentWallet = refreshedWallet;
        _isRefreshing = false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isRefreshing = false;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load wallet: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppStyles.primaryLightColor,
      appBar: AppBar(
        title: const Text("Wallet"),
        backgroundColor: AppStyles.primaryVeryDarkColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Balance',
            onPressed: _refreshWallet,
          ),
        ],
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
                      _isRefreshing
                          ? const CircularProgressIndicator(
                              color: AppStyles.whiteColor)
                          : Text(
                              "\$${_currentWallet?.balance.toStringAsFixed(2) ?? '0.00'}",
                              style: AppStyles.walletBalanceStyle,
                              textAlign: TextAlign.center,
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: AppStyles.xlargeSpacing40),
                ElevatedButton(
                  style: AppStyles.whiteRoundedButtonStyle,
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WalletScreen(
                            customerEmail: widget.customerEmail),
                      ),
                    );
                    // Refresh wallet after returning from WalletScreen
                    _refreshWallet();
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
