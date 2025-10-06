import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chefventory/services/firebase_config.dart';
import 'package:chefventory/models/ingredient.dart';

class IngredientService {
  final CollectionReference _ingredientsCollection = FirebaseConfig.ingredients;

  Future<Ingredient?> fetchIngredientById(String ingredientId) async {
    try {
      final docSnapshot = await _ingredientsCollection.doc(ingredientId).get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null) {
          return Ingredient.fromMap(docSnapshot.id, data as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching ingredient: $e');
      throw Exception(FirebaseConfig.getErrorMessage(e));
    }
  }

  /// This method updates the stock by ADDING quantityChange (can be negative).
  /// Positive = Add stock, Negative = Consume stock.
  Future<void> updateStock(String ingredientId, double quantityChange) async {
    try {
      final ingredientRef = _ingredientsCollection.doc(ingredientId);
      final docSnapshot = await ingredientRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        if (data['currentStock'] != null) {
          double currentStock = (data['currentStock'] as num).toDouble();
          double newStock = currentStock + quantityChange;
          await ingredientRef.update({
            'currentStock': newStock,
            'lastUpdated': Timestamp.now(),
          });
        } else {
          throw Exception("Ingredient data missing 'currentStock' field.");
        }
      } else {
        throw Exception("Ingredient not found.");
      }
    } catch (e) {
      print('Error updating stock: $e');
      throw Exception(FirebaseConfig.getErrorMessage(e));
    }
  }

  Future<List<Ingredient>> fetchAllIngredients() async {
    try {
      final querySnapshot = await _ingredientsCollection.get();
      return querySnapshot.docs.map((doc) {
        return Ingredient.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error fetching ingredients: $e');
      throw Exception(FirebaseConfig.getErrorMessage(e));
    }
  }

  Future<void> deleteIngredient(String ingredientId) async {
    try {
      await _ingredientsCollection.doc(ingredientId).delete();
    } catch (e) {
      print('Error deleting ingredient: $e');
      throw Exception(FirebaseConfig.getErrorMessage(e));
    }
  }

}
