import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';
import '../providers/simple_auth_provider.dart';
import '../models/report_model.dart';

class ReportsListScreen extends StatefulWidget {
  const ReportsListScreen({super.key});

  @override
  State<ReportsListScreen> createState() => _ReportsListScreenState();
}

class _ReportsListScreenState extends State<ReportsListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(context, listen: false).fetchAllReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Reports'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
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
                    onPressed: () => reportProvider.fetchAllReports(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final reports = reportProvider.reports;

          if (reports.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.report_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('No Reports Found', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return Card(
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
                              color: _getStatusColor(report.status),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Icon(
                              _getStatusIcon(report.status),
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
                                const SizedBox(height: 4),
                                Text(
                                  report.description,
                                  style: TextStyle(color: Colors.grey[600]),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
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
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              report.address,
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ),
                          Consumer<SimpleAuthProvider>(
                            builder: (context, authProvider, child) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: authProvider.isAuthenticated
                                        ? () => _handleUpvote(context, report.id)
                                        : () => _showLoginRequired(context),
                                    icon: Icon(
                                      Icons.thumb_up,
                                      size: 16,
                                      color: authProvider.isAuthenticated
                                          ? Colors.blue
                                          : Colors.grey,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 24,
                                      minHeight: 24,
                                    ),
                                  ),
                                  Text(
                                    '${report.upvotes}',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'By: ${report.userName}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const Spacer(),
                          Text(
                            _formatDate(report.createdAt),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
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
      default:
        return Icons.report;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _handleUpvote(BuildContext context, String reportId) async {
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    
    try {
      final success = await reportProvider.upvoteReport(reportId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report upvoted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to upvote report'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showLoginRequired(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('You need to be logged in to upvote reports.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}
