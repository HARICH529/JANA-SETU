import 'dart:async';
import 'package:flutter/foundation.dart';
import '../api/api_service.dart';
import '../models/report_model.dart';

class ReportStatusService with ChangeNotifier {
  final ApiService _apiService = ApiService();
  Timer? _statusCheckTimer;
  final Map<String, String> _reportStatuses = {};
  final Set<String> _watchedReports = {};

  void startWatchingReport(String reportId, String currentStatus) {
    _watchedReports.add(reportId);
    _reportStatuses[reportId] = currentStatus;
    
    if (_statusCheckTimer == null) {
      _startStatusChecking();
    }
  }

  void stopWatchingReport(String reportId) {
    _watchedReports.remove(reportId);
    _reportStatuses.remove(reportId);
    
    if (_watchedReports.isEmpty) {
      _stopStatusChecking();
    }
  }

  void _startStatusChecking() {
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkReportStatuses();
    });
  }

  void _stopStatusChecking() {
    _statusCheckTimer?.cancel();
    _statusCheckTimer = null;
  }

  Future<void> _checkReportStatuses() async {
    if (_watchedReports.isEmpty) return;

    try {
      // Fetch all reports to check for status updates
      final response = await _apiService.getAllReports();
      if (response['success'] == true) {
        final reports = (response['data']['reports'] as List)
            .map((json) => Report.fromJson(json))
            .toList();

        bool hasUpdates = false;
        for (final report in reports) {
          if (_watchedReports.contains(report.id)) {
            final oldStatus = _reportStatuses[report.id];
            if (oldStatus != null && oldStatus != report.status) {
              _reportStatuses[report.id] = report.status;
              hasUpdates = true;
              print('Report ${report.id} status changed from $oldStatus to ${report.status}');
            }
          }
        }

        if (hasUpdates) {
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error checking report statuses: $e');
    }
  }

  String? getReportStatus(String reportId) {
    return _reportStatuses[reportId];
  }

  @override
  void dispose() {
    _stopStatusChecking();
    super.dispose();
  }
}
