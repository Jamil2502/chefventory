import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Analytics Overview',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track your inventory performance and trends',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.grey,
              ),
            ),
            const SizedBox(height: 24),
            
            // Key Metrics
            Text(
              'Key Metrics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Consumer<InventoryProvider>(
              builder: (context, inventoryProvider, child) {
                final totalIngredients = inventoryProvider.inventory.ingredients.length;
                final lowStockCount = inventoryProvider.lowStockIngredients.length;
                final expiringCount = inventoryProvider.expiringSoonIngredients.length;
                final totalDishes = inventoryProvider.dishes.length;

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            'Total Ingredients',
                            totalIngredients.toString(),
                            Icons.inventory,
                            AppTheme.primaryBrown,
                            'Items in inventory',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            'Total Dishes',
                            totalDishes.toString(),
                            Icons.restaurant_menu,
                            AppTheme.secondaryBrown,
                            'Configured dishes',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            'Low Stock',
                            lowStockCount.toString(),
                            Icons.trending_down,
                            AppTheme.warningYellow,
                            'Items below threshold',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            'Expiring Soon',
                            expiringCount.toString(),
                            Icons.schedule,
                            AppTheme.errorRed,
                            'Items expiring within 7 days',
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            
            // Inventory Health
            Text(
              'Inventory Health',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Consumer<InventoryProvider>(
              builder: (context, inventoryProvider, child) {
                final totalIngredients = inventoryProvider.inventory.ingredients.length;
                final healthyCount = totalIngredients - 
                    inventoryProvider.lowStockIngredients.length - 
                    inventoryProvider.expiringSoonIngredients.length - 
                    inventoryProvider.expiredIngredients.length;
                
                final healthPercentage = totalIngredients > 0 
                    ? (healthyCount / totalIngredients * 100).round()
                    : 0;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Overall Health',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '$healthPercentage%',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: _getHealthColor(healthPercentage),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: healthPercentage / 100,
                          backgroundColor: AppTheme.lightGrey,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getHealthColor(healthPercentage),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildHealthItem('Healthy', healthyCount, AppTheme.successGreen),
                            _buildHealthItem('Low Stock', inventoryProvider.lowStockIngredients.length, AppTheme.warningYellow),
                            _buildHealthItem('Expiring', inventoryProvider.expiringSoonIngredients.length, AppTheme.primaryBrown),
                            _buildHealthItem('Expired', inventoryProvider.expiredIngredients.length, AppTheme.errorRed),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            
            // Top Consumed Ingredients
            Text(
              'Top Consumed Ingredients',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildTopIngredientsCard(),
            const SizedBox(height: 24),
            
            // Waste Tracking
            Text(
              'Waste Tracking',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildWasteTrackingCard(),
            const SizedBox(height: 24),
            
            // Usage Patterns
            Text(
              'Usage Patterns',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildUsagePatternsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppTheme.grey,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getHealthColor(int percentage) {
    if (percentage >= 80) return AppTheme.successGreen;
    if (percentage >= 60) return AppTheme.warningYellow;
    return AppTheme.errorRed;
  }

  Widget _buildHealthItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTopIngredientsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<InventoryProvider>(
          builder: (context, inventoryProvider, _) {
            final ingredients = inventoryProvider.inventory.ingredients.values.toList();
            
            if (ingredients.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'No ingredients available. Add ingredients to see analytics.',
                    style: TextStyle(color: AppTheme.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            // Sort by stock quantity and show top 5
            ingredients.sort((a, b) => b.currentStock.compareTo(a.currentStock));
            final topIngredients = ingredients.take(5).toList();

            return Column(
              children: topIngredients.map((ingredient) {
                final maxStock = 100.0; // Reference max for percentage
                final percentage = ((ingredient.currentStock / maxStock) * 100).clamp(0, 100).toInt();
                final color = percentage > 70 ? AppTheme.successGreen : 
                             percentage > 40 ? AppTheme.warningYellow : AppTheme.errorRed;
                
                return _buildIngredientItem(
                  ingredient.name,
                  '${ingredient.currentStock.toStringAsFixed(1)} ${ingredient.unit}',
                  percentage,
                  color,
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIngredientItem(String name, String amount, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppTheme.lightGrey,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildWasteTrackingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'This Week',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.successGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Good',
                    style: TextStyle(
                      color: AppTheme.successGreen,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildWasteItem('Items Wasted', '3', AppTheme.errorRed),
                ),
                Expanded(
                  child: _buildWasteItem('Value Lost', '₹24.50', AppTheme.warningYellow),
                ),
                Expanded(
                  child: _buildWasteItem('Waste Rate', '2.1%', AppTheme.successGreen),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWasteItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.grey,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUsagePatternsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Peak Usage Times',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            _buildTimeSlot('12:00 PM - 2:00 PM', 'Lunch Rush', 95, AppTheme.primaryBrown),
            _buildTimeSlot('6:00 PM - 8:00 PM', 'Dinner Rush', 88, AppTheme.secondaryBrown),
            _buildTimeSlot('11:00 AM - 12:00 PM', 'Pre-Lunch', 65, AppTheme.warningYellow),
            _buildTimeSlot('3:00 PM - 5:00 PM', 'Afternoon', 45, AppTheme.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlot(String time, String label, int percentage, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage / 100,
            backgroundColor: AppTheme.lightGrey,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }
}
