// current_services_screen.dart
import 'package:flutter/material.dart';
import '../styles/app_styles.dart';
import '../models/booking.dart';
import '../models/customerwallet.dart';
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

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    bookingsFuture = ApiService.getCustomerBookings(widget.customerEmail);
  }

  Future<void> _cancelBooking(int id) async {
    final result = await ApiService.cancelBooking(id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? "Booking canceled")),
    );

    setState(_loadBookings);
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
                            onPressed: () => _cancelBooking(booking.id!),
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
