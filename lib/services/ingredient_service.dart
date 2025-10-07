import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chefventory/models/ingredient.dart';
import 'package:chefventory/data/sample_data.dart';
import 'package:chefventory/services/firebase_config.dart';

class IngredientService {
  final bool useStaticData;

  IngredientService({this.useStaticData = true}); // default: false means use Firebase

  Future<List<Ingredient>> fetchAllIngredients() async {
    if (useStaticData) {
      // Return from sample data for testing/demo
      return SampleData.staticIngredients
          .map((map) => Ingredient.fromMap(map['ingredientId'], map))
          .toList();
    } else {
      try {
        final querySnapshot = await FirebaseConfig.ingredients.get();
        return querySnapshot.docs
            .map((doc) =>
                Ingredient.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('Error fetching ingredients: $e');
        throw Exception(FirebaseConfig.getErrorMessage(e));
      }
    }
  }

  Future<Ingredient?> fetchIngredientById(String ingredientId) async {
    if (useStaticData) {
      final ingredientMap = SampleData.staticIngredients.firstWhere(
          (map) => map['ingredientId'] == ingredientId,
          orElse: () => {});
      if (ingredientMap.isNotEmpty) {
        return Ingredient.fromMap(ingredientId, ingredientMap);
      }
      return null;
    } else {
      try {
        final docSnapshot = await FirebaseConfig.ingredients.doc(ingredientId).get();
        if (docSnapshot.exists) {
          final data = docSnapshot.data();
if (data is Map<String, dynamic>) {
  return Ingredient.fromMap(docSnapshot.id, data);
}

        }
        return null;
      } catch (e) {
        print('Error fetching ingredient: $e');
        throw Exception(FirebaseConfig.getErrorMessage(e));
      }
    }
  }

  Future<void> updateStock(String ingredientId, double quantityChange) async {
    if (useStaticData) {
      // Simulate update - no persistent change for static data
      print('Simulate stock update for $ingredientId by $quantityChange');
    } else {
      try {
        final ingredientRef = FirebaseConfig.ingredients.doc(ingredientId);
        final docSnapshot = await ingredientRef.get();
        if (docSnapshot.exists) {
          final data = docSnapshot.data() as Map<String, dynamic>;
          final currentStock = (data['currentStock'] as num).toDouble();
          final newStock = currentStock + quantityChange;
          await ingredientRef.update({
            'currentStock': newStock,
            'lastUpdated': Timestamp.now(),
          });
        }
      } catch (e) {
        print('Error updating stock: $e');
        throw Exception(FirebaseConfig.getErrorMessage(e));
      }
    }
  }

  Future<void> deleteIngredient(String ingredientId) async {
    if (useStaticData) {
      // Simulate delete - no persistent change for static data
      print('Simulate delete ingredient $ingredientId');
    } else {
      try {
        await FirebaseConfig.ingredients.doc(ingredientId).delete();
      } catch (e) {
        print('Error deleting ingredient: $e');
        throw Exception(FirebaseConfig.getErrorMessage(e));
      }
    }
  }
}
