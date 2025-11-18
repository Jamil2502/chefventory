import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/order_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/currency.dart';
import '../../services/activity_service.dart';
import '../../models/dish.dart';

class OrderProcessingScreen extends StatefulWidget {
  const OrderProcessingScreen({super.key});

  @override
  State<OrderProcessingScreen> createState() => _OrderProcessingScreenState();
}

class _OrderProcessingScreenState extends State<OrderProcessingScreen> {
  final List<Dish> _selectedDishes = [];
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Starters',
    'Salads',
    'Main Course',
    'Sides',
    'Rice & Bowls',
    'Breads & Flatbreads',
    'Pasta & Noodles',
    'Pizzas',
    'Burgers & Wraps',
    'Grills & BBQ',
    'Breakfast',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16.0),
            color: AppTheme.white,
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search dishes...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 12),
                // Category Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedCategory = category);
                          },
                          selectedColor: AppTheme.primaryBrown.withOpacity(0.2),
                          checkmarkColor: AppTheme.primaryBrown,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Dishes List
          Expanded(
            child: StreamBuilder<List<Dish>>(
              stream: Provider.of<InventoryProvider>(context, listen: false).watchDishes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
                        const SizedBox(height: 16),
                        Text('Error: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                List<Dish> dishes = snapshot.data ?? [];

                // Apply category filter
                if (_selectedCategory != 'All') {
                  dishes = dishes.where((dish) => dish.category == _selectedCategory).toList();
                }

                // Apply search filter
                if (_searchController.text.isNotEmpty) {
                  dishes = dishes
                      .where((dish) => dish.name
                          .toLowerCase()
                          .contains(_searchController.text.toLowerCase()))
                      .toList();
                }

                if (dishes.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: AppTheme.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No dishes available',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: dishes.length,
                  itemBuilder: (context, index) {
                    final dish = dishes[index];
                    final canPrepare = Provider.of<InventoryProvider>(context, listen: false).canPrepareDish(dish);
                    final isSelected = _selectedDishes.any((d) => d.dishId == dish.dishId);
                    final quantity = _selectedDishes.where((d) => d.dishId == dish.dishId).length;

                    return _buildDishCard(dish, canPrepare, isSelected, quantity, context);
                  },
                );
              },
            ),
          ),
          // Order Summary
          if (_selectedDishes.isNotEmpty) _buildOrderSummary(),
        ],
      ),
    );
  }

  Widget _buildDishCard(Dish dish, bool canPrepare, bool isSelected, int quantity, BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dish.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dish.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              CurrencyService.formatInr(dish.basePrice),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppTheme.primaryBrown,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBrown.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              dish.category,
                              style: const TextStyle(
                                color: AppTheme.primaryBrown,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    // Availability Status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: canPrepare
                            ? AppTheme.successGreen.withOpacity(0.1)
                            : AppTheme.errorRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: canPrepare ? AppTheme.successGreen : AppTheme.errorRed,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            canPrepare ? Icons.check_circle : Icons.cancel,
                            size: 16,
                            color: canPrepare ? AppTheme.successGreen : AppTheme.errorRed,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            canPrepare ? 'Available' : 'Out of Stock',
                            style: TextStyle(
                              color: canPrepare ? AppTheme.successGreen : AppTheme.errorRed,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Quantity Controls
                    if (canPrepare)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: quantity > 0 ? () => _removeDish(dish) : null,
                            color: AppTheme.primaryBrown,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.lightGrey,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              quantity.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => _addDish(dish),
                            color: AppTheme.primaryBrown,
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            // Ingredient Requirements
            if (!canPrepare) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.errorRed.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Missing Ingredients:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.errorRed,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Consumer<InventoryProvider>(
                      builder: (context, inventoryProvider, child) {
                        final missingIngredients = <String>[];
                        for (var entry in dish.ingredientRequirements.entries) {
                          final ingredient = inventoryProvider.inventory.getIngredient(entry.key);
                          if (ingredient == null || ingredient.currentStock < entry.value) {
                            missingIngredients.add(ingredient?.name ?? 'Unknown');
                          }
                        }
                        return Text(
                          missingIngredients.join(', '),
                          style: const TextStyle(
                            color: AppTheme.errorRed,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    final totalPrice = _selectedDishes.fold<double>(
      0.0,
      (sum, dish) => sum + dish.basePrice,
    );

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: AppTheme.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Summary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${_selectedDishes.length} items',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                CurrencyService.formatInr(totalPrice),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryBrown,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearOrder,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: AppTheme.grey),
                  ),
                  child: const Text('Clear Order'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _processOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Process Order',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addDish(Dish dish) {
    print('➕ Adding dish: ${dish.name} (${dish.dishId})');
    setState(() {
      _selectedDishes.add(dish);
      print('   Total dishes now: ${_selectedDishes.length}');
    });
  }

  void _removeDish(Dish dish) {
    print('➖ Removing dish: ${dish.name} (${dish.dishId})');
    print('   Current total: ${_selectedDishes.length}');
    
    // Find and remove the first occurrence of this dish by ID
    final indexToRemove = _selectedDishes.indexWhere((d) => d.dishId == dish.dishId);
    
    if (indexToRemove >= 0) {
      setState(() {
        _selectedDishes.removeAt(indexToRemove);
        print('   Removed at index: $indexToRemove');
        print('   New total: ${_selectedDishes.length}');
      });
    } else {
      print('   ❌ Dish not found in selected list!');
    }
  }

  void _clearOrder() {
    setState(() {
      _selectedDishes.clear();
    });
  }

  Future<void> _processOrder() async {
    if (_selectedDishes.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cream,
        title: const Text('Confirm Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Process order with ${_selectedDishes.length} items?'),
            const SizedBox(height: 12),
            Text(
              'Total: ${CurrencyService.formatInr(_selectedDishes.fold<double>(0.0, (sum, dish) => sum + dish.basePrice))}',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBrown,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.primaryBrown)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBrown,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Process'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      // Save order to Firestore first
      final orderSaved = await orderProvider.processOrder(_selectedDishes);

      if (!orderSaved) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(orderProvider.errorMessage ?? 'Failed to save order'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
        return;
      }

      // Then consume stock from inventory
      final success = await inventoryProvider.processOrder(_selectedDishes);

      if (success && context.mounted) {
        // Log the order activity
        final dishNames = _selectedDishes.map((d) => d.name).join(', ');
        final totalPrice = _selectedDishes.fold<double>(0.0, (sum, dish) => sum + dish.basePrice);
        await ActivityService().logActivity(
          restaurantId: inventoryProvider.restaurantId,
          type: 'order_completed',
          itemName: '${_selectedDishes.length} dishes',
          description: 'Dishes: $dishNames | Total: ${CurrencyService.formatInr(totalPrice)}',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order processed! ${_selectedDishes.length} items consumed.'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        _clearOrder();
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(inventoryProvider.errorMessage ?? 'Failed to process order'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }
}
