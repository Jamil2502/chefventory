import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class RecentActivityWidget extends StatelessWidget {
  const RecentActivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = [
      {
        'title': 'Tomatoes restocked',
        'subtitle': '50 kg added to inventory',
        'time': '5 min ago',
        'icon': Icons.add_circle,
        'color': AppTheme.successGreen,
      },
      {
        'title': 'Order #1247 processed',
        'subtitle': 'Pasta Marinara x3',
        'time': '12 min ago',
        'icon': Icons.restaurant,
        'color': AppTheme.primaryBrown,
      },
      {
        'title': 'User login: John Doe',
        'subtitle': 'Kitchen staff access',
        'time': '1 hour ago',
        'icon': Icons.person,
        'color': AppTheme.secondaryBrown,
      },
      {
        'title': 'Low stock alert',
        'subtitle': 'Cheese below threshold',
        'time': '2 hours ago',
        'icon': Icons.warning,
        'color': AppTheme.warningYellow,
      },
    ];

    return Column(
      children: activities.map((activity) => _buildActivityItem(
        context,
        activity['title'] as String,
        activity['subtitle'] as String,
        activity['time'] as String,
        activity['icon'] as IconData,
        activity['color'] as Color,
      )).toList(),
    );
  }

  Widget _buildActivityItem(BuildContext context, String title, String subtitle, String time, IconData icon, Color color) {
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
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.black,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: AppTheme.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
