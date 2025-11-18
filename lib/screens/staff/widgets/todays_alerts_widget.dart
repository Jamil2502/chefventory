import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/inventory_provider.dart';
import '../../../theme/app_theme.dart';

class TodaysAlertsWidget extends StatelessWidget {
  const TodaysAlertsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, child) {
        final expired = inventoryProvider.expiredIngredients;
        final expiring = inventoryProvider.expiringSoonIngredients;
        final lowStock = inventoryProvider.lowStockIngredients;

        if (expired.isEmpty && expiring.isEmpty && lowStock.isEmpty) {
          return _buildEmptyStateCard(
            'All Good!',
            'No critical alerts at the moment',
            Icons.check_circle,
            AppTheme.successGreen,
          );
        }

        return Column(
          children: [
            if (expired.isNotEmpty)
              _buildModernAlertCard(
                'Expired Items',
                '${expired.length} items need immediate attention',
                '${expired.length}',
                Icons.error,
                AppTheme.errorRed,
                expired.take(3).map((e) => e.name).join(', '),
              ),
            if (expired.isNotEmpty && expiring.isNotEmpty) const SizedBox(height: 16),
            if (expiring.isNotEmpty)
              _buildModernAlertCard(
                'Expiring Soon',
                '${expiring.length} items expiring soon',
                '${expiring.length}',
                Icons.schedule,
                AppTheme.warningYellow,
                expiring.take(3).map((e) => e.name).join(', '),
              ),
            if ((expired.isNotEmpty || expiring.isNotEmpty) && lowStock.isNotEmpty) const SizedBox(height: 16),
            if (lowStock.isNotEmpty)
              _buildModernAlertCard(
                'Low Stock',
                '${lowStock.length} items need restocking',
                '${lowStock.length}',
                Icons.inventory_2,
                AppTheme.primaryBrown,
                lowStock.take(3).map((e) => e.name).join(', '),
              ),
          ],
        );
      },
    );
  }

  Widget _buildModernAlertCard(String title, String subtitle, String count, IconData icon, Color color, String items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: AppTheme.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.grey,
                    fontSize: 14,
                  ),
                ),
                if (items.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    items,
                    style: const TextStyle(
                      color: AppTheme.grey,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                count,
                style: const TextStyle(
                  color: AppTheme.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 36),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


