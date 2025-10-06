import 'dart:collection';
import 'ingredient.dart';

class Dish {
  final String _dishId;
  final String _name;
  String _description;
  double _basePrice;
  final Map<String, double> _ingredientRequirements;
  final String _category;
  static int _idCounter = 1000;

  Dish({
    required String name,
    required String description,
    required double basePrice,
    required Map<String, double> ingredientRequirements,
    required String category,
  }) : _dishId = 'dish_${++_idCounter}',
       _name = name,
       _description = description,
       _basePrice = basePrice,
       _ingredientRequirements = Map<String, double>.from(
         ingredientRequirements,
       ),
       _category = category;

  String get dishId => _dishId;
  String get name => _name;
  String get description => _description;
  double get basePrice => _basePrice;
  UnmodifiableMapView<String, double> get ingredientRequirements =>
      UnmodifiableMapView(_ingredientRequirements);
  String get category => _category;

  bool updatePrice(double newPrice) {
    if (newPrice > 0) {
      _basePrice = newPrice;
      return true;
    }
    return false;
  }

  bool updateDescription(String newDescription) {
    if (newDescription.isNotEmpty) {
      _description = newDescription;
      return true;
    }
    return false;
  }

  bool addIngredient(String ingredientId, double quantity) {
    if (quantity > 0) {
      _ingredientRequirements[ingredientId] = quantity;
      return true;
    }
    return false;
  }

  bool removeIngredient(String ingredientId) {
    return _ingredientRequirements.remove(ingredientId) != null;
  }

  bool updateIngredientQuantity(String ingredientId, double newQuantity) {
    if (_ingredientRequirements.containsKey(ingredientId) && newQuantity > 0) {
      _ingredientRequirements[ingredientId] = newQuantity;
      return true;
    }
    return false;
  }

  double? getIngredientQuantity(String ingredientId) {
    return _ingredientRequirements[ingredientId];
  }

  bool canBePrepared(Map<String, Ingredient> inventory) {
    for (String ingredientId in _ingredientRequirements.keys) {
      final ingredient = inventory[ingredientId];
      final requiredQty = _ingredientRequirements[ingredientId]!;

      if (ingredient == null || ingredient.currentStock < requiredQty) {
        return false;
      }
    }
    return true;
  }
}
