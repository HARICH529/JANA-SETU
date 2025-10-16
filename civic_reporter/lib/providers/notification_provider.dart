import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import '../services/report_service.dart';
import '../providers/simple_auth_provider.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  Set<String> _readNotifications = {};

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider() {
    _loadReadNotifications();
  }

  Future<void> _loadReadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final readIds = prefs.getStringList('read_notifications') ?? [];
    _readNotifications = readIds.toSet();
  }

  Future<void> _saveReadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('read_notifications', _readNotifications.toList());
  }

  Future<void> fetchNotifications(SimpleAuthProvider authProvider) async {
    if (!authProvider.isAuthenticated) {
      _notifications = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final reportService = ReportService();
      final userReports = await reportService.getUserReports();
      
      _notifications = _generateNotificationsFromReports(userReports);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _notifications = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<NotificationModel> _generateNotificationsFromReports(List<dynamic> reports) {
    List<NotificationModel> notifications = [];
    
    for (var report in reports) {
      final status = report.status?.toLowerCase() ?? 'pending';
      final title = report.title?.replaceAll('"', '') ?? 'Report';
      final reportId = report.id ?? '';
      final createdAt = report.createdAt ?? DateTime.now();
      
      // Generate status update notifications based on current status
      switch (status) {
        case 'acknowledged':
        case 'in_progress':
          final notificationId = '${reportId}_acknowledged';
          notifications.add(NotificationModel(
            id: notificationId,
            title: 'Report Status Updated',
            message: 'Your report "$title" has been acknowledged and is being reviewed',
            timestamp: createdAt.add(Duration(hours: 2)),
            type: 'status_update',
            reportId: reportId,
            isRead: _readNotifications.contains(notificationId),
          ));
          break;
          
        case 'resolved':
          // Add acknowledged notification first
          final acknowledgedId = '${reportId}_acknowledged';
          notifications.add(NotificationModel(
            id: acknowledgedId,
            title: 'Report Acknowledged',
            message: 'Your report "$title" has been acknowledged by authorities',
            timestamp: createdAt.add(Duration(hours: 1)),
            type: 'status_update',
            reportId: reportId,
            isRead: _readNotifications.contains(acknowledgedId),
          ));
          
          // Add resolved notification
          final resolvedId = '${reportId}_resolved';
          notifications.add(NotificationModel(
            id: resolvedId,
            title: 'Report Resolved ✅',
            message: 'Great news! Your report "$title" has been successfully resolved',
            timestamp: createdAt.add(Duration(days: 1)),
            type: 'status_update',
            reportId: reportId,
            isRead: _readNotifications.contains(resolvedId),
          ));
          break;
      }
      
      // Generate upvote notifications for reports with significant upvotes
      final upvotes = report.upvotes ?? 0;
      if (upvotes >= 3) {
        final upvoteId = '${reportId}_upvotes';
        notifications.add(NotificationModel(
          id: upvoteId,
          title: 'Report Gaining Attention',
          message: 'Your report "$title" received $upvotes upvote${upvotes > 1 ? 's' : ''} from the community',
          timestamp: createdAt.add(Duration(hours: 3)),
          type: 'upvote',
          reportId: reportId,
          isRead: _readNotifications.contains(upvoteId),
        ));
      }
    }
    
    // Sort by timestamp (newest first)
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return notifications;
  }

  void markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index].isRead = true;
      _readNotifications.add(notificationId);
      await _saveReadNotifications();
      notifyListeners();
    }
  }
  
  void refreshNotifications(SimpleAuthProvider authProvider) {
    fetchNotifications(authProvider);
  }

  void markAllAsRead() async {
    for (var notification in _notifications) {
      notification.isRead = true;
      _readNotifications.add(notification.id);
    }
    await _saveReadNotifications();
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
