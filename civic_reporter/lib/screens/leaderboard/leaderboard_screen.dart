import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../api/api_config.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<dynamic> leaderboard = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchLeaderboard();
  }

  Future<void> fetchLeaderboard() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/leaderboard/monthly'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            leaderboard = data['data']['leaderboard'];
            isLoading = false;
          });
        } else {
          setState(() {
            error = 'Failed to fetch leaderboard';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          error = 'Server error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Network error: $e';
        isLoading = false;
      });
    }
  }

  Widget getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
        );
      case 2:
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.military_tech, color: Colors.grey, size: 20),
        );
      case 3:
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.brown.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.workspace_premium, color: Colors.brown, size: 20),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFF2E4A6B).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.star, color: Color(0xFF2E4A6B), size: 16),
        );
    }
  }

  Color getBadgeColor(String badge) {
    switch (badge) {
      case 'Platinum':
        return Colors.grey.shade300;
      case 'Gold':
        return Colors.amber;
      case 'Silver':
        return Colors.grey;
      case 'Bronze':
        return Colors.brown;
      default:
        return Colors.brown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[50],
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: $error',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchLeaderboard,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchLeaderboard,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                Icons.emoji_events,
                                size: 48,
                                color: Colors.amber.shade600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Top performers this month',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: leaderboard.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.leaderboard,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No leaderboard data available',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: leaderboard.length,
                                itemBuilder: (context, index) {
                                  final user = leaderboard[index];
                                  final rank = index + 1;
                                  final isTopThree = rank <= 3;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: isTopThree ? Border.all(
                                        color: const Color(0xFF2E4A6B).withOpacity(0.3),
                                        width: 2,
                                      ) : null,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      leading: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          getRankIcon(rank),
                                          const SizedBox(width: 8),
                                          Text(
                                            '#$rank',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: isTopThree
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                              color: isTopThree
                                                  ? const Color(0xFF2E4A6B)
                                                  : Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      title: Text(
                                        user['name'] ?? 'Unknown',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${user['monthlyPoints'] ?? 0} points this month',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      trailing: SizedBox(
                                        width: 80,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: getBadgeColor(user['badge']),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                user['badge'] ?? 'Bronze',
                                                style: TextStyle(
                                                  color: user['badge'] == 'Platinum'
                                                      ? Colors.black
                                                      : Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF2E4A6B).withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              child: Text(
                                                '${user['monthlyPoints'] ?? 0} pts',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF2E4A6B),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
}