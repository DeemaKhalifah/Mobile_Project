import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import '../models/service.dart';
import '../models/customerwallet.dart';
import '../services/api_service.dart';
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
      if (!mounted) return;
      setState(() {
        _wallet = loadedWallet;
        _isLoadingWallet = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingWallet = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load wallet: $e")));
    }
  }

  bool _isHttp(String s) => s.startsWith('http://') || s.startsWith('https://');

  String _serverImageUrl(String filename) {
    final base = ApiService.baseUrl.replaceAll(RegExp(r'\/+$'), '');
    return "$base/uploads/$filename";
  }

  Widget _imageFallback() {
    return Container(
      height: AppStyles.imageHeight,
      width: double.infinity,
      alignment: Alignment.center,
      child: const Icon(Icons.broken_image, size: 48),
    );
  }

  Widget _serviceImage(String rawImage) {
    final img = rawImage.trim();

    if (img.isEmpty) {
      return Container(
        height: AppStyles.imageHeight,
        width: double.infinity,
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported, size: 48),
      );
    }

    // 1) If stored as full URL
    if (_isHttp(img)) {
      return Image.network(
        img,
        height: AppStyles.imageHeight,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imageFallback(),
      );
    }

    // 2) If stored as filename (uploaded to server)
    // Try server first, then fallback to assets for old seeded images.
    final serverUrl = _serverImageUrl(img);
    return Image.network(
      serverUrl,
      height: AppStyles.imageHeight,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        // 3) Fallback to local assets (for images that ship with the app)
        return Image.asset(
          "assets/images/$img",
          height: AppStyles.imageHeight,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _imageFallback(),
        );
      },
    );
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
            _serviceImage(widget.service.image),
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
