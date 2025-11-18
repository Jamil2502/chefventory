import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../../services/activity_service.dart';
import '../../../services/auth_service.dart';

class RecentActivityWidget extends StatelessWidget {
  const RecentActivityWidget({super.key});

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return FutureBuilder<Map<String, dynamic>?>(
      future: authService.getCurrentUser(),
      builder: (context, userSnapshot) {
        if (!userSnapshot.hasData || userSnapshot.data == null) {
          return _buildEmptyState();
        }

        final restaurantId = userSnapshot.data!['restaurantId'] as String? ?? 'rest_001';

        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: ActivityService().watchActivities(restaurantId, limit: 10),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final activities = snapshot.data!;

            return Column(
              children: activities.map((activity) {
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
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBrown.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.black,
                                fontSize: 14,
                              ),
                            ),
                            if ((activity['description'] as String).isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  activity['description'] as String,
                                  style: const TextStyle(
                                    color: AppTheme.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        timeAgo,
                        style: const TextStyle(
                          color: AppTheme.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 48, color: AppTheme.grey),
            const SizedBox(height: 12),
            const Text(
              'No recent activities',
              style: TextStyle(color: AppTheme.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}


