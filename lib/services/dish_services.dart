import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chefventory/models/dish.dart';
import 'package:chefventory/models/ingredient.dart';
import 'package:chefventory/services/firebase_config.dart';

class DishService {
  final db = FirebaseConfig.db;
  final dishesCollection = FirebaseConfig.dishes;
  final ingredientsCollection = FirebaseConfig.ingredients;
  final ordersCollection = FirebaseConfig.orders;

  Future<void> addDish(Dish dish) async {
    final batch = db.batch(); //initiates the firebase 

    final ingredientRequirements = dish.ingredientRequirements; 
    final Map<String, String> ingredientIdMap = {};

    for (final ingredientName in ingredientRequirements.keys) {//ingredientRequirement is map and just get the keys like name of the ingredient.. 
      final ingredientQuery = await ingredientsCollection 
          .where('name', isEqualTo: ingredientName)
          .limit(1)//only one matching 
          .get();

      if (ingredientQuery.docs.isEmpty) {
        final newIngredient = Ingredient(
          name: ingredientName,
          initialStock: 0,
          unit: 'g',
        );
        final newDocRef = ingredientsCollection.doc();
        batch.set(newDocRef, newIngredient.toJson()); //toJson() converts your Dart object into a map format Firestore can sav
        ingredientIdMap[ingredientName] = newDocRef.id;
      } else {
        ingredientIdMap[ingredientName] = ingredientQuery.docs.first.id;
      }
    }

    final updatedIngredientRequirements = ingredientRequirements.map((name, qty) {
      return MapEntry(ingredientIdMap[name]!, qty);
    });

    final dishData = dish.toJson();
    dishData['ingredientRequirements'] = updatedIngredientRequirements;

    final newDishRef = dishesCollection.doc();
    batch.set(newDishRef, dishData);

    await batch.commit(); //all the chanegs to the batch are queued up and once we do this all the commands are executed 

    for (final ingredientName in ingredientRequirements.keys) {
      final ingredientId = ingredientIdMap[ingredientName]!;
      await _recalculateAlertThreshold(ingredientId);
    }
  }

  Stream<List<Ingredient>> searchIngredients(String query) {
  if (query.isEmpty) {
    return ingredientsCollection.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Ingredient.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList(),
    );
  }

  final endQuery = query.substring(0, query.length - 1) +
      String.fromCharCode(query.codeUnitAt(query.length - 1) + 1);

  return ingredientsCollection
      .where('name', isGreaterThanOrEqualTo: query)
      .where('name', isLessThan: endQuery)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => Ingredient.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
      });
}


  Future<void> _recalculateAlertThreshold(String ingredientId) async {
    double maxRequirement = 0;
    final dishesSnapshot = await dishesCollection.get();

    for (final doc in dishesSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final ingredientRequirements =
          Map<String, dynamic>.from(data['ingredientRequirements'] ?? {});

      if (ingredientRequirements.containsKey(ingredientId)) {
        final requiredQty =
            (ingredientRequirements[ingredientId] as num).toDouble();
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
