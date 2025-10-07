import 'package:flutter/material.dart';
import 'package:chefventory/services/inventory_service.dart';
import 'package:chefventory/models/ingredient.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventoryService _inventoryService = InventoryService();
  final TextEditingController _searchController = TextEditingController();

  List<Ingredient> _ingredients = [];
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _isLoading = true;
  String? _errorMsg;
  final List<String> _filterOptions = ['All', 'Low Stock', 'Expiring Soon', 'Expired'];

  final Color primaryBrown = const Color(0xFF6F4E37);
  final Color lightBrown = const Color(0xFFF5EEE6);
  final Color darkBrown = const Color(0xFF4B2E1E);

  @override
  void initState() {
    super.initState();
    _fetchIngredients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchIngredients() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      List<Ingredient> ingredients;
      switch (_selectedFilter) {
        case 'Low Stock':
          ingredients = await _inventoryService.getLowStockIngredients();
          break;
        case 'Expiring Soon':
          ingredients = await _inventoryService.getExpiringSoonIngredients(3);
          break;
        case 'Expired':
          ingredients = await _inventoryService.getExpiredIngredients();
          break;
        default:
          ingredients = await _inventoryService.fetchAllIngredients();
      }
      setState(() {
        _ingredients = ingredients;
      });
    } catch (e) {
      setState(() {
        _errorMsg = e.toString();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMsg ?? 'Failed to load inventory.'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _fetchIngredients();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<Ingredient> get _filteredIngredients {
    if (_searchQuery.isEmpty) return _ingredients;
    return _ingredients
        .where((ingredient) =>
            ingredient.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Future<void> _updateStock(String id, double qtyChange) async {
    await _inventoryService.updateStock(id, qtyChange);
    await _fetchIngredients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBrown,
      appBar: AppBar(
        title: const Text('Inventory', style: TextStyle(color: Colors.white),),
        backgroundColor: primaryBrown,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator())),
          if (_errorMsg != null && !_isLoading)
            Expanded(
              child: Center(
                child: Text(
                  _errorMsg!,
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
          if (!_isLoading && _errorMsg == null)
            _filteredIngredients.isEmpty
                ? Expanded(
                    child: Center(
                      child: Text(
                        _searchQuery.isNotEmpty
                            ? 'No ingredients found for "$_searchQuery"'
                            : 'No ingredients found',
                        style: TextStyle(
                          color: darkBrown.withOpacity(0.6),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _filteredIngredients.length,
                      itemBuilder: (context, index) {
                        return _buildIngredientCard(_filteredIngredients[index]);
                      },
                    ),
                  ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBrown,
        onPressed: () {
          // TODO: Implement adding new ingredient navigation
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      color: lightBrown,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Search ingredients...',
              prefixIcon: Icon(Icons.search, color: primaryBrown),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: primaryBrown),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(40),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: _onSearchChanged,
            style: TextStyle(color: darkBrown),
          ),
          const SizedBox(height: 12),
          // Filters
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
                    backgroundColor: Colors.white,
                    selectedColor: primaryBrown,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : darkBrown,
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (selected) {
                      if (selected) _onFilterChanged(filter);
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? primaryBrown : darkBrown.withOpacity(0.3),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientCard(Ingredient ingredient) {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    if (ingredient.isExpired()) {
      statusColor = Colors.redAccent;
      statusText = 'Expired';
      statusIcon = Icons.error_outline;
    } else if (ingredient.isExpiringSoon(3)) {
      statusColor = Colors.orangeAccent;
      statusText = 'Expiring Soon';
      statusIcon = Icons.warning_amber_outlined;
    } else if (ingredient.isLowStock()) {
      statusColor = primaryBrown;
      statusText = 'Low Stock';
      statusIcon = Icons.trending_down;
    } else {
      statusColor = Colors.green.shade700;
      statusText = 'Good';
      statusIcon = Icons.check_circle_outline;
    }
    return Card(
      color: Colors.white,
      elevation: 3,
      shadowColor: primaryBrown.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name & Status
            Row(
              children: [
                Expanded(
                  child: Text(
                    ingredient.name,
                    style: TextStyle(
                      color: darkBrown,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, color: statusColor, size: 18),
                      const SizedBox(width: 6),
                      Text(statusText,
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Stock
            Text(
              '${ingredient.currentStock.toStringAsFixed(1)} ${ingredient.unit}',
              style: TextStyle(
                color: primaryBrown,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            // Expiry Date
            if (ingredient.expiryDate != null)
              Row(
                children: [
                  const Icon(Icons.schedule, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text('Expires: ${_formatDate(ingredient.expiryDate!)}',
                      style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            const SizedBox(height: 8),
            // Last Updated and Actions
            Row(
              children: [
                Icon(Icons.update, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  'Updated: ${ingredient.lastUpdated != null ? _formatDate(ingredient.lastUpdated!) : "-"}',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.remove_circle, size: 26, color: primaryBrown),
                  tooltip: 'Consume Stock',
                  onPressed: () => _showStockDialog(ingredient, false),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle, size: 26, color: primaryBrown),
                  tooltip: 'Add Stock',
                  onPressed: () => _showStockDialog(ingredient, true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showStockDialog(Ingredient ingredient, bool addStock) {
    final quantityController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${addStock ? 'Add' : 'Consume'} Stock - ${ingredient.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!addStock)
              Text('Current stock: ${ingredient.currentStock.toStringAsFixed(1)} ${ingredient.unit}'),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(
                labelText: 'Quantity',
                suffixText: ingredient.unit,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryBrown, foregroundColor: Colors.white),
            child: Text(addStock ? 'Add' : 'Consume'),
            onPressed: () async {
              final quantity = double.tryParse(quantityController.text);
              if (quantity == null || quantity <= 0 || (!addStock && quantity > ingredient.currentStock)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      addStock
                          ? 'Enter a valid quantity.'
                          : 'Invalid quantity or insufficient stock.',
                    ),
                    backgroundColor: Colors.redAccent,
                  ),
                );
                return;
              }
              Navigator.of(context).pop();
              await _updateStock(ingredient.ingredientId, addStock ? quantity : -quantity);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${addStock ? 'Added' : 'Consumed'} $quantity ${ingredient.unit} ${addStock ? 'to' : 'from'} ${ingredient.name}'),
                  backgroundColor: addStock ? primaryBrown : Colors.brown.shade700,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
