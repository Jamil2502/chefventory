import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildModernActionCard(
                context,
                'Add Ingredient',
                'Stock new items',
                Icons.add_circle,
                AppTheme.primaryBrown,
                '🥬',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModernActionCard(
                context,
                'Process Order',
                'Handle requests',
                Icons.restaurant,
                AppTheme.secondaryBrown,
                '🍽️',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildModernActionCard(
                context,
                'Generate Report',
                'View analytics',
                Icons.analytics,
                AppTheme.successGreen,
                '📊',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModernActionCard(
                context,
                'Manage Users',
                'Staff accounts',
                Icons.people,
                AppTheme.warningYellow,
                '👥',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernActionCard(BuildContext context, String title, String subtitle, IconData icon, Color color, String emoji) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.black,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.grey,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
