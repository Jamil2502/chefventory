import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/ingredient.dart';
import 'add_ingredient_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<String> _filterOptions = ['All', 'Low Stock', 'Expiring Soon', 'Expired'];

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
                    hintText: 'Search ingredients...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: 12),
                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filterOptions.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => _selectedFilter = filter);
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
          // Inventory List
          Expanded(
            child: Consumer<InventoryProvider>(
              builder: (context, inventoryProvider, child) {
                if (inventoryProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                List<Ingredient> ingredients = inventoryProvider.inventory.ingredients.values.toList();

                // Apply search filter
                if (_searchQuery.isNotEmpty) {
                  ingredients = ingredients
                      .where((ingredient) =>
                          ingredient.name.toLowerCase().contains(_searchQuery.toLowerCase()))
                      .toList();
                }

                // Apply category filter
                switch (_selectedFilter) {
                  case 'Low Stock':
                    ingredients = ingredients.where((ingredient) => ingredient.isLowStock()).toList();
                    break;
                  case 'Expiring Soon':
                    ingredients = ingredients.where((ingredient) => ingredient.isExpiringSoon(3)).toList();
                    break;
                  case 'Expired':
                    ingredients = ingredients.where((ingredient) => ingredient.isExpired()).toList();
                    break;
                }

                if (ingredients.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isNotEmpty ? Icons.search_off : Icons.inventory_2_outlined,
                          size: 64,
                          color: AppTheme.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'No ingredients found for "$_searchQuery"'
                              : 'No ingredients found',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.grey,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: const Text('Clear search'),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: ingredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = ingredients[index];
                    return _buildIngredientCard(ingredient, context);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddIngredient(context),
        backgroundColor: AppTheme.primaryBrown,
        child: const Icon(Icons.add, color: AppTheme.white),
      ),
    );
  }

  Widget _buildIngredientCard(Ingredient ingredient, BuildContext context) {
    Color statusColor = AppTheme.successGreen;
    String statusText = 'Good';
    IconData statusIcon = Icons.check_circle;

    if (ingredient.isExpired()) {
      statusColor = AppTheme.errorRed;
      statusText = 'Expired';
      statusIcon = Icons.error;
    } else if (ingredient.isExpiringSoon(3)) {
      statusColor = AppTheme.warningYellow;
      statusText = 'Expiring Soon';
      statusIcon = Icons.warning;
    } else if (ingredient.isLowStock()) {
      statusColor = AppTheme.primaryBrown;
      statusText = 'Low Stock';
      statusIcon = Icons.trending_down;
    }

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
                        ingredient.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${ingredient.currentStock.toStringAsFixed(1)} ${ingredient.unit}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryBrown,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (ingredient.expiryDate != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppTheme.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Expires: ${_formatDate(ingredient.expiryDate!)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.grey,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.update,
                  size: 16,
                  color: AppTheme.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  'Updated: ${_formatDate(ingredient.lastUpdated)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.grey,
                  ),
                ),
                const Spacer(),
                // Action buttons
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add, size: 20),
                      onPressed: () => _showAddStockDialog(ingredient, context),
                      color: AppTheme.successGreen,
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove, size: 20),
                      onPressed: () => _showConsumeStockDialog(ingredient, context),
                      color: AppTheme.primaryBrown,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddIngredient(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddIngredientScreen(),
      ),
    );
  }

  void _showAddStockDialog(Ingredient ingredient, BuildContext context) {
    final quantityController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Stock - ${ingredient.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity to add',
                suffixText: ingredient.unit,
                hintText: 'Enter quantity',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantity = double.tryParse(quantityController.text);
              if (quantity != null && quantity > 0) {
                final success = await Provider.of<InventoryProvider>(context, listen: false)
                    .updateStock(ingredient.ingredientId, quantity);
                if (success && context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added ${quantity} ${ingredient.unit} to ${ingredient.name}'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showConsumeStockDialog(Ingredient ingredient, BuildContext context) {
    final quantityController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Consume Stock - ${ingredient.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current stock: ${ingredient.currentStock} ${ingredient.unit}'),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity to consume',
                suffixText: ingredient.unit,
                hintText: 'Enter quantity',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantity = double.tryParse(quantityController.text);
              if (quantity != null && quantity > 0 && quantity <= ingredient.currentStock) {
                final success = await Provider.of<InventoryProvider>(context, listen: false)
                    .consumeStock(ingredient.ingredientId, quantity);
                if (success && context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Consumed ${quantity} ${ingredient.unit} from ${ingredient.name}'),
                      backgroundColor: AppTheme.primaryBrown,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid quantity or insufficient stock'),
                    backgroundColor: AppTheme.errorRed,
                  ),
                );
              }
            },
            child: const Text('Consume'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
