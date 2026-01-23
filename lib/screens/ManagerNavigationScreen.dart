import 'package:flutter/material.dart';
import '../../styles/app_styles.dart';
import '../../styles/strings.dart';
import 'ManagerOrdersScreen.dart';
import 'ManagerServicesScreen.dart';
import 'ManagerTeamsScreen.dart';
import 'ManagerFeedbackScreen.dart';

class ManagerNavigationScreen extends StatefulWidget {
  const ManagerNavigationScreen({super.key});

  @override
  State<ManagerNavigationScreen> createState() =>
      _ManagerNavigationScreenState();
}

class _ManagerNavigationScreenState extends State<ManagerNavigationScreen>
    with WidgetsBindingObserver {
  int _index = 0;

  final _pages = const [
    ManagerOrdersScreen(),
    ManagerServicesScreen(),
    ManagerTeamsScreen(),
    ManagerFeedbackScreen(),
  ];

  // Optional: if you want to keep the current tab when rotating
  // Flutter usually keeps state, but this is extra-safe.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Lifecycle management (requirement #10)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    if (state == AppLifecycleState.paused) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("App paused")));
    } else if (state == AppLifecycleState.resumed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("App resumed")));
    }
  }

  // Orientation management (requirement #11)
  // Here we slightly change the layout when in landscape:
  // - We keep BottomNavigationBar in portrait
  // - In landscape we show NavigationRail + page content side-by-side
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        final isLandscape = orientation == Orientation.landscape;

        if (isLandscape) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  labelType: NavigationRailLabelType.all,
                  selectedIconTheme: const IconThemeData(
                    color: AppStyles.primaryColor,
                  ),
                  selectedLabelTextStyle: const TextStyle(
                    color: AppStyles.primaryColor,
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.receipt_long),
                      label: Text(AppStrings.orders),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.miscellaneous_services),
                      label: Text(AppStrings.services),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.groups),
                      label: Text(AppStrings.teams),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.star_rate),
                      label: Text(AppStrings.feedback),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _pages[_index]),
              ],
            ),
          );
        }

        // Portrait: keep your original BottomNavigationBar
        return Scaffold(
          body: _pages[_index],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _index,
            selectedItemColor: AppStyles.primaryColor,
            unselectedItemColor: Colors.grey,
            onTap: (i) => setState(() => _index = i),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long),
                label: "Orders",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.miscellaneous_services),
                label: "Services",
              ),
              BottomNavigationBarItem(icon: Icon(Icons.groups), label: "Teams"),
              BottomNavigationBarItem(
                icon: Icon(Icons.star_rate),
                label: "Feedback",
              ),
            ],
          ),
        );
      },
    );
  }
}
