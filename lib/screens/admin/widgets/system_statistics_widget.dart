import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/inventory_provider.dart';
import '../../../theme/app_theme.dart';

class SystemStatisticsWidget extends StatelessWidget {
  const SystemStatisticsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, child) {
        final totalIngredients = inventoryProvider.inventory.ingredients.length;
        final totalDishes = inventoryProvider.dishes.length;
        
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildModernStatCard(
                    context,
                    'Total Ingredients',
                    totalIngredients.toString(),
                    Icons.inventory_2,
                    AppTheme.primaryBrown,
                    '+12%',
                    true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModernStatCard(
                    context,
                    'Total Dishes',
                    totalDishes.toString(),
                    Icons.restaurant_menu,
                    AppTheme.secondaryBrown,
                    '+8%',
                    true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildModernStatCard(
                    context,
                    'Orders Today',
                    '24',
                    Icons.shopping_cart,
                    AppTheme.successGreen,
                    '+15%',
                    true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildModernStatCard(
                    context,
                    'Inventory Value',
                    '₹12.5K',
                    Icons.attach_money,
                    AppTheme.warningYellow,
                    '+5%',
                    true,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildModernStatCard(BuildContext context, String title, String value, IconData icon, Color color, String change, bool isPositive) {
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
                child: Icon(icon, color: color, size: 20),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive ? AppTheme.successGreen.withOpacity(0.1) : AppTheme.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: isPositive ? AppTheme.successGreen : AppTheme.errorRed,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
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
