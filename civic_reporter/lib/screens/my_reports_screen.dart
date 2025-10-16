import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/report_provider.dart';
import '../providers/simple_auth_provider.dart';
import '../models/report_model.dart';
import '../main.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(context, listen: false).fetchUserReports();
      _startAutoRefresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      Provider.of<ReportProvider>(context, listen: false).fetchUserReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<ReportProvider>(context, listen: false).fetchUserReports();
            },
          ),
        ],
      ),
      body: Consumer<ReportProvider>(
        builder: (context, reportProvider, child) {
          if (reportProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (reportProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 80, color: Colors.red),
                  const SizedBox(height: 20),
                  Text('Error: ${reportProvider.error}'),
                  ElevatedButton(
                    onPressed: () => reportProvider.fetchUserReports(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final userReports = reportProvider.userReports;

          if (userReports.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.report_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text(
                    'No Reports Submitted by You',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'You haven\'t submitted any reports yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: userReports.length,
            itemBuilder: (context, index) {
              final report = userReports[index];
              final authProvider = Provider.of<SimpleAuthProvider>(context, listen: false);
              return GestureDetector(
                onTap: () => _viewReportDetails(report),
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _getIssueColor(report.title),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Icon(
                                _getIssueIcon(report.title),
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    report.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(report.status),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      report.status.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.grey),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '↑',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${report.upvotes}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getSeverityColor(report.upvotes),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getSeverityText(report.upvotes),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (report.status.toLowerCase() == 'acknowledged')
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _markAsResolved(report),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Mark as Resolved'),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'acknowledged':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.pending;
      case 'in_progress':
        return Icons.construction;
      case 'resolved':
        return Icons.check_circle;
      case 'acknowledged':
        return Icons.visibility;
      default:
        return Icons.report;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewReportDetails(report) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ReportDetailScreen(report: report),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Color _getSeverityColor(int upvotes) {
    if (upvotes >= 10) return Colors.red[700]!;
    if (upvotes >= 5) return Colors.orange[700]!;
    if (upvotes >= 2) return Colors.yellow[700]!;
    return Colors.grey[600]!;
  }

  String _getSeverityText(int upvotes) {
    if (upvotes >= 10) return 'CRITICAL';
    if (upvotes >= 5) return 'HIGH';
    if (upvotes >= 2) return 'MEDIUM';
    return 'LOW';
  }

  Color _getIssueColor(String title) {
    if (title.toLowerCase().contains('light')) return Colors.yellow[700]!;
    if (title.toLowerCase().contains('pothole') || title.toLowerCase().contains('road')) return Colors.brown;
    if (title.toLowerCase().contains('garbage') || title.toLowerCase().contains('waste')) return Colors.green;
    if (title.toLowerCase().contains('water') || title.toLowerCase().contains('leak')) return Colors.blue;
    if (title.toLowerCase().contains('footpath') || title.toLowerCase().contains('path')) return Colors.grey[700]!;
    if (title.toLowerCase().contains('traffic')) return Colors.red[700]!;
    if (title.toLowerCase().contains('dog')) return Colors.purple[700]!;
    return Colors.red[700]!;
  }

  IconData _getIssueIcon(String title) {
    if (title.toLowerCase().contains('light')) return Icons.lightbulb;
    if (title.toLowerCase().contains('pothole') || title.toLowerCase().contains('road')) return Icons.warning;
    if (title.toLowerCase().contains('garbage') || title.toLowerCase().contains('waste')) return Icons.delete;
    if (title.toLowerCase().contains('water') || title.toLowerCase().contains('leak')) return Icons.water_drop;
    if (title.toLowerCase().contains('footpath') || title.toLowerCase().contains('path')) return Icons.directions_walk;
    if (title.toLowerCase().contains('traffic')) return Icons.traffic;
    if (title.toLowerCase().contains('dog')) return Icons.pets;
    return Icons.report_problem;
  }

  Future<void> _markAsResolved(report) async {
    try {
      final reportProvider = Provider.of<ReportProvider>(context, listen: false);
      final success = await reportProvider.updateReportStatus(report.id);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report marked as resolved!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the reports list
        reportProvider.fetchUserReports();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(reportProvider.error ?? 'Failed to resolve report'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
