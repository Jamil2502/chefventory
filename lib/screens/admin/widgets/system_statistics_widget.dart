import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/inventory_provider.dart';
import '../../../providers/order_provider.dart';
import '../../../models/ingredient.dart';
import '../../../models/dish.dart';
import '../../../theme/app_theme.dart';

class SystemStatisticsWidget extends StatelessWidget {
  const SystemStatisticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StreamBuilder<List<Ingredient>>(
                stream: Provider.of<InventoryProvider>(context, listen: false).watchIngredients(),
                builder: (context, snapshot) {
                  final totalIngredients = snapshot.data?.length ?? 0;
                  return _buildModernStatCard(
                    context,
                    'Total Ingredients',
                    totalIngredients.toString(),
                    Icons.inventory_2,
                    AppTheme.primaryBrown,
                    '📊',
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StreamBuilder<List<Dish>>(
                stream: Provider.of<InventoryProvider>(context, listen: false).watchDishes(),
                builder: (context, snapshot) {
                  final totalDishes = snapshot.data?.length ?? 0;
                  return _buildModernStatCard(
                    context,
                    'Total Dishes',
                    totalDishes.toString(),
                    Icons.restaurant_menu,
                    AppTheme.secondaryBrown,
                    '🍽️',
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: Provider.of<InventoryProvider>(context, listen: false).watchIngredients().asyncMap((_) async {
                  final count = await Provider.of<OrderProvider>(context, listen: false).getTodayOrdersCount();
                  return List.filled(count, {});
                }),
                builder: (context, snapshot) {
                  final ordersToday = snapshot.data?.length ?? 0;
                  return _buildModernStatCard(
                    context,
                    'Orders Today',
                    ordersToday.toString(),
                    Icons.shopping_cart,
                    AppTheme.successGreen,
                    '📦',
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FutureBuilder<double>(
                future: Provider.of<OrderProvider>(context, listen: false).getTodayRevenue(),
                builder: (context, snapshot) {
                  double revenue = snapshot.data ?? 0;
                  final value = revenue > 1000 ? '₹${(revenue / 1000).toStringAsFixed(1)}K' : '₹${revenue.toStringAsFixed(0)}';
                  return _buildModernStatCard(
                    context,
                    'Revenue Today',
                    value,
                    Icons.attach_money,
                    AppTheme.warningYellow,
                    '💰',
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernStatCard(BuildContext context, String title, String value, IconData icon, Color color, String emoji) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}


