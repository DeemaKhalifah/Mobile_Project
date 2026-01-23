import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/shared_preferences_service.dart';
import '../../styles/app_styles.dart';
import '../../styles/strings.dart';
import 'EmployeeOrderDetailsScreen.dart';

class EmployeeOrdersScreen extends StatefulWidget {
  const EmployeeOrdersScreen({super.key});

  @override
  State<EmployeeOrdersScreen> createState() => _EmployeeOrdersScreenState();
}

class _EmployeeOrdersScreenState extends State<EmployeeOrdersScreen> {
  bool _loading = true;
  String? _error;
  String _statusFilter = ''; // all
  List<Map<String, dynamic>> _orders = [];

  final List<String> _statuses = [
    '', // all
    'pending',
    'assigned',
    'accepted',
    'rejected',
    'in_progress',
    'completed',
    'cancelled',
  ];

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final email = await SharedPreferencesService.getEmployeeEmail();
      if (email == null || email.isEmpty) {
        throw Exception("No employee email found. Please login again.");
      }

      final orders = await ApiService.getEmployeeOrders(
        email,
        status: _statusFilter.isEmpty ? null : _statusFilter,
      );

      setState(() {
        _orders = orders;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  String _prettyStatus(String s) {
    if (s.isEmpty) return "ALL";
    return s.replaceAll('_', ' ').toUpperCase();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return AppStyles.primaryColor;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'in_progress':
        return Colors.purple;
      case 'completed':
        return Colors.teal;
      case 'cancelled':
        return Colors.grey;
      default:
        return AppStyles.greyColor;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColorAlt,
      appBar: AppBar(
        backgroundColor: AppStyles.primaryColor,
        title: const Text(AppStrings.employeeOrders),
        actions: [
          IconButton(onPressed: _loadOrders, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppStyles.standardPadding16),
            child: DropdownButtonFormField<String>(
              initialValue: _statusFilter,
              items: _statuses
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(_prettyStatus(s)),
                    ),
                  )
                  .toList(),
              onChanged: (v) {
                setState(() => _statusFilter = v ?? '');
                _loadOrders();
              },
              decoration: AppStyles.filledInputDecoration.copyWith(
                labelText: AppStrings.filterByStatus,
              ),
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text(_error!))
                : _orders.isEmpty
                ? const Center(child: Text("No orders found"))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppStyles.standardPadding16,
                      vertical: 8,
                    ),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final o = _orders[index];

                      final id = o['id'].toString();
                      final service = (o['service_name'] ?? '').toString();
                      final date = (o['booking_date'] ?? '').toString();
                      final time = (o['booking_time'] ?? '').toString();
                      final status = (o['status'] ?? '').toString();
                      final location = (o['location'] ?? '').toString();

                      final carModel = (o['car_model'] ?? '-').toString();
                      final carPlate = (o['car_plate'] ?? '-').toString();

                      return Card(
                        shape: AppStyles.cardShape,
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () async {
                            final changed = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EmployeeOrderDetailsScreen(
                                  bookingId: int.parse(id),
                                ),
                              ),
                            );
                            if (changed == true) {
                              _loadOrders();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        service,
                                        style: AppStyles.titleStyle,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _statusColor(
                                          status,
                                        ).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _prettyStatus(status),
                                        style: TextStyle(
                                          color: _statusColor(status),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text("📅 $date  ⏰ $time"),
                                const SizedBox(height: 6),
                                Text("📍 $location"),
                                const SizedBox(height: 6),
                                Text("🚗 $carModel  |  $carPlate"),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
