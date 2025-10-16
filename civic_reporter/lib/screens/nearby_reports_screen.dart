import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../providers/report_provider.dart';
import '../models/report_model.dart';
import '../utils/location_utils.dart';
import 'create_report_screen.dart';

class NearbyReportsScreen extends StatefulWidget {
  const NearbyReportsScreen({super.key});

  @override
  State<NearbyReportsScreen> createState() => _NearbyReportsScreenState();
}

class _NearbyReportsScreenState extends State<NearbyReportsScreen> {
  Position? _currentPosition;
  List<Report> _nearbyReports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNearbyReports();
  }

  Future<void> _loadNearbyReports() async {
    try {
      print('🔍 Loading nearby reports...');
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        _currentPosition = await Geolocator.getCurrentPosition();
        print('📍 Current position: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
        
        final reportProvider = Provider.of<ReportProvider>(context, listen: false);
        await reportProvider.fetchAllReports();
        print('📊 Total reports fetched: ${reportProvider.reports.length}');
        
        _filterNearbyReports();
        print('🎯 Nearby reports found: ${_nearbyReports.length}');
      } else {
        print('❌ Location permission denied');
      }
    } catch (e) {
      print('❌ Error loading nearby reports: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterNearbyReports() {
    if (_currentPosition == null) {
      print('❌ Current position is null, cannot filter reports');
      return;
    }
    
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    final allReports = reportProvider.reports;
    
    _nearbyReports = allReports.where((report) {
      double distance = calculateDistance(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        report.latitude,
        report.longitude,
      );
      print('📏 Report "${report.title}" is ${distance.round()}m away');
      return distance <= 100; // 100 meters
    }).toList();
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print('🟢 NearbyReportsScreen build called - isLoading: $_isLoading, nearbyReports: ${_nearbyReports.length}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Reports'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.green.shade50,
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Reports within 100m of your location (${_nearbyReports.length} found)',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _nearbyReports.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_searching, 
                                   size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              const Text(
                                'No nearby reports',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Be the first to report an issue in this area',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _nearbyReports.length,
                          itemBuilder: (context, index) {
                            final report = _nearbyReports[index];
                            double distance = calculateDistance(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                              report.latitude,
                              report.longitude,
                            );
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            report.title,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(report.status),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            report.status.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      report.description,
                                      style: TextStyle(color: Colors.grey[700]),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, 
                                             size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${distance.round()}m away',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(Icons.thumb_up, 
                                             size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${report.upvotes}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CreateReportScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Create New Report',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green;
      case 'pending':
      case 'submitted':
        return Colors.orange;
      case 'in_progress':
      case 'acknowledged':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
