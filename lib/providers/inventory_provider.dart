import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/inventory.dart';
import '../models/ingredient.dart';
import '../models/dish.dart';
import '../services/activity_service.dart';

class InventoryProvider with ChangeNotifier {
  static const int DAYS_UNTIL_EXPIRY_ALERT = 7; // Configurable expiry alert threshold

  late Inventory _inventory;
  List<Dish> _dishes = [];
  bool _isLoading = false;
  String? _errorMessage;
  late String _restaurantId;

  // Constructor that accepts restaurant ID
  InventoryProvider({String restaurantId = 'rest_001'}) {
    _restaurantId = restaurantId;
    _inventory = Inventory(restaurantId: restaurantId);
  }

  // Method to set restaurant ID dynamically
  void setRestaurantId(String restaurantId) {
    _restaurantId = restaurantId;
    _inventory = Inventory(restaurantId: restaurantId);
    notifyListeners();
  }

  Inventory get inventory => _inventory;
  List<Dish> get dishes => _dishes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get restaurantId => _restaurantId;

  List<Ingredient> get lowStockIngredients =>
      _inventory.getLowStockIngredients();
  List<Ingredient> get expiringSoonIngredients =>
      _inventory.getExpiringSoonIngredients(DAYS_UNTIL_EXPIRY_ALERT);
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
      final firestore = FirebaseFirestore.instance;

      // IMPORTANT: Clear old data before loading new - prevents duplicates
      _inventory = Inventory(restaurantId: _restaurantId);
      _dishes = [];

      // Try to load ingredients from a subcollection under the restaurant document
      final ingredientsRef = firestore
          .collection('restaurants')
          .doc(_inventory.restaurantId)
          .collection('ingredients');

      final dishesRef = firestore
          .collection('restaurants')
          .doc(_inventory.restaurantId)
          .collection('dishes');

      final ingSnap = await ingredientsRef.get();
      final dishSnap = await dishesRef.get();

      // Load data from Firestore - all data is sourced from Firebase
      if (ingSnap.docs.isNotEmpty || dishSnap.docs.isNotEmpty) {
        print('📦 Loading ${ingSnap.docs.length} ingredients and ${dishSnap.docs.length} dishes');
        
        for (var doc in ingSnap.docs) {
          final data = doc.data();
          // Parse expiry date if present (Timestamp or String)
          DateTime? expiry;
          if (data['expiryDate'] != null) {
            final v = data['expiryDate'];
            if (v is Timestamp) expiry = v.toDate();
            else if (v is String) expiry = DateTime.tryParse(v);
          }

          final ingredient = Ingredient.fromMap(doc.id, {
            'name': data['name'],
            'currentStock': data['currentStock'],
            'unit': data['unit'],
            'expiryDate': expiry,
            'alertThreshold': data['alertThreshold'],
            'lastUpdated': data['lastUpdated'],
          });

          _inventory.addIngredient(ingredient);
        }

        for (var doc in dishSnap.docs) {
          final data = doc.data();
          final reqs = <String, double>{};
          if (data['ingredientRequirements'] is Map) {
            (data['ingredientRequirements'] as Map).forEach((k, v) {
              double val = 0;
              if (v is num) val = v.toDouble();
              else if (v is String) val = double.tryParse(v) ?? 0;
              reqs[k.toString()] = val;
            });
          }

          final dish = Dish.fromMap(doc.id, {
            'name': data['name'],
            'description': data['description'],
            'basePrice': data['basePrice'],
            'ingredientRequirements': reqs,
            'category': data['category'],
          });

          _dishes.add(dish);
        }

        // Update thresholds based on loaded dishes
        _inventory.updateAlertThresholds(_dishes);
        print('✅ Inventory loaded successfully');
      } else {
        // No data in Firestore yet - waiting for user to add ingredients/dishes
        print('ℹ️ No ingredients or dishes found in Firestore');
        setLoading(false);
      }

