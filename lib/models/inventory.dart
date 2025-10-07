import 'dart:collection';
import 'ingredient.dart';
import 'dish.dart';

class Inventory {
  final Map<String, Ingredient> _ingredients;
  final String _restaurantId;
  DateTime _lastUpdated;

  Inventory({required String restaurantId})
      : _ingredients = {},
        _restaurantId = restaurantId,
        _lastUpdated = DateTime.now();

  String get restaurantId => _restaurantId;
  DateTime get lastUpdated => _lastUpdated;
  UnmodifiableMapView<String, Ingredient> get ingredients => UnmodifiableMapView(_ingredients);

  bool addIngredient(Ingredient ingredient) {
    if (!_ingredients.containsKey(ingredient.ingredientId)) {
      _ingredients[ingredient.ingredientId] = ingredient;
      _lastUpdated = DateTime.now();
      return true;
    }
    return false;
  }

  bool removeIngredient(String ingredientId) {
    final removed = _ingredients.remove(ingredientId) != null;
    if (removed) _lastUpdated = DateTime.now();
    return removed;
  }

  Ingredient? getIngredient(String ingredientId) => _ingredients[ingredientId];

  bool consumeIngredient(String ingredientId, double quantity) {
    final ingredient = _ingredients[ingredientId];
    if (ingredient != null && quantity > 0 && ingredient.currentStock >= quantity) {
      ingredient.currentStock -= quantity;
      ingredient.lastUpdated = DateTime.now();
      _lastUpdated = DateTime.now();
      return true;
    }
    return false;
  }

  bool addStock(String ingredientId, double quantity) {
    final ingredient = _ingredients[ingredientId];
    if (ingredient != null && quantity > 0) {
      ingredient.currentStock += quantity;
      ingredient.lastUpdated = DateTime.now();
      _lastUpdated = DateTime.now();
      return true;
    }
    return false;
  }

  List<Ingredient> getLowStockIngredients() =>
      _ingredients.values.where((ingredient) => ingredient.isLowStock()).toList();

  List<Ingredient> getExpiringSoonIngredients([int daysAhead = 3]) =>
      _ingredients.values.where((ingredient) => ingredient.isExpiringSoon(daysAhead)).toList();

  List<Ingredient> getExpiredIngredients() =>
      _ingredients.values.where((ingredient) => ingredient.isExpired()).toList();

  List<Ingredient> searchIngredients(String query) {
    final lowerQuery = query.toLowerCase();
    return _ingredients.values
        .where((ingredient) => ingredient.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  void updateAlertThresholds(List<Dish> dishes) {
    // Set all thresholds to 0 initially
    for (var ingredient in _ingredients.values) {
      ingredient.alertThreshold = 0;
    }
    // Update thresholds based on dish requirements
    for (var dish in dishes) {
      for (var entry in dish.ingredientRequirements.entries) {
        final ingredientId = entry.key;
        final requiredQuantity = entry.value;
        final ingredient = _ingredients[ingredientId];
        if (ingredient != null && requiredQuantity > ingredient.alertThreshold) {
          ingredient.alertThreshold = requiredQuantity;
        }
      }
    }
  }
}
