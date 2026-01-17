import 'package:flutter/material.dart';
import '../../styles/app_styles.dart';
import '../../services/shared_preferences_service.dart';
import 'login_screen.dart';
import 'EmployeeOrdersScreen.dart';

class EmployeeNavigationScreen extends StatefulWidget {
  const EmployeeNavigationScreen({super.key});

  @override
  State<EmployeeNavigationScreen> createState() =>
      _EmployeeNavigationScreenState();
}

class _EmployeeNavigationScreenState extends State<EmployeeNavigationScreen> {
  int _index = 0;

  final List<Widget> _pages = const [
    EmployeeOrdersScreen(),
    _EmployeeProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: AppStyles.primaryColor,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Orders"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class _EmployeeProfileScreen extends StatefulWidget {
  const _EmployeeProfileScreen();

  @override
  State<_EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<_EmployeeProfileScreen> {
  String _email = '';
  String _role = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final email = await SharedPreferencesService.getEmployeeEmail();
    final role = await SharedPreferencesService.getUserRole();
    setState(() {
      _email = email ?? '';
      _role = role ?? '';
    });
  }

  Future<void> _logout() async {
    await SharedPreferencesService.clearAll();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen(role: "employee")),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColorAlt,
      appBar: AppBar(
        backgroundColor: AppStyles.primaryColor,
        title: const Text("Employee Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppStyles.standardPadding16),
        child: Card(
          shape: AppStyles.cardShape,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.person,
                  size: 70,
                  color: AppStyles.primaryColor,
                ),
                const SizedBox(height: 10),
                Text(_email, style: AppStyles.titleStyle),
                const SizedBox(height: 6),
                Text("Role: ${_role.isEmpty ? 'employee' : _role}"),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: AppStyles.primaryButtonStyleRounded,
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