      setLoading(false);
    } catch (e) {
      setError('Failed to load inventory: ${e.toString()}');
      setLoading(false);
    }
  }

  Future<bool> addIngredient(Ingredient ingredient) async {
    try {
      // Validate restaurantId is set
      if (_restaurantId.isEmpty || _restaurantId == 'rest_001') {
        print('⚠️ WARNING: restaurantId might be default: $_restaurantId');
      }
      
      final success = _inventory.addIngredient(ingredient);
      if (!success) {
        setError('Ingredient already exists locally');
        return false;
      }

      // Persist to Firestore
      final firestore = FirebaseFirestore.instance;
      final docRef = firestore
          .collection('restaurants')
          .doc(_inventory.restaurantId)
          .collection('ingredients')
          .doc(ingredient.ingredientId);

      // Build Firestore document - remove ingredientId as it's already the doc ID
      final writeData = {
        'name': ingredient.name,
        'currentStock': ingredient.currentStock,
        'unit': ingredient.unit,
        'alertThreshold': ingredient.alertThreshold,
        'lastUpdated': Timestamp.fromDate(ingredient.lastUpdated),
      };
      
      // Only include expiryDate if it's not null
      if (ingredient.expiryDate != null) {
        writeData['expiryDate'] = Timestamp.fromDate(ingredient.expiryDate!);
      }

      print('📝 Writing ingredient to Firestore:');
      print('   Restaurant: ${_inventory.restaurantId}');
      print('   ID: ${ingredient.ingredientId}');
      print('   Name: ${ingredient.name}');
      print('   Data: $writeData');

      await docRef.set(writeData);

      // Log activity
      await ActivityService().logActivity(
        restaurantId: _inventory.restaurantId,
        type: 'ingredient_added',
        itemName: ingredient.name,
        description: 'Added ${ingredient.currentStock} ${ingredient.unit}',
      );

      print('✅ Ingredient saved successfully');
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ Error adding ingredient: $e');
      // revert local change if persistence failed
      try {
        _inventory.removeIngredient(ingredient.ingredientId);
      } catch (_) {}
      setError('Failed to add ingredient: ${e.toString()}');
      return false;
    }
  }

  Future<bool> updateStock(String ingredientId, double quantity) async {
    try {
      final ingredient = _inventory.getIngredient(ingredientId);
      if (ingredient == null) {
        setError('Ingredient not found');
        return false;
      }

      final success = _inventory.addStock(ingredientId, quantity);
      if (!success) return false;

      // persist updated stock
      final firestore = FirebaseFirestore.instance;
      final docRef = firestore
          .collection('restaurants')
          .doc(_inventory.restaurantId)
          .collection('ingredients')
          .doc(ingredientId);

      await docRef.update({
        'currentStock': ingredient.currentStock,
        'lastUpdated': Timestamp.fromDate(ingredient.lastUpdated),
      });

      notifyListeners();
      return true;
    } catch (e) {
      // try rollback
      try {
        _inventory.consumeIngredient(ingredientId, quantity);
      } catch (_) {}
      setError('Failed to update stock: ${e.toString()}');
      return false;
    }
  }

  Future<bool> consumeStock(String ingredientId, double quantity) async {
    try {
      final ingredient = _inventory.getIngredient(ingredientId);
      if (ingredient == null) {
        setError('Ingredient not found');
        return false;
      }

      final success = _inventory.consumeIngredient(ingredientId, quantity);
      if (!success) return false;

      final firestore = FirebaseFirestore.instance;
      final docRef = firestore
          .collection('restaurants')
          .doc(_inventory.restaurantId)
          .collection('ingredients')
          .doc(ingredientId);

      await docRef.update({
        'currentStock': ingredient.currentStock,
        'lastUpdated': Timestamp.fromDate(ingredient.lastUpdated),
      });

      notifyListeners();
      return true;
    } catch (e) {
      // try rollback
      try {
        _inventory.addStock(ingredientId, quantity);
      } catch (_) {}
      setError('Failed to consume stock: ${e.toString()}');
      return false;
    }
  }

  List<Ingredient> searchIngredients(String query) {
    return _inventory.searchIngredients(query);
  }

  bool canPrepareDish(Dish dish) {
    // Check if all required ingredients are available in inventory
    for (var entry in dish.ingredientRequirements.entries) {
      final ingredientId = entry.key;
      final requiredQty = entry.value;
      final ingredient = _inventory.getIngredient(ingredientId);
      
      // If ingredient not found or insufficient stock, cannot prepare
      if (ingredient == null || ingredient.currentStock < requiredQty) {
        return false;
      }
    }
    return true;
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

  /// Stream real-time ingredient updates from Firestore
  Stream<List<Ingredient>> watchIngredients() {
    final firestore = FirebaseFirestore.instance;
    final ingredientsRef = firestore
        .collection('restaurants')
        .doc(_inventory.restaurantId)
        .collection('ingredients');

    return ingredientsRef.snapshots().map((snapshot) {
      final ingredients = <String, Ingredient>{};
      for (var doc in snapshot.docs) {
        final ing = Ingredient.fromMap(doc.id, doc.data());
        ingredients[doc.id] = ing;
      }
      return ingredients.values.toList();
    });
  }

  /// Stream real-time dish updates from Firestore
  Stream<List<Dish>> watchDishes() {
    final firestore = FirebaseFirestore.instance;
    final dishesRef = firestore
        .collection('restaurants')
        .doc(_inventory.restaurantId)
        .collection('dishes');

    return dishesRef.snapshots().map((snapshot) {
      final dishes = <Dish>[];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final reqs = <String, double>{};
        if (data['ingredientRequirements'] is Map) {
          (data['ingredientRequirements'] as Map).forEach((k, v) {
            double val = 0;
            if (v is num) val = v.toDouble();
            else if (v is String) val = double.tryParse(v) ?? 0;
            reqs[k.toString()] = val;
          });
        }
        final dish = Dish.fromMap(doc.id, {
          'name': data['name'],
          'description': data['description'],
          'basePrice': data['basePrice'],
          'ingredientRequirements': reqs,
          'category': data['category'],
        });
        dishes.add(dish);
      }
      return dishes;
    });
  }

  /// Stream low stock alerts
  Stream<List<Ingredient>> watchLowStockAlerts() {
    return watchIngredients().map((ingredients) {
      return ingredients
          .where((ing) => ing.isLowStock())
          .toList();
    });
  }

  /// Stream expiring soon alerts
  Stream<List<Ingredient>> watchExpiringAlerts() {
    return watchIngredients().map((ingredients) {
      return ingredients
          .where((ing) => ing.isExpiringSoon(DAYS_UNTIL_EXPIRY_ALERT))
          .toList();
    });
  }

  /// Stream expired items alerts
  Stream<List<Ingredient>> watchExpiredAlerts() {
    return watchIngredients().map((ingredients) {
      return ingredients
          .where((ing) => ing.isExpired())
          .toList();
    });
  }
}

