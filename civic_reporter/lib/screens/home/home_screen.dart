// import 'package:jana_setu/api/database_service.dart'; // Temporarily disabled
import 'package:jana_setu/screens/home/dashboard_screen.dart';
import 'package:jana_setu/screens/home/map_view_screen.dart';
import 'package:jana_setu/screens/home/profile_screen.dart';
import 'package:jana_setu/screens/nearby_reports_screen.dart';
import 'package:jana_setu/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const DashboardScreen(),
    const MapViewScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // This ensures that we don't try to access providers before the widget is built.
    // Notification service temporarily disabled
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // When the user logs in and this screen is built, save their notification token.
    //   final notificationService = context.read<NotificationService>();
    //   final dbService = context.read<DatabaseService>();
    //   notificationService.saveTokenToDatabase(dbService);
    // });
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('🔥 FAB pressed - navigating to NearbyReportsScreen');
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const NearbyReportsScreen()));
        },
        child: const Icon(Icons.add),
        tooltip: 'Create Report',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
