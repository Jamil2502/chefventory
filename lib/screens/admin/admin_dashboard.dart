import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../inventory/inventory_screen.dart';
import '../orders/order_processing_screen.dart';
import '../analytics/analytics_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminHomeScreen(),
    const InventoryScreen(),
    const OrderProcessingScreen(),
    const AnalyticsScreen(),
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
        title: const Text('Chefventory Admin'),
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
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications'),
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
                    '${expired.length} items have expired',
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
                  const Text('No notifications'),
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

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Banner
          Container(
            height: 200,
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
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Positioned(
                  right: 40,
                  bottom: -10,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings,
                              size: 32,
                              color: AppTheme.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back, Admin!',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: AppTheme.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Manage your restaurant inventory efficiently',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          _buildBannerStat('Ingredients', '24', Icons.inventory),
                          const SizedBox(width: 20),
                          _buildBannerStat('Dishes', '12', Icons.restaurant_menu),
                          const SizedBox(width: 20),
                          _buildBannerStat('Orders', '8', Icons.shopping_cart),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Alert Center
          Text(
            'Alert Center',
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
                      expired.map((e) => e.name).join(', '),
                    ),
                  if (expiring.isNotEmpty)
                    _buildAlertCard(
                      'Expiring Soon',
                      '${expiring.length} items expiring in 3 days',
                      AppTheme.warningYellow,
                      Icons.warning,
                      expiring.map((e) => e.name).join(', '),
                    ),
                  if (lowStock.isNotEmpty)
                    _buildAlertCard(
                      'Low Stock',
                      '${lowStock.length} items are low on stock',
                      AppTheme.primaryBrown,
                      Icons.inventory_2,
                      lowStock.map((e) => e.name).join(', '),
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
                              'No alerts at the moment',
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
          // System Statistics
          Text(
            'System Statistics',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Consumer<InventoryProvider>(
            builder: (context, inventoryProvider, child) {
              final totalIngredients = inventoryProvider.inventory.ingredients.length;
              final totalDishes = inventoryProvider.dishes.length;
              final lowStockCount = inventoryProvider.lowStockIngredients.length;
              final expiringCount = inventoryProvider.expiringSoonIngredients.length;

              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Ingredients',
                      totalIngredients.toString(),
                      Icons.inventory,
                      AppTheme.primaryBrown,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Total Dishes',
                      totalDishes.toString(),
                      Icons.restaurant_menu,
                      AppTheme.brown,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
            Consumer<InventoryProvider>(
              builder: (context, inventoryProvider, child) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Low Stock',
                        inventoryProvider.lowStockIngredients.length.toString(),
                        Icons.trending_down,
                        AppTheme.warningYellow,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Expiring Soon',
                        inventoryProvider.expiringSoonIngredients.length.toString(),
                        Icons.schedule,
                        AppTheme.errorRed,
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
                  'Add Ingredient',
                  Icons.add_circle,
                  AppTheme.primaryBrown,
                  '🥬',
                  () => _navigateToInventory(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCardWithImage(
                  'Process Order',
                  Icons.restaurant,
                  AppTheme.accentBrown,
                  '🍽️',
                  () => _navigateToOrders(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionCardWithImage(
                  'View Analytics',
                  Icons.analytics,
                  AppTheme.warningYellow,
                  '📊',
                  () => _navigateToAnalytics(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionCardWithImage(
                  'Manage Users',
                  Icons.people,
                  AppTheme.successGreen,
                  '👥',
                  () => _navigateToUsers(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(String title, String subtitle, Color color, IconData icon, String details) {
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
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      details,
                      style: const TextStyle(
                        color: AppTheme.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.white.withOpacity(0.8),
            fontSize: 12,
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
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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

  void _navigateToAnalytics(BuildContext context) {
    // This will be handled by the parent widget's navigation
  }

  void _navigateToUsers(BuildContext context) {
    // This will be handled by the parent widget's navigation
  }
}
