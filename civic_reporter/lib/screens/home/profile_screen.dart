import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/simple_auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../main.dart';
import '../settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    print('🔵 ProfileScreen: initState called');
    // Fetch user profile when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔵 ProfileScreen: Post frame callback triggered');
      _fetchUserProfile();
    });
  }

  Future<void> _fetchUserProfile() async {
    print('🔵 ProfileScreen: _fetchUserProfile called');
    final authProvider = Provider.of<SimpleAuthProvider>(context, listen: false);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    
    print('🔵 ProfileScreen: Current profile data before refresh: ${authProvider.userProfile}');
    
    // Force refresh user profile and reports
    print('🔵 ProfileScreen: Calling refreshUserProfile...');
    await authProvider.refreshUserProfile();
    
    print('🔵 ProfileScreen: Profile data after refresh: ${authProvider.userProfile}');
    
    print('🔵 ProfileScreen: Calling fetchUserReports...');
    await reportProvider.fetchUserReports();
    
    print('🔵 ProfileScreen: _fetchUserProfile completed');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SimpleAuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchUserProfile,
              ),
            ],
          ),
          body: authProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      
                      // User Info Section
                      Column(
                        children: [
                          Builder(
                            builder: (context) {
                              final name = authProvider.userProfile?['name']?.toString() ?? 'Loading...';
                              print('🔵 ProfileScreen: Rendering name: $name');
                              print('🔵 ProfileScreen: Full profile in render: ${authProvider.userProfile}');
                              return Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          Text(
                            authProvider.userProfile?['email']?.toString() ?? 'Loading...',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
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
                        ],
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Impact Analytics Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF2E4A6B).withOpacity(0.05),
                              const Color(0xFF7CB342).withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF2E4A6B).withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Your Impact Analytics',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
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
                                        Expanded(
                                          child: _buildAnalyticsCard(
                                            '$totalReports',
                                            'Total Reports',
                                            Icons.report,
                                            const Color(0xFF3498DB),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildAnalyticsCard(
                                            '$resolvedReports',
                                            'Resolved',
                                            Icons.check_circle,
                                            const Color(0xFF7CB342),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildAnalyticsCard(
                                            '$pendingReports',
                                            'Pending',
                                            Icons.pending,
                                            Colors.orange,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildAnalyticsCard(
                                            '$inProgressReports',
                                            'In Progress',
                                            Icons.construction,
                                            const Color(0xFF2E4A6B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildAnalyticsCard(
                                            '$totalUpvotes',
                                            'Total Upvotes',
                                            Icons.thumb_up,
                                            Colors.purple,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildAnalyticsCard(
                                            '$successRate%',
                                            'Success Rate',
                                            Icons.trending_up,
                                            const Color(0xFF7CB342),
                                          ),
                                        ),
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
                      
                      // Recent Activity Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recent Activity',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Consumer<ReportProvider>(
                              builder: (context, reportProvider, child) {
                                final recentReports = reportProvider.userReports.take(3).toList();
                                if (recentReports.isEmpty) {
                                  return const Text(
                                    'No recent activity',
                                    style: TextStyle(color: Colors.grey),
                                  );
                                }
                                return Column(
                                  children: recentReports.map((report) => 
                                    Padding(
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
                                    ),
                                  ).toList(),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      ElevatedButton(
                        onPressed: () async {
                          await authProvider.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Sign Out',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildAnalyticsCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return const Color(0xFF7CB342);
      case 'pending':
      case 'submitted':
        return Colors.orange;
      case 'in_progress':
      case 'acknowledged':
        return const Color(0xFF3498DB);
      default:
        return Colors.grey;
    }
  }
}
