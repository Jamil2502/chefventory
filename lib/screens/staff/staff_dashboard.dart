import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../inventory/inventory_screen.dart';
import '../orders/order_processing_screen.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({super.key});

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const StaffHomeScreen(),
    const InventoryScreen(),
    const OrderProcessingScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InventoryProvider>(context, listen: false).loadInventory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chefventory Staff'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: () => themeProvider.toggleTheme(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => _showNotifications(context),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppTheme.grey),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: AppTheme.primaryBrown,
        unselectedItemColor: AppTheme.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Orders',
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Today\'s Alerts'),
        content: Consumer<InventoryProvider>(
          builder: (context, inventoryProvider, child) {
            final lowStock = inventoryProvider.lowStockIngredients;
            final expiring = inventoryProvider.expiringSoonIngredients;
            final expired = inventoryProvider.expiredIngredients;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (expired.isNotEmpty) ...[
                  _buildNotificationItem(
                    'Expired Items',
                    '${expired.length} items need immediate attention',
                    AppTheme.errorRed,
                  ),
                  const SizedBox(height: 8),
                ],
                if (expiring.isNotEmpty) ...[
                  _buildNotificationItem(
                    'Expiring Soon',
                    '${expiring.length} items expiring in 3 days',
                    AppTheme.warningYellow,
                  ),
                  const SizedBox(height: 8),
                ],
                if (lowStock.isNotEmpty) ...[
                  _buildNotificationItem(
                    'Low Stock',
                    '${lowStock.length} items are low on stock',
                    AppTheme.primaryBrown,
                  ),
                ],
                if (expired.isEmpty && expiring.isEmpty && lowStock.isEmpty)
                  const Text('No alerts for today'),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(String title, String message, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class StaffHomeScreen extends StatelessWidget {
  const StaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Banner
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryBrown,
                  AppTheme.darkBrown,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                // Background Pattern
                Positioned(
                  right: -20,
                  top: -20,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  right: 30,
                  bottom: -10,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 28,
                              color: AppTheme.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Good day, Staff!',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: AppTheme.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ready to process orders and manage inventory',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildBannerStat('Today\'s Orders', '5', Icons.shopping_cart),
                          const SizedBox(width: 20),
                          _buildBannerStat('Low Stock', '2', Icons.warning),
                          const SizedBox(width: 20),
                          _buildBannerStat('Available', '18', Icons.check_circle),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Today's Alerts
          Text(
            'Today\'s Alerts',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Consumer<InventoryProvider>(
            
            builder: (context, inventoryProvider, child) {
              final lowStock = inventoryProvider.lowStockIngredients;
              final expiring = inventoryProvider.expiringSoonIngredients;
              final expired = inventoryProvider.expiredIngredients;

              return Column(
                children: [
                  if (expired.isNotEmpty)
                    _buildAlertCard(
                      'Expired Items',
                      '${expired.length} items have expired',
                      AppTheme.errorRed,
                      Icons.error,
                      'Check inventory immediately',
                    ),
                  if (expiring.isNotEmpty)
                    _buildAlertCard(
                      'Expiring Soon',
                      '${expiring.length} items expiring in 3 days',
                      AppTheme.warningYellow,
                      Icons.warning,
                      'Use these ingredients first',
                    ),
                  if (lowStock.isNotEmpty)
                    _buildAlertCard(
                      'Low Stock',
                      '${lowStock.length} items are low on stock',
                      AppTheme.primaryBrown,
                      Icons.inventory_2,
                      'Notify manager for restocking',
                    ),
                  if (expired.isEmpty && expiring.isEmpty && lowStock.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 48,
                              color: AppTheme.successGreen,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'All Good!',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'No alerts for today',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          // Quick Order Processing
          Text(
            'Quick Order Processing',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Consumer<InventoryProvider>(
            builder: (context, inventoryProvider, child) {
              final availableDishes = inventoryProvider.dishes
                  .where((dish) => inventoryProvider.canPrepareDish(dish))
                  .toList();

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Row(
                          children: [
                            Icon(
                              Icons.restaurant_menu,
                              color: AppTheme.primaryBrown,
                              size: 24,
                            ),
                          const SizedBox(width: 8),
                          Text(
                            'Available Dishes',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (availableDishes.isNotEmpty)
                        ...availableDishes.take(3).map((dish) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  dish.name,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                ),
                              ),
                              Text(
                                '\$${dish.basePrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: AppTheme.primaryBrown,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ))
                      else
                        const Text(
                          'No dishes available - check inventory',
                          style: TextStyle(color: AppTheme.grey),
                        ),
                      if (availableDishes.length > 3)
                        TextButton(
                          onPressed: () {
                            // Navigate to order processing
                          },
                          child: const Text('View All Dishes'),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          // Current Inventory Overview
          Text(
            'Current Inventory',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Consumer<InventoryProvider>(
            builder: (context, inventoryProvider, child) {
              final totalIngredients = inventoryProvider.inventory.ingredients.length;
              final lowStockCount = inventoryProvider.lowStockIngredients.length;

              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Items',
                      totalIngredients.toString(),
                      Icons.inventory,
                      AppTheme.primaryBrown,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Low Stock',
                      lowStockCount.toString(),
                      Icons.trending_down,
                      lowStockCount > 0 ? AppTheme.warningYellow : AppTheme.successGreen,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          // Quick Actions with Category Images
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCardWithImage(
                  'Process Order',
                  Icons.restaurant,
                  AppTheme.primaryBrown,
                  '🍽️',
                  () => _navigateToOrders(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCardWithImage(
                  'Check Inventory',
                  Icons.inventory,
                  AppTheme.accentBrown,
                  '📦',
                  () => _navigateToInventory(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCardWithImage(
                  'Add Stock',
                  Icons.add_box,
                  AppTheme.successGreen,
                  '📈',
                  () => _navigateToAddStock(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCardWithImage(
                  'View Reports',
                  Icons.assessment,
                  AppTheme.warningYellow,
                  '📊',
                  () => _navigateToReports(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(String title, String subtitle, Color color, IconData icon, String action) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
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
                  const SizedBox(height: 4),
                  Text(
                    action,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: AppTheme.white, size: 16),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.white.withOpacity(0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCardWithImage(String title, IconData icon, Color color, String emoji, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToInventory(BuildContext context) {
    // This will be handled by the parent widget's navigation
  }

  void _navigateToOrders(BuildContext context) {
    // This will be handled by the parent widget's navigation
  }

  void _navigateToAddStock(BuildContext context) {
    // This will be handled by the parent widget's navigation
  }

  void _navigateToReports(BuildContext context) {
    // This will be handled by the parent widget's navigation
  }
}
