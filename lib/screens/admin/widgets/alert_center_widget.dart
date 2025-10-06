import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/inventory_provider.dart';
import '../../../theme/app_theme.dart';

class AlertCenterWidget extends StatelessWidget {
  const AlertCenterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, child) {
        final expired = inventoryProvider.expiredIngredients;
        final expiring = inventoryProvider.expiringSoonIngredients;
        final lowStock = inventoryProvider.lowStockIngredients;

        if (expired.isEmpty && expiring.isEmpty && lowStock.isEmpty) {
          return _buildEmptyStateCard(
            context,
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
                context,
                'Expired Items',
                '${expired.length} items need immediate attention',
                '${expired.length}',
                Icons.error,
                AppTheme.errorRed,
                expired.take(3).map((e) => e.name).join(', '),
              ),
            if (expiring.isNotEmpty)
              _buildModernAlertCard(
                context,
                'Expiring Soon',
                '${expiring.length} items expiring in 3 days',
                '${expiring.length}',
                Icons.schedule,
                AppTheme.warningYellow,
                expiring.take(3).map((e) => e.name).join(', '),
              ),
            if (lowStock.isNotEmpty)
              _buildModernAlertCard(
                context,
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

  Widget _buildModernAlertCard(BuildContext context, String title, String subtitle, String count, IconData icon, Color color, String items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.grey,
                    fontSize: 14,
                  ),
                ),
                if (items.isNotEmpty) ...[
                  const SizedBox(height: 4),
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
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                count,
                style: const TextStyle(
                  color: AppTheme.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyStateCard(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.grey,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
