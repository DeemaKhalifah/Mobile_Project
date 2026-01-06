import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import '../models/service.dart';
import '../models/customerwallet.dart';
import '../services/api_service.dart';
import '../services/shared_preferences_service.dart';
import 'bookingform.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final Service service;
  final String customerEmail;

  const ServiceDetailsScreen({
    super.key,
    required this.service,
    required this.customerEmail,
  });

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  CustomerWallet? _wallet;
  bool _isLoadingWallet = true;

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    try {
      final loadedWallet = await ApiService.getWallet(widget.customerEmail);
      setState(() {
        _wallet = loadedWallet;
        _isLoadingWallet = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingWallet = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load wallet: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.primaryColor,
      appBar: AppBar(
        title: Text(widget.service.name),
        backgroundColor: AppStyles.primaryVeryDarkColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppStyles.standardPadding16),
        child: Column(
          children: [
            Image.asset(
              "assets/images/${widget.service.image.trim()}",
              height: AppStyles.imageHeight,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: AppStyles.largeSpacing),
            Text(widget.service.name, style: AppStyles.headingStyle),
            const SizedBox(height: AppStyles.smallSpacing),
            Text("\$${widget.service.price}", style: AppStyles.subtitleStyle),
            const SizedBox(height: AppStyles.xlargeSpacing),
            _isLoadingWallet
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _wallet == null
                        ? null
                        : () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => BookingForm(
                                service: widget.service,
                                wallet: _wallet!,
                                customerEmail: widget.customerEmail,
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
