import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/dish.dart';
import '../../models/ingredient.dart';
import '../../providers/inventory_provider.dart';
import '../../services/dish_services.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_config.dart';
import '../../theme/app_theme.dart';

class AddDishScreenNew extends StatefulWidget {
  const AddDishScreenNew({super.key});

  @override
  State<AddDishScreenNew> createState() => _AddDishScreenNewState();
}

class _AddDishScreenNewState extends State<AddDishScreenNew> {
  final _formKey = GlobalKey<FormState>();
  final _dishNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _ingredientSearchController = TextEditingController();

  String? _selectedCategory;
  List<Ingredient> _matchedIngredients = [];
  Map<String, double> _selectedIngredients = {};
  bool _isLoading = false;

  final List<String> _categories = [
    'Starters', 'Salads', 'Main Course', 'Sides', 'Rice & Bowls',
    'Breads & Flatbreads', 'Pasta & Noodles', 'Pizzas', 'Burgers & Wraps',
    'Grills & BBQ', 'Breakfast',
  ];

  final List<String> _commonUnits = [
    'kg', 'g', 'lb', 'oz', 'pieces', 'liters', 'ml', 'cups', 'tbsp', 'tsp',
  ];

  late DishService _dishService;
  late String _restaurantId;

  @override
  void initState() {
    super.initState();
    _ingredientSearchController.addListener(_searchIngredients);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _restaurantId = authProvider.restaurantId ?? FirebaseConfig.defaultRestaurantId;
    _dishService = DishService(_restaurantId);
    
    // Ensure inventory is loaded and static counters are synced from Firestore
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    if (inventoryProvider.inventory.ingredients.isEmpty) {
      inventoryProvider.loadInventory();
    }
  }

  @override
  void dispose() {
    _dishNameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _ingredientSearchController.dispose();
    super.dispose();
  }

