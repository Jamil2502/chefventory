import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/inventory_provider.dart';
import '../../../theme/app_theme.dart';

class CurrentInventoryWidget extends StatelessWidget {
  const CurrentInventoryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, inventoryProvider, child) {
        final totalIngredients = inventoryProvider.inventory.ingredients.length;
        final lowStockCount = inventoryProvider.lowStockIngredients.length;
        final expiringCount = inventoryProvider.expiringSoonIngredients.length;
        
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildModernStatCard(
                    'Total Items',
                    totalIngredients.toString(),
                    Icons.inventory_2,
                    AppTheme.primaryBrown,
                    '',
                    true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModernStatCard(
                    'Low Stock',
                    lowStockCount.toString(),
                    Icons.trending_down,
                    lowStockCount > 0 ? AppTheme.warningYellow : AppTheme.successGreen,
                    lowStockCount > 0 ? '⚠️' : '✓',
                    lowStockCount == 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildModernStatCard(
                    'Expiring Soon',
                    expiringCount.toString(),
                    Icons.schedule,
                    expiringCount > 0 ? AppTheme.warningYellow : AppTheme.successGreen,
                    expiringCount > 0 ? '⏰' : '✓',
                    expiringCount == 0,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModernStatCard(
                    'Stock Status',
                    'Healthy',
                    Icons.check_circle,
                    AppTheme.successGreen,
                    '✓',
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

  Widget _buildModernStatCard(String title, String value, IconData icon, Color color, String change, bool isPositive) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isPositive ? AppTheme.successGreen.withOpacity(0.1) : AppTheme.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    color: isPositive ? AppTheme.successGreen : AppTheme.errorRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.grey,
            ),
          ),
        ],
      ),
    );
  }
}


