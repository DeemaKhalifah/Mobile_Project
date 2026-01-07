// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import '../models/customerwallet.dart';
import 'Customer_main_screen.dart';
import 'CurrentServicesScreen.dart';
import 'WalletSummaryScreen.dart';
import '../services/api_service.dart';

class CustomerNavigationScreen extends StatefulWidget {
  final String customerEmail;

  const CustomerNavigationScreen({
    super.key,
    required this.customerEmail,
  });

  @override
  State<CustomerNavigationScreen> createState() =>
      _CustomerNavigationScreenState();
}

class _CustomerNavigationScreenState extends State<CustomerNavigationScreen> {
  int _currentIndex = 0;
  CustomerWallet? wallet;
  bool isLoadingWallet = true;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    try {
      final loadedWallet = await ApiService.getWallet(widget.customerEmail);
      setState(() {
        wallet = loadedWallet;
        isLoadingWallet = false;
      });
    } catch (e) {
      setState(() {
        isLoadingWallet = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load wallet: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loader if wallet is not yet loaded
    if (isLoadingWallet) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Services: pass customerEmail and wallet
          CustomerMainScreen(
            customerEmail: widget.customerEmail,
            wallet: wallet!, // wallet is now ready
          ),

          // My Bookings
          CurrentServicesScreen(
            customerEmail: widget.customerEmail,
          ),

          // Wallet Summary
          WalletSummaryScreen(
            wallet: wallet!,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppStyles.primaryVeryDarkColor,
        selectedItemColor: AppStyles.whiteColor,
        unselectedItemColor: AppStyles.white70,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'My Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
        ],
      ),
    );
  }
}
