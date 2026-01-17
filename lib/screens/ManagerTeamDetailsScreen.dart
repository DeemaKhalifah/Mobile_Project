import 'package:flutter/material.dart';
import '../../styles/app_styles.dart';
import '../../services/api_service.dart';

class ManagerTeamDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> team;
  const ManagerTeamDetailsScreen({super.key, required this.team});

  @override
  State<ManagerTeamDetailsScreen> createState() =>
      _ManagerTeamDetailsScreenState();
}

class _ManagerTeamDetailsScreenState extends State<ManagerTeamDetailsScreen> {
  String _safe(dynamic v) => (v ?? '').toString();
  int? _toInt(dynamic v) => v == null ? null : int.tryParse(v.toString());

  bool _loading = true;
  String _error = '';

  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> _available = [];

  int? _selectedEmployeeId;
  bool _saving = false;

  bool _changed = false;

  int _teamId() {
    final v = widget.team['team_id'] ?? widget.team['id'];
    return int.tryParse(_safe(v)) ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final teamId = _teamId();
    if (teamId == 0) {
      setState(() {
        _loading = false;
        _error = "Invalid team id";
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final members = await ApiService.managerGetTeamMembers(teamId);
      final available = await ApiService.managerGetAvailableEmployees();

      setState(() {
        _members = members;
        _available = available;

        if (_selectedEmployeeId != null &&
            !_available.any((e) => _toInt(e['id']) == _selectedEmployeeId)) {
          _selectedEmployeeId = null;
        }
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _addMember() async {
    final teamId = _teamId();
    final empId = _selectedEmployeeId;

    if (teamId == 0 || empId == null) return;

    if (_members.length >= 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Team already has 4 employees")),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final res = await ApiService.managerAddTeamMember(teamId, empId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _safe(res['message']).isEmpty ? "Added" : _safe(res['message']),
          ),
        ),
      );

      _changed = true;
      await _loadAll();
      if (mounted) setState(() => _selectedEmployeeId = null);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: $e")));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _removeMember(int teamMemberId) async {
    setState(() => _saving = true);
    try {
      final res = await ApiService.managerRemoveTeamMember(teamMemberId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _safe(res['message']).isEmpty ? "Removed" : _safe(res['message']),
          ),
        ),
      );

      _changed = true;
      await _loadAll();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: $e")));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _removeTeam() async {
    final teamId = _teamId();
    if (teamId == 0) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Team"),
        content: const Text(
          "Are you sure you want to delete this team?\nThis action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: AppStyles.primaryButtonStyleRounded,
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => _saving = true);
    try {
      final res = await ApiService.managerRemoveTeam(teamId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _safe(res['message']).isEmpty
                ? "Team deleted"
                : _safe(res['message']),
          ),
        ),
      );

      // go back & refresh teams screen
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: $e")));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.team;
    final teamName = _safe(t['team_name']);
    final carPlate = _safe(t['car_number_plate']);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _changed);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppStyles.backgroundColorAlt,
        appBar: AppBar(
          backgroundColor: AppStyles.primaryColor,
          title: const Text("Team Details"),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error.isNotEmpty
            ? Center(child: Text(_error))
            : Padding(
                padding: const EdgeInsets.all(AppStyles.standardPadding16),
                child: Card(
                  shape: AppStyles.cardShape,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ListView(
                      children: [
                        Text(
                          teamName.isEmpty ? "Team" : teamName,
                          style: AppStyles.titleStyle,
                        ),
                        const SizedBox(height: 8),
                        Text("Car Plate: $carPlate"),
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Team Members",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("${_members.length}/4"),
                          ],
                        ),
                        const SizedBox(height: 8),

                        if (_members.isEmpty)
                          const Text("No members in this team yet.")
                        else
                          ..._members.map((m) {
                            final tmId = _toInt(m['team_member_id']) ?? 0;
                            final name = _safe(m['name']);
                            final email = _safe(m['email']);

                            return Card(
                              shape: AppStyles.cardShape,
                              child: ListTile(
                                title: Text(name.isEmpty ? "Employee" : name),
                                subtitle: Text(email),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle),
                                  onPressed: (_saving || tmId == 0)
                                      ? null
                                      : () => _removeMember(tmId),
                                ),
                              ),
                            );
                          }),

                        const SizedBox(height: 20),

                        const Text(
                          "Add Employee",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        DropdownButtonFormField<int>(
                          initialValue: _selectedEmployeeId,
                          items: _available
                              .where((e) => (_toInt(e['id']) ?? 0) > 0)
                              .map((e) {
                                final id = _toInt(e['id'])!;
                                final name = _safe(e['name']);
                                final email = _safe(e['email']);
                                return DropdownMenuItem<int>(
                                  value: id,
                                  child: Text("$name  ($email)"),
                                );
                              })
                              .toList(),
                          onChanged: (_saving || _available.isEmpty)
                              ? null
                              : (v) => setState(() => _selectedEmployeeId = v),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Select employee",
                          ),
                        ),

                        const SizedBox(height: 12),

                        ElevatedButton.icon(
                          style: AppStyles.primaryButtonStyleRounded,
                          onPressed:
                              (_saving ||
                                  _selectedEmployeeId == null ||
                                  _members.length >= 4 ||
                                  _available.isEmpty)
                              ? null
                              : _addMember,
                          icon: const Icon(Icons.person_add),
                          label: Text(
                            _members.length >= 4
                                ? "Team is full (4)"
                                : _saving
                                ? "Saving..."
                                : "Add to Team",
                          ),
                        ),

                        const SizedBox(height: 8),
                        if (_available.isEmpty)
                          const Text(
                            "No available employees (all employees are already assigned).",
                            style: TextStyle(fontSize: 12),
                          ),

                        const SizedBox(height: 24),
                        const Divider(),
                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _saving ? null : _removeTeam,
                            icon: const Icon(Icons.delete, color: Colors.white),
                            label: Text(
                              _saving ? "Please wait..." : "Delete",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              disabledBackgroundColor: Colors.red.shade200,
                              elevation: 6,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                          ),
                        ),
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
