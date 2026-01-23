import 'package:flutter/material.dart';
import '../../styles/app_styles.dart';
import '../../styles/strings.dart';
import '../../services/api_service.dart';
import '../../services/shared_preferences_service.dart';

class ManagerOrderDetailsScreen extends StatefulWidget {
  final int bookingId;
  const ManagerOrderDetailsScreen({super.key, required this.bookingId});

  @override
  State<ManagerOrderDetailsScreen> createState() =>
      _ManagerOrderDetailsScreenState();
}

class _ManagerOrderDetailsScreenState extends State<ManagerOrderDetailsScreen> {
  bool _loading = true;
  String _error = '';
  Map<String, dynamic>? _order;

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _safe(dynamic v) => (v ?? '').toString();

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
      _order = null;
    });

    try {
      final data = await ApiService.managerOrderDetails(widget.bookingId);
      setState(() => _order = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? "-" : value)),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    await SharedPreferencesService.clearAll();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final o = _order;

    return Scaffold(
      backgroundColor: AppStyles.backgroundColorAlt,
      appBar: AppBar(
        backgroundColor: AppStyles.primaryColor,
        title: Text("Order #${widget.bookingId}"),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : o == null
          ? const Center(child: Text(AppStrings.noDataFound))
          : Padding(
              padding: const EdgeInsets.all(AppStyles.standardPadding16),
              child: Card(
                shape: AppStyles.cardShape,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _row("Customer", _safe(o['customer_email'])),
                        _row("Service", _safe(o['service_name'])),
                        _row("Location", _safe(o['location'])),
                        _row("Notes", _safe(o['notes'])),
                        _row("Date", _safe(o['booking_date'])),
                        _row("Time", _safe(o['booking_time'])),
                        _row("Status", _safe(o['status'])),
                        _row("Team", _safe(o['team_name'])),
                        _row("Team Car", _safe(o['car_number_plate'])),
                        _row(
                          "Car",
                          "${_safe(o['car_model'])} • ${_safe(o['car_plate'])}"
                              .trim(),
                        ),

                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 6),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
