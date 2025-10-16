import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:async';
import 'main.dart';
import 'providers/simple_auth_provider.dart';
import 'providers/report_provider.dart';
import 'providers/notification_provider.dart';
import 'models/notification_model.dart';
import 'screens/settings_screen.dart';

// Global settings state
class AppSettings {
  static bool notificationsEnabled = true;
  static bool locationEnabled = true;
  static bool darkMode = false;
  static String language = 'English';
  static String userName = 'John Doe';
  static String userEmail = 'john.doe@example.com';
  static bool isLoggedIn = false;
  
  // ValueNotifier for dark mode to trigger UI updates
  static final ValueNotifier<bool> darkModeNotifier = ValueNotifier<bool>(false);
  
  static void toggleDarkMode(bool value) {
    darkMode = value;
    darkModeNotifier.value = value;
  }
  
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', value);
    isLoggedIn = value;
  }
  
  static Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    return isLoggedIn;
  }
}

class MapTab extends StatelessWidget {
  const MapTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.map, size: 80, color: Colors.blue),
          const SizedBox(height: 20),
          const Text('Map View', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('${reportedIssues.length} issues reported in your area', style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Map integration requires Google Maps API key')),
              );
            },
            child: const Text('View Issues on Map'),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: const Column(
              children: [
                Icon(Icons.info, color: Colors.green),
                SizedBox(height: 8),
                Text(
                  'Map functionality is available but requires Google Maps API key configuration.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.green),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> with AutomaticKeepAliveClientMixin {
  final String _currentUserId = 'user123';
  Timer? _refreshTimer;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserProfile();
      _startPeriodicRefresh();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _fetchUserProfile();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh profile data whenever the widget becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUserProfile();
    });
  }

  Future<void> _fetchUserProfile() async {
    final authProvider = Provider.of<SimpleAuthProvider>(context, listen: false);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    await authProvider.refreshUserProfile();
    await reportProvider.fetchUserReports();
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help, color: Colors.green),
            SizedBox(width: 8),
            Text('Help & Support'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Need help with JANA SETU?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text('📧 Email: help@janasetu.com'),
            const SizedBox(height: 8),
            const Text('🌐 Website: www.janasetu.com'),
            const SizedBox(height: 16),
            const Text(
              '📞 24/7 Helpline:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: const Row(
                children: [
                  Icon(Icons.phone, color: Colors.blue),
                  SizedBox(width: 8),
                  Text(
                    '+91-1800-123-4567',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening dialer... +91-1800-123-4567'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.call),
                label: const Text('Call Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final userIssues = reportedIssues.where((issue) => issue.reportedBy == _currentUserId).toList();
    final resolvedIssues = userIssues.where((i) => i.status == 'Resolved').length;
    final pendingIssues = userIssues.where((i) => i.status == 'Pending').length;
    final inProgressIssues = userIssues.where((i) => i.status == 'In Progress').length;
    final totalUpvotes = userIssues.fold(0, (sum, issue) => sum + issue.upvotes);

    return RefreshIndicator(
      onRefresh: _fetchUserProfile,
      child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [const Color(0xFF2E4A6B), const Color(0xFF3498DB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.person,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Consumer<SimpleAuthProvider>(
            builder: (context, authProvider, child) {
              return Column(
                children: [
                  Text(
                    authProvider.userProfile?['name']?.toString() ?? 'Loading...',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    authProvider.userProfile?['email']?.toString() ?? 'Loading...',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7CB342),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          authProvider.userProfile?['badge']?.toString() ?? 'Bronze',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.emoji_events, color: Colors.yellow, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Resolved Reports: ${authProvider.userProfile?['resolvedReportsCount']?.toString() ?? '0'}',
                    style: const TextStyle(color: Color(0xFF7CB342), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  if (authProvider.isLoading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    TextButton.icon(
                      onPressed: _fetchUserProfile,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Refresh'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          
          // Analytics Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.withOpacity(0.1), Colors.green.withOpacity(0.1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Impact Analytics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Consumer<ReportProvider>(
                  builder: (context, reportProvider, child) {
                    final userReports = reportProvider.userReports;
                    final totalReports = userReports.length;
                    final resolvedReports = userReports.where((r) => r.status.toLowerCase() == 'resolved').length;
                    final pendingReports = userReports.where((r) => r.status.toLowerCase() == 'pending' || r.status.toLowerCase() == 'submitted').length;
                    final inProgressReports = userReports.where((r) => r.status.toLowerCase() == 'in_progress' || r.status.toLowerCase() == 'acknowledged').length;
                    final totalUpvotes = userReports.fold(0, (sum, report) => sum + report.upvotes);
                    final successRate = totalReports > 0 ? ((resolvedReports / totalReports) * 100).round() : 0;
                    
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildAnalyticsCard('Total Reports', totalReports.toString(), const Color(0xFF3498DB), Icons.report)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildAnalyticsCard('Resolved', resolvedReports.toString(), const Color(0xFF7CB342), Icons.check_circle)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildAnalyticsCard('Pending', pendingReports.toString(), Colors.orange, Icons.pending)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildAnalyticsCard('In Progress', inProgressReports.toString(), const Color(0xFF2E4A6B), Icons.construction)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildAnalyticsCard('Total Upvotes', totalUpvotes.toString(), Colors.purple, Icons.thumb_up)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildAnalyticsCard('Success Rate', '$successRate%', const Color(0xFF7CB342), Icons.trending_up)),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Recent Activity
          Consumer<ReportProvider>(
            builder: (context, reportProvider, child) {
              final recentReports = reportProvider.userReports.take(3).toList();
              if (recentReports.isEmpty) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent Activity',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ...recentReports.map((report) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(report.status),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    report.title,
                                    style: const TextStyle(fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  report.status.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getStatusColor(report.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              );
            },
          ),
          
          // Settings and Actions
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings, color: Colors.blue),
              title: const Text('Settings'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.help, color: Colors.green),
              title: const Text('Help & Support'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                _showHelpDialog(context);
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.orange),
              title: const Text('About'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('About JANA SETU'),
                    content: const Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Version: 1.0.0'),
                        SizedBox(height: 8),
                        Text('JANA SETU is a citizen reporting platform that empowers communities to report and track civic issues.'),
                        SizedBox(height: 8),
                        Text('Built with Flutter and Firebase.'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'In Progress': return Colors.blue;
      case 'Resolved': return Colors.green;
      default: return Colors.grey;
    }
  }
}

// SettingsScreen is now in separate file

class AreaReportsScreen extends StatefulWidget {
  const AreaReportsScreen({super.key});

  @override
  State<AreaReportsScreen> createState() => _AreaReportsScreenState();
}

class _AreaReportsScreenState extends State<AreaReportsScreen> {
  Position? _currentPosition;
  String _locationText = 'Getting your location...';
  List<Issue> _nearbyIssues = [];
  final String _currentUserId = 'user123';

  @override
  void initState() {
    super.initState();
    _getCurrentLocationAndLoadIssues();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports in Your Area'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.green.withOpacity(0.1),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _locationText,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          if (_nearbyIssues.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_nearbyIssues.length} issues found in your area. Upvote to increase priority!',
                      style: const TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _nearbyIssues.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_searching, size: 80, color: Colors.grey),
                        SizedBox(height: 20),
                        Text('Be the First to Report!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _nearbyIssues.length,
                    itemBuilder: (context, index) {
                      final issue = _nearbyIssues[index];
                      final hasUpvoted = issue.hasUpvoted(_currentUserId);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
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
                                      color: _getIssueColor(issue.title),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Icon(
                                      _getIssueIcon(issue.title),
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
                                          issue.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          issue.description,
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
                                      color: _getStatusColor(issue.status),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      issue.status,
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
                                  if (issue.voiceNote != null)
                                    const Padding(
                                      padding: EdgeInsets.only(right: 8),
                                      child: Icon(Icons.mic, size: 16, color: Colors.green),
                                    ),
                                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDate(issue.reportedAt),
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '~${(index * 0.3 + 0.2).toStringAsFixed(1)} km away',
                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => _toggleUpvote(issue),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        gradient: hasUpvoted 
                                          ? LinearGradient(
                                              colors: [Colors.green.shade400, Colors.green.shade600],
                                            )
                                          : null,
                                        color: hasUpvoted ? null : (Theme.of(context).brightness == Brightness.dark ? Colors.grey[700] : Colors.grey[200]),
                                        borderRadius: BorderRadius.circular(25),
                                        boxShadow: hasUpvoted ? [
                                          BoxShadow(
                                            color: Colors.green.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ] : null,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.thumb_up,
                                            size: 16,
                                            color: hasUpvoted ? Colors.white : Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${issue.upvotes}',
                                            style: TextStyle(
                                              color: hasUpvoted ? Colors.white : Colors.grey[600],
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getSeverityColor(issue.upvotes),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getSeverityText(issue.upvotes),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
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
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ReportIssueScreen()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo),
              SizedBox(width: 8),
              Text('Report New Issue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getCurrentLocationAndLoadIssues() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          _locationText = 'Delhi Area - Sample Location';
          _nearbyIssues = List.from(reportedIssues)..sort((a, b) => b.upvotes.compareTo(a.upvotes));
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _locationText = 'Within 5km of your location';
        _nearbyIssues = _getIssuesInArea(position);
      });
    } catch (e) {
      setState(() {
        _locationText = 'Delhi Area - Sample Location';
        _nearbyIssues = List.from(reportedIssues)..sort((a, b) => b.upvotes.compareTo(a.upvotes));
      });
    }
  }

  List<Issue> _getIssuesInArea(Position userPosition) {
    List<Issue> nearbyIssues = reportedIssues.where((issue) {
      if (issue.latitude == null || issue.longitude == null) return true;
      
      double distance = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        issue.latitude!,
        issue.longitude!,
      );
      
      return distance <= 5000;
    }).toList();

    nearbyIssues.sort((a, b) => b.upvotes.compareTo(a.upvotes));
    
    return nearbyIssues;
  }

  void _toggleUpvote(Issue issue) {
    setState(() {
      if (issue.hasUpvoted(_currentUserId)) {
        issue.removeUpvote(_currentUserId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upvote removed')),
        );
      } else {
        issue.addUpvote(_currentUserId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Issue upvoted! Helps prioritize severity.')),
        );
      }
      
      if (_currentPosition != null) {
        _nearbyIssues = _getIssuesInArea(_currentPosition!);
      } else {
        _nearbyIssues = List.from(reportedIssues)..sort((a, b) => b.upvotes.compareTo(a.upvotes));
      }
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'In Progress': return Colors.blue;
      case 'Resolved': return Colors.green;
      default: return Colors.grey;
    }
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
}

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  bool _isRecording = false;
  bool _hasVoiceNote = false;
  String? _voiceNotePath;
  Position? _currentPosition;
  String _locationText = 'Getting location...';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Issue'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Only photo is required. Location will be tagged automatically.',
                      style: TextStyle(color: Colors.blue, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Issue Title (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g., Broken streetlight (auto-generated if empty)',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Description (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Describe the issue in detail...',
              ),
            ),
            const SizedBox(height: 16),
            const Text('Voice Note (Optional)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _hasVoiceNote ? Icons.mic : Icons.mic_none,
                    color: _hasVoiceNote ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _hasVoiceNote ? 'Voice note recorded' : 'Tap to record voice note',
                      style: TextStyle(
                        color: _hasVoiceNote ? Colors.green : Colors.grey,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _isRecording ? null : _toggleVoiceRecording,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRecording ? Colors.red : Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_isRecording ? 'Stop' : (_hasVoiceNote ? 'Re-record' : 'Record')),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _locationText,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (_currentPosition == null)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('Photo *', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            Image.file(_selectedImage!, fit: BoxFit.cover, width: double.infinity, height: 200),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Photo captured',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Tap to take photo', style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 4),
                          Text('Required for reporting', style: TextStyle(color: Colors.red, fontSize: 12)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitIssue,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Issue', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationText = 'Location permission denied';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationText = 'Location permission permanently denied';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _locationText = 'Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}';
      });
    } catch (e) {
      setState(() {
        _locationText = 'Using sample location for demo';
        _currentPosition = Position(
          latitude: 28.6139,
          longitude: 77.2090,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      var status = await Permission.camera.request();
      if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission is required')),
        );
        return;
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        
        if (_currentPosition == null) {
          _getCurrentLocation();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error taking photo: $e')),
      );
    }
  }

  Future<void> _toggleVoiceRecording() async {
    try {
      var status = await Permission.microphone.request();
      if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Microphone permission is required')),
        );
        return;
      }

      if (_isRecording) {
        setState(() {
          _isRecording = false;
          _hasVoiceNote = true;
          _voiceNotePath = 'voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Voice note recorded successfully')),
        );
      } else {
        setState(() {
          _isRecording = true;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recording voice note...')),
        );
        
        await Future.delayed(const Duration(seconds: 3));
        
        if (_isRecording) {
          setState(() {
            _isRecording = false;
            _hasVoiceNote = true;
            _voiceNotePath = 'voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Voice note recorded successfully')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isRecording = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error with voice recording: $e')),
      );
    }
  }

  Future<void> _submitIssue() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please take a photo to report the issue')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    await Future.delayed(const Duration(seconds: 2));

    String title = _titleController.text.isEmpty 
        ? 'Issue reported on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'
        : _titleController.text;

    final issue = Issue(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: _descriptionController.text.isEmpty ? 'No description provided' : _descriptionController.text,
      imagePath: _selectedImage!.path,
      reportedAt: DateTime.now(),
      location: _locationText,
      latitude: _currentPosition?.latitude,
      longitude: _currentPosition?.longitude,
      voiceNote: _voiceNotePath,
      reportedBy: 'user123',
    );

    reportedIssues.add(issue);

    // Refresh notifications after creating report
    final authProvider = Provider.of<SimpleAuthProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    notificationProvider.refreshNotifications(authProvider);

    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Issue reported successfully with location!')),
    );

    Navigator.pop(context);
  }
}
