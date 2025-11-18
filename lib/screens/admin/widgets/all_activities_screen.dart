import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../../services/activity_service.dart';
import '../../../services/auth_service.dart';

class AllActivitiesScreen extends StatelessWidget {
  const AllActivitiesScreen({super.key});

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        title: const Text('All Activities'),
        backgroundColor: AppTheme.primaryBrown,
        elevation: 0,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: authService.getCurrentUser(),
        builder: (context, userSnapshot) {
          if (!userSnapshot.hasData || userSnapshot.data == null) {
            return _buildEmptyState();
          }

          final restaurantId = userSnapshot.data!['restaurantId'] as String? ?? 'rest_001';

          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: ActivityService().watchActivities(restaurantId, limit: 100),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return _buildEmptyState();
              }

              final activities = snapshot.data!;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  final timeAgo = _getTimeAgo(activity['timestamp'] as DateTime);
                  final message = ActivityService.getActivityMessage(activity);
                  final emoji = ActivityService.getActivityEmoji(activity['type'] as String);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBrown.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.black,
                                  fontSize: 15,
                                ),
                              ),
                              if ((activity['description'] as String).isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    activity['description'] as String,
                                    style: const TextStyle(
                                      color: AppTheme.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  timeAgo,
                                  style: const TextStyle(
                                    color: AppTheme.grey,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: AppTheme.grey),
            const SizedBox(height: 16),
            const Text(
              'No activities yet',
              style: TextStyle(color: AppTheme.grey, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Activities will appear here',
              style: TextStyle(color: AppTheme.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
