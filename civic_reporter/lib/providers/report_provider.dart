import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class ReportProvider with ChangeNotifier {
  final ReportService _reportService = ReportService();
  Timer? _statusUpdateTimer;
  
  List<Report> _reports = [];
  List<Report> _userReports = [];
  List<Report> _nearbyReports = [];
  bool _isLoading = false;
  String? _error;
  
  ReportProvider() {
    _startStatusUpdateTimer();
  }
  
  void _startStatusUpdateTimer() {
    _statusUpdateTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _refreshReportsInBackground();
    });
  }
  
  Future<void> _refreshReportsInBackground() async {
    try {
      await fetchAllReports();
      await fetchUserReports();
    } catch (e) {
      print('Background refresh failed: $e');
    }
  }
  
  @override
  void dispose() {
    _statusUpdateTimer?.cancel();
    super.dispose();
  }

  List<Report> get reports => _reports;
  List<Report> get userReports => _userReports;
  List<Report> get nearbyReports => _nearbyReports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<bool> createReport({
    required String title,
    required String description,
    required String category,
    required double latitude,
    required double longitude,
    required String address,
    File? image,
    File? voice,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final report = await _reportService.createReport(
        title: title,
        description: description,
        category: category,
        latitude: latitude,
        longitude: longitude,
        address: address,
        image: image,
        voice: voice,
      );

      _reports.insert(0, report);
      _userReports.insert(0, report);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchAllReports() async {
    try {
      _setLoading(true);
      _setError(null);

      _reports = await _reportService.getAllReports();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchUserReports() async {
    try {
      _setLoading(true);
      _setError(null);

      _userReports = await _reportService.getUserReports();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchNearbyReports({
    required double latitude,
    required double longitude,
    double radius = 5.0,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      _nearbyReports = await _reportService.getNearbyReports(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> upvoteReport(String reportId) async {
    try {
      _setError(null);
      print('ReportProvider: Attempting to upvote report $reportId');
      
      final success = await _reportService.upvoteReport(reportId);
      print('ReportProvider: Upvote result: $success');
      
      if (success) {
        // Refresh reports to get updated upvote data from server
        await fetchAllReports();
        await fetchUserReports();
      }
      
      return success;
    } catch (e) {
      print('ReportProvider: Upvote error: $e');
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      _setError(errorMessage);
      return false;
    }
  }
  


  Future<bool> updateReportStatus(String reportId) async {
    try {
      final success = await _reportService.updateReportStatus(reportId);
      if (success) {
        _updateReportInLists(reportId, (report) {
          return Report(
            id: report.id,
            title: report.title,
            description: report.description,
            category: report.category,
            latitude: report.latitude,
            longitude: report.longitude,
            address: report.address,
            imageUrl: report.imageUrl,
            status: 'resolved',
            createdAt: report.createdAt,
            userId: report.userId,
            userName: report.userName,
            upvotes: report.upvotes,
            upvotedBy: report.upvotedBy,
            blockchainTxHash: report.blockchainTxHash,
          );
        });
      }
      return success;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  void _updateReportInLists(String reportId, Report Function(Report) updater) {
    final allIndex = _reports.indexWhere((r) => r.id == reportId);
    if (allIndex != -1) {
      _reports[allIndex] = updater(_reports[allIndex]);
    }

    final userIndex = _userReports.indexWhere((r) => r.id == reportId);
    if (userIndex != -1) {
      _userReports[userIndex] = updater(_userReports[userIndex]);
    }

    final nearbyIndex = _nearbyReports.indexWhere((r) => r.id == reportId);
    if (nearbyIndex != -1) {
      _nearbyReports[nearbyIndex] = updater(_nearbyReports[nearbyIndex]);
    }

    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }
}
