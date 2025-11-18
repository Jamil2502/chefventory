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

  // Update the counter if we load an ID that's higher than current counter
  static void updateCounterIfNeeded(String dishId) {
    // Parse ID like 'dish_1234' to extract number
    if (dishId.startsWith('dish_')) {
      try {
        final idNum = int.parse(dishId.substring(5));
        if (idNum >= _idCounter) {
          _idCounter = idNum;
        }
      } catch (_) {}
    }
  }

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

  // Create Dish from Firestore / map data with explicit id
  Dish._fromData({
    required String dishId,
    required String name,
    required String description,
    required double basePrice,
    required Map<String, double> ingredientRequirements,
    required String category,
  }) : _dishId = dishId,
       _name = name,
       _description = description,
       _basePrice = basePrice,
       _ingredientRequirements = Map<String, double>.from(ingredientRequirements),
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

  Map<String, dynamic> toMap() {
    return {
      'dishId': _dishId,
      'name': _name,
      'description': _description,
      'basePrice': _basePrice,
      'ingredientRequirements': _ingredientRequirements,
      'category': _category,
    };
  }

  factory Dish.fromMap(String id, Map<String, dynamic> map) {
    // IMPORTANT: Update static counter when loading from Firestore
    // This prevents duplicate IDs when app restarts
    updateCounterIfNeeded(id);

    double basePrice = 0;
    if (map['basePrice'] is num) basePrice = (map['basePrice'] as num).toDouble();
    else if (map['basePrice'] is String) basePrice = double.tryParse(map['basePrice']) ?? 0;

    final Map<String, double> reqs = {};
    if (map['ingredientRequirements'] is Map) {
      (map['ingredientRequirements'] as Map).forEach((k, v) {
        double val = 0;
        if (v is num) val = v.toDouble();
        else if (v is String) val = double.tryParse(v) ?? 0;
        reqs[k.toString()] = val;
      });
    }

    return Dish._fromData(
      dishId: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      basePrice: basePrice,
      ingredientRequirements: reqs,
      category: map['category'] ?? '',
    );
  }
}
