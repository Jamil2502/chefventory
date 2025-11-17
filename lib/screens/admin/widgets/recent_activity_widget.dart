import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/inventory_provider.dart';
import '../../../theme/app_theme.dart';

class RecentActivityWidget extends StatelessWidget {
  const RecentActivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, child) {
        final activities = _generateActivitiesFromSampleData(inventoryProvider);

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
      },
    );
  }

  List<Map<String, dynamic>> _generateActivitiesFromSampleData(InventoryProvider inventoryProvider) {
    final activities = <Map<String, dynamic>>[];
    
    // Add order activities from sample data
    for (var order in inventoryProvider.orders.take(2)) {
      final orderTime = order['timestamp'] as DateTime;
      activities.add({
        'title': 'Order #${order['orderId'].toString().substring(6)} processed',
        'subtitle': '${order['dishName']} x${order['quantity']}',
        'time': '${DateTime.now().difference(orderTime).inMinutes} min ago',
        'icon': Icons.restaurant,
        'color': AppTheme.primaryBrown,
      });
    }
    
    // Add ingredient activities based on sample data
    final lowStockIngredients = inventoryProvider.lowStockIngredients;
    if (lowStockIngredients.isNotEmpty) {
      activities.add({
        'title': 'Low stock alert',
        'subtitle': '${lowStockIngredients.first.name} below threshold',
        'time': '1 hour ago',
        'icon': Icons.warning,
        'color': AppTheme.warningYellow,
      });
    }
    
    final expiredIngredients = inventoryProvider.expiredIngredients;
    if (expiredIngredients.isNotEmpty) {
      activities.add({
        'title': 'Expired ingredient',
        'subtitle': '${expiredIngredients.first.name} needs attention',
        'time': '2 hours ago',
        'icon': Icons.error,
        'color': AppTheme.errorRed,
      });
    }
    
    // Add a restocking activity
    activities.add({
      'title': 'Tomatoes restocked',
      'subtitle': '5kg added to inventory',
      'time': '3 hours ago',
      'icon': Icons.add_circle,
      'color': AppTheme.successGreen,
    });
    
    return activities;
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
