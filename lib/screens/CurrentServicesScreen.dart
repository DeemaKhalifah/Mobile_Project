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
    } catch (_) {
      return null;
    }
  }

  // ================= STATUS HELPERS (FIXED) =================

  String _normStatus(String? s) {
    final v = (s ?? '').trim().toLowerCase();

    if (v.isEmpty) return 'unknown';

    // normalize all cancel variants
    if (v == 'cancelled' || v == 'canceled' || v == 'cancel') {
      return 'canceled';
    }

    return v;
  }

  String _statusLabel(String s) {
    switch (_normStatus(s)) {
      case 'pending':
        return 'Pending';
      case 'assigned':
        return 'Assigned';
      case 'completed':
        return 'Completed';
      case 'rejected':
        return 'Rejected';
      case 'canceled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  Color _statusColor(String s) {
    switch (_normStatus(s)) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'canceled':
        return Colors.grey;
      default:
        return Colors.black54;
    }
  }

  bool _isFinalStatus(String s) {
    final v = _normStatus(s);
    return v == 'completed' || v == 'rejected' || v == 'canceled';
  }

  Widget _statusChip(String? status) {
    final s = _normStatus(status);
    final label = _statusLabel(s);
    final color = _statusColor(s);

    return Chip(
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
  }

  // ==========================================================

  Future<void> _cancelBooking(int id, String serviceName) async {
    final servicePrice = await _getServicePrice(serviceName);

    if (servicePrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not determine service price for refund")),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Cancel booking"),
        content: const Text("Are you sure you want to cancel this booking?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes, cancel"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      final result = await ApiService.cancelBooking(
        id,
        widget.customerEmail,
        servicePrice,
      );

      try {
        await ApiService.refundToWallet(widget.customerEmail, servicePrice);
      } catch (_) {}

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message'] ??
                "Booking cancelled. Refund \$${servicePrice.toStringAsFixed(2)} processed.",
          ),
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

    if (updated == true) {
      setState(_loadBookings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Bookings")),
      body: FutureBuilder<List<Booking>>(
        future: bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final bookings = snapshot.data ?? [];

          if (bookings.isEmpty) {
            return const Center(child: Text("No bookings yet"));
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(_loadBookings);
              await bookingsFuture;
            },
            child: ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final status = booking.status;
                final isFinal = _isFinalStatus(status);

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                booking.serviceName,
                                style: AppStyles.serviceNameStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _statusChip(status),
                          ],
                        ),
                        const SizedBox(height: 6),
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
                              onPressed:
                                  isFinal ? null : () => _updateBooking(booking),
                              child: const Text("Update"),
                            ),
                            TextButton(
                              onPressed: isFinal
                                  ? null
                                  : () => _cancelBooking(
                                        booking.id!,
                                        booking.serviceName,
                                      ),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
