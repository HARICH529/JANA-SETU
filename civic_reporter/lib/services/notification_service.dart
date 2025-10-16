import 'package:jana_setu/api/database_service.dart';
import 'package:jana_setu/api/api_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final ApiService _apiService = ApiService();

  Future<void> initNotifications() async {
    // Request permission from the user
    await _fcm.requestPermission();

    // Get and save FCM token
    String? token = await _fcm.getToken();
    await _saveFcmTokenToBackend(token);
  
    // Listen for token refreshes
    _fcm.onTokenRefresh.listen((newToken) {
      _saveFcmTokenToBackend(newToken);
    });

    // Handle notifications when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // Show local notification or update UI
        _handleForegroundMessage(message);
      }
    });

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      _handleNotificationTap(message);
    });
  }

  Future<void> _saveFcmTokenToBackend(String token) async {
    try {
      final response = await _apiService.saveFcmToken(token);
      if (response['success'] == true) {
        print('FCM token saved successfully');
      }
    } catch (e) {
      print('Failed to save FCM token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Handle different notification types
    final type = message.data['type'];
    
    if (type == 'report_acknowledged' || type == 'status_update') {
      // Refresh report data or show in-app notification
      print('Report status notification received: ${message.notification?.title}');
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    // Navigate to specific screen based on notification type
    final type = message.data['type'];
    final reportId = message.data['reportId'];
    
    if (type == 'report_acknowledged' || type == 'status_update') {
      // Navigate to report details or my reports screen
      print('Navigate to report: $reportId');
    }
  }

  Future<void> saveTokenToDatabase(DatabaseService dbService) async {
    if (dbService.uid == null) return;

    // Get the token for this device
    String? token = await _fcm.getToken();

    // Save the token to the user's document in Firestore
    await dbService.saveUserToken(token);

    // Listen for token refreshes and save the new one
    _fcm.onTokenRefresh.listen(dbService.saveUserToken);
    }
}
