import 'package:flutter/material.dart';
import '../../styles/app_styles.dart';
import '../../services/api_service.dart';
import '../../services/shared_preferences_service.dart';
import 'ManagerTeamDetailsScreen.dart';

class ManagerTeamsScreen extends StatefulWidget {
  const ManagerTeamsScreen({super.key});

  @override
  State<ManagerTeamsScreen> createState() => _ManagerTeamsScreenState();
}

class _ManagerTeamsScreenState extends State<ManagerTeamsScreen> {
  bool _loading = true;
  String _error = '';
  List<Map<String, dynamic>> _teams = [];

  static const Color babyBlue = Color(0xFF89CFF0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _safe(dynamic v) => (v ?? '').toString();

  int _teamId(Map<String, dynamic> t) {
    final v = t['team_id'] ?? t['id'];
    return int.tryParse(_safe(v)) ?? 0;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final data = await ApiService.managerGetTeams();
      setState(() => _teams = data);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addTeamDialog() async {
    final nameCtrl = TextEditingController();
    final carPlateCtrl = TextEditingController();

    List<Map<String, dynamic>> available = [];
    try {
      available = await ApiService.managerGetAvailableEmployees();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load employees: $e")));
      return;
    }

    int? selectedEmpId;

    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: const Text("Add Team"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: "Team Name",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<int>(
                  initialValue: selectedEmpId,
                  items: available
                      .map((e) {
                        final id =
                            int.tryParse((e['id'] ?? '').toString()) ?? 0;
                        final name = (e['name'] ?? '').toString();
                        final email = (e['email'] ?? '').toString();
                        if (id <= 0) return null;
                        return DropdownMenuItem<int>(
                          value: id,
                          child: Text("$name ($email)"),
                        );
                      })
                      .whereType<DropdownMenuItem<int>>()
                      .toList(),
                  onChanged: available.isEmpty
                      ? null
                      : (v) => setDialogState(() => selectedEmpId = v),
                  decoration: const InputDecoration(
                    labelText: "Leader Employee",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),
                TextField(
                  controller: carPlateCtrl,
                  decoration: const InputDecoration(
                    labelText: "Car Number Plate",
                    border: OutlineInputBorder(),
                  ),
                ),

                if (available.isEmpty) ...[
                  const SizedBox(height: 8),
                  const Text(
                    "No available employees (all employees already assigned).",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: AppStyles.primaryButtonStyleRounded,
              onPressed: available.isEmpty
                  ? null
                  : () async {
                      final teamName = nameCtrl.text.trim();
                      final carPlate = carPlateCtrl.text.trim();
                      final employeeId = selectedEmpId;

                      if (teamName.isEmpty ||
                          carPlate.isEmpty ||
                          employeeId == null ||
                          employeeId <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Fill all fields correctly"),
                          ),
                        );
                        return;
                      }

                      try {
                        final res = await ApiService.managerAddTeam(
                          teamName,
                          employeeId,
                          carPlate,
                        );

                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              _safe(res['message']).isEmpty
                                  ? "Team added"
                                  : _safe(res['message']),
                            ),
                          ),
                        );

                        Navigator.pop(dialogCtx);
                        _load();
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Failed: $e")));
                      }
                    },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openTeamDetails(Map<String, dynamic> team) async {
    final refreshed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ManagerTeamDetailsScreen(team: team)),
    );

    if (refreshed == true) {
      _load();
    }
  }

  Future<void> _logout() async {
    // 1) Show confirm dialog
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Logout"),
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
        title: const Text("Manager - Teams"),

        automaticallyImplyLeading: false,
        leading: const SizedBox.shrink(),

        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: babyBlue,
        onPressed: _addTeamDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
          ? Center(child: Text(_error))
          : _teams.isEmpty
          ? const Center(child: Text("No teams found"))
          : ListView.builder(
              padding: const EdgeInsets.all(AppStyles.standardPadding16),
              itemCount: _teams.length,
              itemBuilder: (_, i) {
                final t = _teams[i];
                final tid = _teamId(t);

                final teamName = _safe(t['team_name']);
                final leaderName = _safe(t['leader_name']);
                final leaderEmail = _safe(t['leader_email']);
                final carPlate = _safe(t['car_number_plate']);

                return Card(
                  shape: AppStyles.cardShape,
                  child: ListTile(
                    onTap: tid == 0 ? null : () => _openTeamDetails(t),
                    title: Text(
                      teamName.isEmpty ? "Team" : teamName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          "Leader: ${leaderName.isEmpty ? 'Not assigned' : leaderName}"
                          "${leaderEmail.isEmpty ? '' : ' ($leaderEmail)'}",
                        ),
                        Text(
                          "Car Number: ${carPlate.isEmpty ? '-' : carPlate}",
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
    );
  }
}
