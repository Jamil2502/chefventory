import 'package:flutter/foundation.dart';
import '../models/inventory.dart';
import '../models/ingredient.dart';
import '../models/dish.dart';

class InventoryProvider with ChangeNotifier {
  Inventory _inventory = Inventory(restaurantId: 'rest_001');
  List<Dish> _dishes = [];
  bool _isLoading = false;
  String? _errorMessage;

  Inventory get inventory => _inventory;
  List<Dish> get dishes => _dishes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Ingredient> get lowStockIngredients => _inventory.getLowStockIngredients();
  List<Ingredient> get expiringSoonIngredients => _inventory.getExpiringSoonIngredients(3);
  List<Ingredient> get expiredIngredients => _inventory.getExpiredIngredients();

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadInventory() async {
    setLoading(true);
    try {
      // Simulate loading from Firebase
      await Future.delayed(const Duration(seconds: 1));
      _loadSampleData();
      setLoading(false);
    } catch (e) {
      setError('Failed to load inventory: ${e.toString()}');
      setLoading(false);
    }
  }

  void _loadSampleData() {
    // Add sample ingredients
    final ingredients = [
      Ingredient(
        name: 'Tomatoes',
        initialStock: 50.0,
        unit: 'kg',
        expiryDate: DateTime.now().add(const Duration(days: 3)),
      ),
      Ingredient(
        name: 'Onions',
        initialStock: 30.0,
        unit: 'kg',
        expiryDate: DateTime.now().add(const Duration(days: 7)),
      ),
      Ingredient(
        name: 'Lettuce',
        initialStock: 5.0,
        unit: 'kg',
        expiryDate: DateTime.now().add(const Duration(days: 1)),
      ),
      Ingredient(
        name: 'Ground Beef',
        initialStock: 20.0,
        unit: 'kg',
        expiryDate: DateTime.now().add(const Duration(days: 2)),
      ),
      Ingredient(
        name: 'Cheese',
        initialStock: 15.0,
        unit: 'kg',
        expiryDate: DateTime.now().add(const Duration(days: 5)),
      ),
      Ingredient(
        name: 'Bread Buns',
        initialStock: 100.0,
        unit: 'pieces',
        expiryDate: DateTime.now().add(const Duration(days: 4)),
      ),
      Ingredient(
        name: 'Potatoes',
        initialStock: 40.0,
        unit: 'kg',
        expiryDate: DateTime.now().add(const Duration(days: 10)),
      ),
      Ingredient(
        name: 'Chicken Breast',
        initialStock: 25.0,
        unit: 'kg',
        expiryDate: DateTime.now().add(const Duration(days: 6)),
      ),
    ];

    for (var ingredient in ingredients) {
      _inventory.addIngredient(ingredient);
    }

    // Add sample dishes
    _dishes = [
      Dish(
        name: 'Classic Burger',
        description: 'Juicy beef patty with fresh vegetables',
        basePrice: 12.99,
        ingredientRequirements: {
          'ing_1001': 0.2, // Ground Beef
          'ing_1002': 0.1, // Cheese
          'ing_1003': 0.05, // Lettuce
          'ing_1004': 0.03, // Tomatoes
          'ing_1005': 0.02, // Onions
          'ing_1006': 1.0, // Bread Buns
        },
        category: 'Burgers',
      ),
      Dish(
        name: 'Chicken Sandwich',
        description: 'Grilled chicken with fresh vegetables',
        basePrice: 10.99,
        ingredientRequirements: {
          'ing_1008': 0.15, // Chicken Breast
          'ing_1002': 0.08, // Cheese
          'ing_1003': 0.04, // Lettuce
          'ing_1004': 0.03, // Tomatoes
          'ing_1006': 1.0, // Bread Buns
        },
        category: 'Sandwiches',
      ),
      Dish(
        name: 'French Fries',
        description: 'Crispy golden fries',
        basePrice: 4.99,
        ingredientRequirements: {
          'ing_1007': 0.2, // Potatoes
        },
        category: 'Sides',
      ),
    ];

    // Update alert thresholds based on dishes
    _inventory.updateAlertThresholds(_dishes);
  }

  Future<bool> addIngredient(Ingredient ingredient) async {
    try {
      final success = _inventory.addIngredient(ingredient);
      if (success) {
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      setError('Failed to add ingredient: ${e.toString()}');
      return false;
    }
  }

  Future<bool> updateStock(String ingredientId, double quantity) async {
    try {
      final success = _inventory.addStock(ingredientId, quantity);
      if (success) {
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      setError('Failed to update stock: ${e.toString()}');
      return false;
    }
  }

  Future<bool> consumeStock(String ingredientId, double quantity) async {
    try {
      final success = _inventory.consumeIngredient(ingredientId, quantity);
      if (success) {
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      setError('Failed to consume stock: ${e.toString()}');
      return false;
    }
  }

  List<Ingredient> searchIngredients(String query) {
    return _inventory.searchIngredients(query);
  }

  bool canPrepareDish(Dish dish) {
    return dish.canBePrepared(_inventory.ingredients);
  }

  Future<bool> processOrder(List<Dish> orderedDishes) async {
    try {
      for (var dish in orderedDishes) {
        for (var entry in dish.ingredientRequirements.entries) {
          final success = await consumeStock(entry.key, entry.value);
          if (!success) {
            setError('Insufficient stock for ${dish.name}');
            return false;
          }
        }
      }
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to process order: ${e.toString()}');
      return false;
    }
  }
}
