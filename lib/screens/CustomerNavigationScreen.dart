// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import '../services/shared_preferences_service.dart';
import 'Customer_main_screen.dart';
import 'CurrentServicesScreen.dart';
import 'WalletSummaryScreen.dart';
import '../services/api_service.dart';
import 'welcome_screen.dart';

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
  bool _isLoadingWallet = true;

  @override
  void initState() {
    super.initState();
    _loadWallet(); // Preload wallet to show loading indicator
  }

  // This function ensures wallet is preloaded so balance is up-to-date
  Future<void> _loadWallet() async {
    setState(() {
      _isLoadingWallet = true;
    });

    try {
      await ApiService.getWallet(widget.customerEmail); // Fetch wallet but we don't need to store it
    } catch (e) {
      // Ignore errors here, screens will handle it individually
    }

    setState(() {
      _isLoadingWallet = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingWallet) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyles.primaryVeryDarkColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirmed == true) {
                await SharedPreferencesService.clearAll();
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (route) => false,
                  );
                }
              }
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Services screen
          CustomerMainScreen(
            customerEmail: widget.customerEmail,
          ),

          // My Bookings screen
          CurrentServicesScreen(
            customerEmail: widget.customerEmail,
          ),

          // Wallet Summary screen
          WalletSummaryScreen(
            customerEmail: widget.customerEmail,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          // Reload wallet when switching to wallet tab
          if (index == 2) _loadWallet();
        },
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
