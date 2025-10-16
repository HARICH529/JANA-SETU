import 'package:jana_setu/screens/auth/login_screen.dart';
import 'package:jana_setu/screens/auth/complete_profile_screen.dart';
import 'package:jana_setu/api/database_service.dart';
import 'package:jana_setu/services/notification_service.dart';
import 'package:jana_setu/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  final NotificationService _notificationService = NotificationService();
  bool _notificationsInitialized = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    // Initialize notifications when user is authenticated
    if (user != null && !_notificationsInitialized) {
      _initializeNotifications();
    }

    // return either Home or Authenticate widget
    if (user == null) {
      return const LoginScreen();
    } else {
      // For now, just show the home screen directly
      // TODO: Add profile completion check later
      return const HomeScreen();
    }
  }

  void _initializeNotifications() async {
    try {
      await _notificationService.initNotifications();
      _notificationsInitialized = true;
      print('Notifications initialized successfully');
    } catch (e) {
      print('Failed to initialize notifications: $e');
    }
  }
}
