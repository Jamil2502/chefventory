import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../inventory/inventory_screen.dart';
import '../orders/order_processing_screen.dart';
import '../auth/login_screen.dart';
import 'widgets/todays_alerts_widget.dart';
import 'widgets/quick_order_processing_widget.dart';
import 'widgets/current_inventory_widget.dart';

class ModernStaffDashboard extends StatefulWidget {
  const ModernStaffDashboard({super.key});

  @override
  State<ModernStaffDashboard> createState() => _ModernStaffDashboardState();
}

class _ModernStaffDashboardState extends State<ModernStaffDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const ModernStaffHomeScreen(),
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
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: AppTheme.primaryBrown,
          unselectedItemColor: AppTheme.grey,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Inventory',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart),
              label: 'Orders',
            ),
          ],
        ),
      ),
    );
  }

}

class ModernStaffHomeScreen extends StatelessWidget {
  const ModernStaffHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.cream,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildModernHeader(context),
            
            const SizedBox(height: 44),
            
            _buildWelcomeSection(context),
            
            const SizedBox(height: 24),
            
            _buildSection(
              context,
              'Today\'s Alerts',
              const TodaysAlertsWidget(),
            ),
            
            _buildSection(
              context,
              'Quick Order Processing',
              const QuickOrderProcessingWidget(),
            ),
            
            _buildSection(
              context,
              'Current Inventory',
              const CurrentInventoryWidget(),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryBrown,
            AppTheme.primaryBrown.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => _showUserMenu(context),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBrown,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppTheme.white,
                    size: 32,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        const Icon(
                          Icons.search,
                          color: AppTheme.grey,
                          size: 22,
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'Search inventory & dishes',
                            style: TextStyle(
                              color: AppTheme.grey,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryBrown,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.tune,
                            color: AppTheme.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back!',
            style: const TextStyle(
              color: AppTheme.black,
              fontWeight: FontWeight.bold,
              fontSize: 34,
            ),
          ),
          Text(
            'Kitchen Staff',
            style: const TextStyle(
              color: AppTheme.grey,
              fontSize: 26,
            ),
          ),
        ],
      ),
    );
  }

  void _showUserMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryBrown,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppTheme.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Kitchen Staff',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'staff1@restaurant.com',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: AppTheme.errorRed),
                title: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: AppTheme.errorRed,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _handleSignOut(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleSignOut(BuildContext context) {
    Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.black,
                ),
              ),
              Text(
                'View All',
                style: const TextStyle(
                  color: AppTheme.secondaryBrown,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          content,
        ],
      ),
    );
  }
}