  void _searchIngredients() {
    final query = _ingredientSearchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _matchedIngredients = []);
      return;
    }
    
    // Get all ingredients from InventoryProvider - use inventory which should be synced
    final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
    final allIngredients = inventoryProvider.inventory.ingredients.values.toList();
    
    // Search locally in loaded ingredients
    final matched = allIngredients
        .where((ing) => ing.name.toLowerCase().contains(query))
        .toList();
    
    setState(() => _matchedIngredients = matched);
  }

  Future<void> _showCreateIngredientDialog(String ingredientName) async {
    String selectedUnit = _commonUnits.first;
    final stockController = TextEditingController(text: '0');
    final thresholdController = TextEditingController(text: '5');

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text('Create: "$ingredientName"'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedUnit,
                      decoration: const InputDecoration(labelText: 'Unit'),
                      items: _commonUnits
                          .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
                          .toList(),
                      onChanged: (value) => setDialogState(() => selectedUnit = value ?? selectedUnit),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Initial Stock'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: thresholdController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Alert Threshold'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => _handleCreateIngredient(
                    ingredientName,
                    selectedUnit,
                    double.tryParse(stockController.text) ?? 0,
                    double.tryParse(thresholdController.text) ?? 5,
                  ).then((_) => Navigator.pop(dialogContext)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBrown),
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handleCreateIngredient(
    String name,
    String unit,
    double stock,
    double threshold,
  ) async {
    try {
      final provider = Provider.of<InventoryProvider>(context, listen: false);
      
      // Validate restaurantId is set
      if (provider.restaurantId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Restaurant ID not set. Please sign in again.'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
        return;
      }

      // Create ingredient with expiryDate as optional
      final newIng = Ingredient(
        name: name,
        initialStock: stock,
        unit: unit,
        expiryDate: null, // Optional for quick creation from dish screen
      );
      newIng.updateAlertThreshold(threshold);
      
      final success = await provider.addIngredient(newIng);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ $name created'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        // Wait for Firestore write to complete before adding to dish
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          await _addIngredientWithQuantity(newIng);
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Failed to create ingredient'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _addIngredientWithQuantity(Ingredient ingredient) async {
    double qty = 1.0;
    final qtyController = TextEditingController(text: '1');

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Add ${ingredient.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Unit: ${ingredient.unit}', style: TextStyle(color: AppTheme.grey)),
              const SizedBox(height: 12),
              TextField(
                controller: qtyController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Quantity', hintText: '1.0'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                qty = double.tryParse(qtyController.text.trim()) ?? 1.0;
                if (qty > 0) {
                  setState(() {
                    _selectedIngredients[ingredient.ingredientId] = qty;
                    _ingredientSearchController.clear();
                    _matchedIngredients = [];
                  });
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBrown),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _removeIngredient(String ingredientId) {
    setState(() => _selectedIngredients.remove(ingredientId));
  }

  String _getIngredientName(String ingredientId) {
    try {
      final inventoryProvider = Provider.of<InventoryProvider>(context, listen: false);
      return inventoryProvider.inventory.getIngredient(ingredientId)?.name ?? 'Unknown';
    } catch (_) {
      return 'Unknown';
    }
  }

  Future<void> _submitDish() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final price = double.tryParse(_priceController.text) ?? 0.0;
      final dish = Dish(
        name: _dishNameController.text.trim(),
        description: _descriptionController.text.trim(),
        basePrice: price,
        ingredientRequirements: _selectedIngredients,
        category: _selectedCategory!,
      );

      await _dishService.addDish(dish);
      
      // Wait for Firestore stream to update (gives watchDishes() time to emit)
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Dish added successfully!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        title: const Text('Add Dish'),
        backgroundColor: AppTheme.primaryBrown,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dish Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBrown,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dishNameController,
                    decoration: InputDecoration(
                      labelText: 'Dish Name',
                      prefixIcon: const Icon(Icons.restaurant),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      prefixIcon: const Icon(Icons.description),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Price (₹)',
                      prefixIcon: const Icon(Icons.attach_money),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return 'Required';
                      if (double.tryParse(value) == null) return 'Invalid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      prefixIcon: const Icon(Icons.category),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (value) => setState(() => _selectedCategory = value),
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Add Ingredients',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBrown,
                        ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _ingredientSearchController,
                    decoration: InputDecoration(
                      labelText: 'Search or Create Ingredient',
                      hintText: 'Type ingredient name...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  if (_ingredientSearchController.text.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    if (_matchedIngredients.isNotEmpty) ...[
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.primaryBrown),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _matchedIngredients.length,
                          itemBuilder: (context, index) {
                            final ing = _matchedIngredients[index];
                            final isSelected = _selectedIngredients.containsKey(ing.ingredientId);
                            return ListTile(
                              leading: Icon(
                                isSelected ? Icons.check_circle : Icons.restaurant,
                                color: isSelected ? AppTheme.successGreen : AppTheme.primaryBrown,
                              ),
                              title: Text(ing.name),
                              subtitle: Text('${ing.currentStock} ${ing.unit}'),
                              onTap: isSelected ? null : () => _addIngredientWithQuantity(ing),
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.warningYellow, width: 2),
                          borderRadius: BorderRadius.circular(8),
                          color: AppTheme.warningYellow.withOpacity(0.05),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _showCreateIngredientDialog(_ingredientSearchController.text.trim()),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Icon(Icons.add_circle_outline, color: AppTheme.primaryBrown),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Create: "${_ingredientSearchController.text.trim()}"',
                                          style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryBrown),
                                        ),
                                        const Text(
                                          'Doesn\'t exist. Tap to create.',
                                          style: TextStyle(fontSize: 12, color: AppTheme.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                  const SizedBox(height: 20),
                  if (_selectedIngredients.isNotEmpty) ...[
                    Text(
                      'Selected (${_selectedIngredients.length})',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryBrown),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedIngredients.entries.map((entry) {
                        return Chip(
                          label: Text('${_getIngredientName(entry.key)}: ${entry.value}'),
                          deleteIcon: const Icon(Icons.close),
                          onDeleted: () => _removeIngredient(entry.key),
                          backgroundColor: AppTheme.primaryBrown.withOpacity(0.1),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitDish,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBrown,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isLoading
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Add Dish', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
