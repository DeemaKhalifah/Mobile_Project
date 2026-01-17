import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/shared_preferences_service.dart';
import '../../styles/app_styles.dart';

class EmployeeOrderDetailsScreen extends StatefulWidget {
  final int bookingId;
  const EmployeeOrderDetailsScreen({super.key, required this.bookingId});

  @override
  State<EmployeeOrderDetailsScreen> createState() =>
      _EmployeeOrderDetailsScreenState();
}

class _EmployeeOrderDetailsScreenState
    extends State<EmployeeOrderDetailsScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _order;

  String? _employeeEmail;

  final List<String> _allowedStatuses = ['assigned', 'completed'];

  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    final email = await SharedPreferencesService.getEmployeeEmail();
    if (!mounted) return;

    if (email == null || email.isEmpty) {
      setState(() {
        _employeeEmail = null;
        _loading = false;
        _error = "Employee email not found. Please login again.";
      });
      return;
    }

    setState(() => _employeeEmail = email);
    await _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final email = await SharedPreferencesService.getEmployeeEmail();
      if (email == null || email.isEmpty) {
        throw Exception("Employee email missing, login again.");
      }
      final data = await ApiService.getEmployeeOrderDetails(
        email,
        widget.bookingId,
      );
      setState(() => _order = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _setStatus(String status) async {
    try {
      final email = _employeeEmail;
      if (email == null) throw Exception("Employee email missing");

      final res = await ApiService.updateOrderStatus(
        email,
        widget.bookingId,
        status,
      );

      if (res['status'] == true) {
        await _load();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['message'] ?? "Status updated to $status"),
            ),
          );
        }
      } else {
        throw Exception(res['message'] ?? "Failed");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = _order;
    final currentStatus = (o?['status'] ?? '').toString();

    return Scaffold(
      backgroundColor: AppStyles.backgroundColorAlt,
      appBar: AppBar(
        backgroundColor: AppStyles.primaryColor,
        title: Text("Order #${widget.bookingId}"),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : o == null
          ? const Center(child: Text("No data"))
          : ListView(
              padding: const EdgeInsets.all(AppStyles.standardPadding16),
              children: [
                Card(
                  shape: AppStyles.cardShape,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _infoRow("Customer", o['customer_email'] ?? ''),
                        _infoRow("Service", o['service_name'] ?? ''),
                        _infoRow(
                          "Date",
                          "${o['booking_date'] ?? ''}  ${o['booking_time'] ?? ''}",
                        ),
                        _infoRow("Location", o['location'] ?? ''),
                        _infoRow("Notes", o['notes'] ?? ''),
                        const Divider(height: 24),
                        _infoRow(
                          "Car",
                          "${o['car_model'] ?? '-'} | ${o['car_plate'] ?? '-'}",
                        ),
                        _infoRow(
                          "Team",
                          "${o['team_name'] ?? '-'} (${o['car_number_plate'] ?? '-'})",
                        ),
                        const Divider(height: 24),
                        _infoRow("Current Status", currentStatus),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                if (currentStatus != 'completed' &&
                    currentStatus != 'cancelled') ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: AppStyles.primaryButtonStyleRounded,
                          onPressed: () => _setStatus('assigned'),
                          icon: const Icon(Icons.check),
                          label: const Text("Accept"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _setStatus('rejected'),
                          icon: const Icon(Icons.close),
                          label: const Text("Reject"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Card(
                    shape: AppStyles.cardShape,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: DropdownButtonFormField<String>(
                        initialValue: _allowedStatuses.contains(currentStatus)
                            ? currentStatus
                            : 'assigned',
                        items: _allowedStatuses
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(s.toUpperCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) _setStatus(v);
                        },
                        decoration: AppStyles.filledInputDecoration.copyWith(
                          labelText: "Change status",
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _infoRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$title:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value?.toString() ?? "")),
        ],
      ),
    );
  }
}
