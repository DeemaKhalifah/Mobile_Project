import 'package:flutter/material.dart';
import '../../styles/app_styles.dart';
import '../../styles/strings.dart';
import '../../services/api_service.dart';
import '../../services/shared_preferences_service.dart';
import 'ManagerOrderDetailsScreen.dart';

class ManagerOrdersScreen extends StatefulWidget {
  const ManagerOrdersScreen({super.key});

  @override
  State<ManagerOrdersScreen> createState() => _ManagerOrdersScreenState();
}

class _ManagerOrdersScreenState extends State<ManagerOrdersScreen> {
  bool _loading = true;
  String _error = '';
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final data = await ApiService.managerGetOrders();
      setState(() => _orders = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _safe(dynamic v) => (v ?? '').toString();

  Future<void> _logout() async {
    // 1) Show confirm dialog
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(AppStrings.logout),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
    );

    if (confirm != true) return; // Cancel

    // 2) Do logout
    await SharedPreferencesService.clearAll();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColorAlt,
      appBar: AppBar(
        backgroundColor: AppStyles.primaryColor,
        title: const Text(AppStrings.orders),
        automaticallyImplyLeading: false,
        leading: const SizedBox.shrink(),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
          // IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : _orders.isEmpty
          ? const Center(child: Text(AppStrings.noDataFound))
          : ListView.builder(
              padding: const EdgeInsets.all(AppStyles.standardPadding16),
              itemCount: _orders.length,
              itemBuilder: (_, i) {
                final o = _orders[i];

                final id = int.tryParse(_safe(o['id'])) ?? 0;
                final status = _safe(o['status']);
                final service = _safe(o['service_name']);
                final email = _safe(o['customer_email']);
                final date = _safe(o['booking_date']);
                final time = _safe(o['booking_time']);

                final rawTeam = _safe(o['team_name']);
                final team = rawTeam.isEmpty ? AppStrings.status : rawTeam;

                return Card(
                  shape: AppStyles.cardShape,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    title: Text(
                      "#$id • $service",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$date  $time • Team: $team",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    isThreeLine: true,
                    trailing: Chip(
                      label: Text(status.isEmpty ? "unknown" : status),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ManagerOrderDetailsScreen(bookingId: id),
                        ),
                      ).then((_) => _load());
                    },
                  ),
                );
              },
            ),
    );
  }
}
