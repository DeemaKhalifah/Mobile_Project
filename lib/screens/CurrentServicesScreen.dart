// current_services_screen.dart
import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import '../models/booking.dart';
import '../models/customerwallet.dart';
import '../models/service.dart';
import '../services/api_service.dart';
import 'BookingForm.dart';

class CurrentServicesScreen extends StatefulWidget {
  final String customerEmail;

  const CurrentServicesScreen({super.key, required this.customerEmail});

  @override
  State<CurrentServicesScreen> createState() => _CurrentServicesScreenState();
}

class _CurrentServicesScreenState extends State<CurrentServicesScreen> {
  late Future<List<Booking>> bookingsFuture;
  late Future<List<Service>> servicesFuture;

  @override
  void initState() {
    super.initState();
    _loadBookings();
    servicesFuture = ApiService.getServices();
  }

  void _loadBookings() {
    bookingsFuture = ApiService.getCustomerBookings(widget.customerEmail);
  }

  Future<double?> _getServicePrice(String serviceName) async {
    try {
      final services = await servicesFuture;
      final service = services.firstWhere(
        (s) => s.name == serviceName,
        orElse: () => Service(
          id: 0,
          name: '',
          price: 0.0,
          image: '',
          description: '',
        ),
      );
      return service.price > 0 ? service.price : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _cancelBooking(int id, String serviceName) async {
    // Get service price for refund
    final servicePrice = await _getServicePrice(serviceName);
    
    if (servicePrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not determine service price for refund")),
      );
      return;
    }

    try {
      // Cancel the booking
      final result = await ApiService.cancelBooking(id, widget.customerEmail, servicePrice);

      // Explicitly refund money to wallet to ensure it's updated in database
      try {
        await ApiService.refundToWallet(widget.customerEmail, servicePrice);
      } catch (refundError) {
        // If explicit refund fails, log but don't block - backend might have already handled it
        print("Warning: Explicit refund failed: $refundError");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ?? "Booking canceled. Refund of \$${servicePrice.toStringAsFixed(2)} has been processed.",
          ),
          duration: const Duration(seconds: 3),
        ),
      );

      setState(_loadBookings);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error canceling booking: $e")),
      );
    }
  }


  Future<void> _updateBooking(Booking booking) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BookingForm(
          isUpdate: true,
          existingBooking: booking,
          customerEmail: widget.customerEmail,
          wallet: CustomerWallet(
            cardNumber: "",
            cardHolder: "",
            expiryDate: "",
            cvv: "",
            balance: 0,
          ),
        ),
      ),
    );

    if (updated == true) setState(_loadBookings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Bookings")),
      body: FutureBuilder<List<Booking>>(
        future: bookingsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final bookings = snapshot.data!;

          if (bookings.isEmpty) {
            return const Center(child: Text("No bookings yet"));
          }

          return ListView.builder(
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];

              return Card(
                margin: const EdgeInsets.all(10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.serviceName,
                          style: AppStyles.serviceNameStyle),
                      Text("📍 ${booking.location}"),
                      Text("📅 ${booking.bookingDate}"),
                      Text("⏰ ${booking.bookingTime}"),
                      if (booking.notes.isNotEmpty)
                        Text("📝 ${booking.notes}"),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _updateBooking(booking),
                            child: const Text("Update"),
                          ),
                          TextButton(
                            onPressed: () => _cancelBooking(booking.id!, booking.serviceName),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}