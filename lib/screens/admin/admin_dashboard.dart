import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../inventory/inventory_screen.dart';
import '../orders/order_processing_screen.dart';
import 'widgets/alert_center_widget.dart';
import 'widgets/system_statistics_widget.dart';
import 'widgets/recent_activity_widget.dart';
import 'widgets/quick_actions_widget.dart';
import 'widgets/all_activities_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      AdminHomeScreen(onSelectIndex: (index) => setState(() => _selectedIndex = index)),
      const InventoryScreen(),
      const OrderProcessingScreen(),
    ];
    
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

class AdminHomeScreen extends StatefulWidget {
  final Function(int)? onSelectIndex;
  
  const AdminHomeScreen({super.key, this.onSelectIndex});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  void _performSearch(String query) {
    _searchDebounce?.cancel();
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      final provider = Provider.of<InventoryProvider>(context, listen: false);
      final results = provider.searchIngredients(query);
      if (mounted) {
        setState(() => _searchResults = results);
      }
    });
  }

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
            const SizedBox(height: 32),
            _buildWelcomeSection(context),
            const SizedBox(height: 32),
            _buildSection(context, 'Alert Center', const AlertCenterWidget()),
            const SizedBox(height: 16),
            _buildSection(context, 'System Statistics', const SystemStatisticsWidget()),
            const SizedBox(height: 24),
            _buildSection(context, 'Recent Activity', const RecentActivityWidget()),
            const SizedBox(height: 16),
            _buildSection(context, 'Quick Actions', const QuickActionsWidget()),
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
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryBrown,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person,
                        color: AppTheme.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(16),
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
                        const SizedBox(width: 16),
                        const Icon(Icons.search, color: AppTheme.grey, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _performSearch,
                            decoration: const InputDecoration(
                              hintText: 'Search your inventory',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: AppTheme.grey, fontSize: 16),
                            ),
                            style: const TextStyle(fontSize: 16, color: AppTheme.black),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _showInventoryFilterModal(context);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryBrown,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.tune, color: AppTheme.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.notifications_outlined, color: AppTheme.white, size: 22),
                ),
              ],
            ),
            if (_searchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: AppTheme.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final ingredient = _searchResults[index];
                    return ListTile(
                      title: Text(ingredient.name),
                      subtitle: Text('${ingredient.currentStock} ${ingredient.unit}'),
                      trailing: Icon(
                        ingredient.isLowStock() ? Icons.warning : Icons.check,
                        color: ingredient.isLowStock() ? AppTheme.errorRed : AppTheme.successGreen,
                        size: 18,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final username = authProvider.currentUser?['username'] ?? 'Chef';
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Welcome back, ',
                      style: TextStyle(
                        color: AppTheme.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 28,
                      ),
                    ),
                    TextSpan(
                      text: username,
                      style: const TextStyle(
                        color: AppTheme.primaryBrown,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUserMenu(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final username = authProvider.currentUser?['username'] ?? 'Admin';
    final email = authProvider.currentUser?['email'] ?? 'admin@restaurant.com';
    final restaurantId = authProvider.currentUser?['restaurantId'] ?? 'N/A';
    final role = authProvider.currentUser?['role'] ?? 'admin';
    
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
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.secondaryBrown,
                            AppTheme.primaryBrown,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(35),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.secondaryBrown.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person, color: AppTheme.white, size: 36),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryBrown.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Role: ${role.toUpperCase()}',
                            style: const TextStyle(
                              color: AppTheme.primaryBrown,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryBrown.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            restaurantId,
                            style: const TextStyle(
                              color: AppTheme.secondaryBrown,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  Widget _buildSection(BuildContext context, String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
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
                  fontSize: 18,
                ),
              ),
              if (title == 'Recent Activity')
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllActivitiesScreen()),
                  ),
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: AppTheme.secondaryBrown,
                      fontWeight: FontWeight.w500,
                    ),
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

  void _showInventoryFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        String selected = 'All';
        final provider = Provider.of<InventoryProvider>(context, listen: false);
        List filtered = provider.inventory.ingredients.values.toList();
        return StatefulBuilder(builder: (context, setState) {
          void applyFilter(String f) {
            setState(() => selected = f);
            final all = provider.inventory.ingredients.values.toList();
            switch (f) {
              case 'Low Stock':
                filtered = all.where((e) => e.isLowStock()).toList();
                break;
              case 'Expiring Soon':
                filtered = all.where((e) => e.isExpiringSoon(7)).toList();
                break;
              case 'Expired':
                filtered = all.where((e) => e.isExpired()).toList();
                break;
              default:
                filtered = all;
            }
          }

          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Filter Inventory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: ['All', 'Low Stock', 'Expiring Soon', 'Expired'].map((f) {
                    final isSelected = selected == f;
                    return ChoiceChip(
                      label: Text(f),
                      selected: isSelected,
                      onSelected: (_) => applyFilter(f),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: filtered.isEmpty
                      ? const Center(child: Text('No items for selected filter'))
                      : ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final ing = filtered[index];
                            return ListTile(
                              title: Text(ing.name),
                              subtitle: Text('${ing.currentStock} ${ing.unit}'),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}

