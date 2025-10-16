import 'package:flutter/material.dart';

class SimpleNotificationService {
  static final SimpleNotificationService _instance = SimpleNotificationService._internal();
  factory SimpleNotificationService() => _instance;
  SimpleNotificationService._internal();

  static GlobalKey<NavigatorState>? navigatorKey;

  void showNotification(String title, String message) {
    if (navigatorKey?.currentContext != null) {
      ScaffoldMessenger.of(navigatorKey!.currentContext!).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(message),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
