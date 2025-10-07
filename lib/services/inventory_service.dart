import 'package:chefventory/services/ingredient_service.dart';
import 'package:chefventory/models/ingredient.dart';

class InventoryService {
  final IngredientService _ingredientService = IngredientService();

  Future<List<Ingredient>> fetchAllIngredients() async {
    return _ingredientService.fetchAllIngredients();
  }

  Future<List<Ingredient>> getLowStockIngredients() async {
    final allIngredients = await fetchAllIngredients();
    return allIngredients.where((ingredient) => ingredient.isLowStock()).toList();
  }

  Future<List<Ingredient>> getExpiringSoonIngredients(int daysAhead) async {
    final allIngredients = await fetchAllIngredients();
    final now = DateTime.now();
    final soon = now.add(Duration(days: daysAhead));
    return allIngredients.where((ingredient) =>
      ingredient.expiryDate != null &&
      ingredient.expiryDate!.isAfter(now) &&
      ingredient.expiryDate!.isBefore(soon) &&
      !ingredient.isExpired()
    ).toList();
  }

  Future<List<Ingredient>> getExpiredIngredients() async {
    final allIngredients = await fetchAllIngredients();
    return allIngredients.where((ingredient) => ingredient.isExpired()).toList();
  }

  Future<void> updateStock(String id, double qtyChange) async {
    await _ingredientService.updateStock(id, qtyChange);
  }

  Future<void> deleteIngredient(String id) async {
    await _ingredientService.deleteIngredient(id);
  }

  Future<Ingredient?> fetchIngredientById(String ingredientId) async {
    return await _ingredientService.fetchIngredientById(ingredientId);
  }
}
