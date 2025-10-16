import 'dart:io';
import '../api/api_service.dart';
import '../models/report_model.dart';

class ReportService {
  final ApiService _apiService = ApiService();

  Future<Report> createReport({
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
      final response = await _apiService.createReport(
        title: title,
        description: description,
        category: category,
        latitude: latitude,
        longitude: longitude,
        address: address,
        image: image,
        voice: voice,
      );

      if (response['success'] == true && response['data'] != null) {
        return Report.fromJson(response['data']);
      } else {
        throw Exception(response['message'] ?? 'Failed to create report');
      }
    } catch (e) {
      throw Exception('Error creating report: $e');
    }
  }

  Future<List<Report>> getAllReports() async {
    try {
      final response = await _apiService.getAllReports();
      
      if (response['success'] == true && response['data'] != null && response['data']['reports'] != null) {
        final List<dynamic> reportsJson = response['data']['reports'];
        return reportsJson.map((json) => Report.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch reports');
      }
    } catch (e) {
      throw Exception('Error fetching reports: $e');
    }
  }

  Future<List<Report>> getUserReports() async {
    try {
      final response = await _apiService.getUserReports();
      
      if (response['success'] == true && response['data'] != null && response['data']['reports'] != null) {
        final List<dynamic> reportsJson = response['data']['reports'];
        return reportsJson.map((json) => Report.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch user reports');
      }
    } catch (e) {
      throw Exception('Error fetching user reports: $e');
    }
  }

  Future<List<Report>> getNearbyReports({
    required double latitude,
    required double longitude,
    double radius = 5.0,
  }) async {
    try {
      final response = await _apiService.getNearbyReports(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
      );
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> reportsJson = response['data'];
        return reportsJson.map((json) => Report.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch nearby reports');
      }
    } catch (e) {
      throw Exception('Error fetching nearby reports: $e');
    }
  }

  Future<bool> upvoteReport(String reportId) async {
    try {
      print('ReportService: Calling upvote API for report $reportId');
      final response = await _apiService.upvoteReport(reportId);
      print('ReportService: Upvote API response: $response');
      
      // Check if response contains message (indicates success)
      final success = response['message'] != null;
      print('ReportService: Upvote success: $success');
      
      return success;
    } catch (e) {
      print('ReportService: Upvote error: $e');
      // Extract meaningful error message
      String errorMsg = e.toString();
      if (errorMsg.contains('Exception: ')) {
        errorMsg = errorMsg.replaceAll('Exception: ', '');
      }
      if (errorMsg.contains('Network error: ')) {
        errorMsg = errorMsg.replaceAll('Network error: ', '');
      }
      throw Exception(errorMsg);
    }
  }

  Future<bool> updateReportStatus(String reportId) async {
    try {
      final response = await _apiService.updateReportStatus(reportId);
      return response['success'] == true;
    } catch (e) {
      throw Exception('Error updating report status: $e');
    }
  }
}
