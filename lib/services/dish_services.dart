import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_config.dart';
import '../models/dish.dart';
import '../models/ingredient.dart';
import 'activity_service.dart';

class DishService {
  final String restaurantId;

  DishService([this.restaurantId = FirebaseConfig.defaultRestaurantId]);

  FirebaseFirestore get db => FirebaseConfig.db;

  CollectionReference<Map<String, dynamic>> get dishesCollection =>
      FirebaseConfig.dishes(restaurantId);

  CollectionReference<Map<String, dynamic>> get ingredientsCollection =>
      FirebaseConfig.ingredients(restaurantId);

  CollectionReference<Map<String, dynamic>> get ordersCollection =>
      FirebaseConfig.orders(restaurantId);

  Future<void> addDish(Dish dish) async {
    final batch = db.batch();

    // ingredientRequirements already uses ingredientIds as keys (from add_dish_screen)
    final ingredientRequirements = dish.ingredientRequirements;

    // Simply use the ingredientIds as they are already validated from the screen
    final dishData = dish.toMap();
    // No need to transform - ingredientRequirements already has ingredientIds as keys
    
    // Use the dish's own ID as the Firestore document ID
    final newDishRef = dishesCollection.doc(dish.dishId);
    batch.set(newDishRef, dishData);

    await batch.commit();

    // Log activity
    await ActivityService().logActivity(
      restaurantId: restaurantId,
      type: 'dish_added',
      itemName: dish.name,
      description: 'Base price: ₹${dish.basePrice.toStringAsFixed(2)}',
    );

    // Recalculate alert thresholds for all ingredients in this dish
    for (final ingredientId in ingredientRequirements.keys) {
      await _recalculateAlertThreshold(ingredientId);
    }
  }

  Stream<List<Ingredient>> searchIngredients(String query) {
    if (query.isEmpty) {
      return ingredientsCollection.snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => Ingredient.fromMap(doc.id, doc.data()))
            .toList(),
      );
    }

    final lowerQuery = query.toLowerCase();
    final endQuery = lowerQuery.substring(0, lowerQuery.length - 1) +
        String.fromCharCode(lowerQuery.codeUnitAt(lowerQuery.length - 1) + 1);

    return ingredientsCollection
        .where('name', isGreaterThanOrEqualTo: lowerQuery)
        .where('name', isLessThan: endQuery)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) {
                final ingredient = Ingredient.fromMap(doc.id, doc.data());
                // Filter to ensure the name contains the query (case-insensitive)
                if (ingredient.name.toLowerCase().contains(lowerQuery)) {
                  return ingredient;
                }
                return null;
              })
              .whereType<Ingredient>()
              .toList();
        });
  }

  Future<List<Ingredient>> getAllIngredients() async {
    final snapshot = await ingredientsCollection.get();
    return snapshot.docs
        .map((doc) => Ingredient.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> _recalculateAlertThreshold(String ingredientId) async {
    double maxRequirement = 0;
    final dishesSnapshot = await dishesCollection.get();

    for (final doc in dishesSnapshot.docs) {
      final data = doc.data();
      final ingredientRequirements =
          Map<String, dynamic>.from(data['ingredientRequirements'] ?? {});

      if (ingredientRequirements.containsKey(ingredientId)) {
        final requiredQty = (ingredientRequirements[ingredientId] as num).toDouble();
        if (requiredQty > maxRequirement) {
          maxRequirement = requiredQty;
        }
      }
    }

    await ingredientsCollection.doc(ingredientId).update({
      'alertThreshold': maxRequirement,
      'lastUpdated': Timestamp.now(),
    });
  }
}

