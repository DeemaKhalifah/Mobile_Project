import 'package:flutter/material.dart';
import '../../styles/app_styles.dart';
import '../../styles/strings.dart';
import '../../services/api_service.dart';
import '../../services/shared_preferences_service.dart';

class ManagerFeedbackScreen extends StatefulWidget {
  const ManagerFeedbackScreen({super.key});

  @override
  State<ManagerFeedbackScreen> createState() => _ManagerFeedbackScreenState();
}

class _ManagerFeedbackScreenState extends State<ManagerFeedbackScreen> {
  bool _loading = true;
  String _error = '';
  List<Map<String, dynamic>> _feedbacks = [];

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
      final data = await ApiService.managerGetFeedbacks();
      setState(() => _feedbacks = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
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
        title: const Text(AppStrings.feedback),

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
          : _feedbacks.isEmpty
          ? const Center(child: Text(AppStrings.noDataFound))
          : ListView.builder(
              padding: const EdgeInsets.all(AppStyles.standardPadding16),
              itemCount: _feedbacks.length,
              itemBuilder: (_, i) {
                final f = _feedbacks[i];
                final rating = _safe(f['rating']);
                return Card(
                  shape: AppStyles.cardShape,
                  child: ListTile(
                    title: Text("${_safe(f['service_name'])}  •  ⭐ $rating"),
                    subtitle: Text(
                      "${_safe(f['customer_email'])}\n${_safe(f['comment'])}",
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
