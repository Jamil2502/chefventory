import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chefventory/services/firebase_config.dart';
import 'package:chefventory/models/ingredient.dart';
import 'package:chefventory/services/ingredient_service.dart';

class InventoryService {
  final IngredientService _ingredientService = IngredientService();

  Future<List<Ingredient>> fetchAllIngredients() async {
    return _ingredientService.fetchAllIngredients();
  }

  Future<List<Ingredient>> getLowStockIngredients() async {
    try {
      final allIngredients = await _ingredientService.fetchAllIngredients();
      return allIngredients
          .where((ingredient) =>
              ingredient.currentStock <= ingredient.alertThreshold)
          .toList();
    } catch (e) {
      print('Error fetching low stock ingredients: $e');
      throw Exception(FirebaseConfig.getErrorMessage(e));
    }
  }

  Future<List<Ingredient>> getExpiringSoonIngredients(int daysAhead) async {
    try {
      final now = DateTime.now();
      final alertDate = now.add(Duration(days: daysAhead));
      final querySnapshot = await FirebaseConfig.ingredients
          .where('expiryDate', isGreaterThan: Timestamp.fromDate(now))
          .where('expiryDate', isLessThanOrEqualTo: Timestamp.fromDate(alertDate))
          .get();

      return querySnapshot.docs
          .map((doc) => Ingredient.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching expiring ingredients: $e');
      throw Exception(FirebaseConfig.getErrorMessage(e));
    }
  }

  Future<List<Ingredient>> getExpiredIngredients() async {
    try {
      final now = DateTime.now();
      final querySnapshot = await FirebaseConfig.ingredients
          .where('expiryDate', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .get();
      return querySnapshot.docs
          .map((doc) => Ingredient.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error fetching expired ingredients: $e');
      throw Exception(FirebaseConfig.getErrorMessage(e));
    }
  }

  Future<void> updateStock(String id, double qtyChange) async {
    await _ingredientService.updateStock(id, qtyChange);
  }
}
