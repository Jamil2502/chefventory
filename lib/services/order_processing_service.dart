import 'package:chefventory/services/orders_service.dart' as order_models;
import 'package:cloud_firestore/cloud_firestore.dart';
// import your dish_service.dart and inventory_service.dart as appropriate

class OrderProcessingService {
  Future<void> processOrder({
    required String userId,
    required List<Map<String, dynamic>> orderedDishes,
    required List<Map<String, dynamic>> customIngredients,
  }) async {
    Map<String, double> totalIngredientRequirement = {};

    // --- Calculate ingredient needs from dish_service
    for (var dish in orderedDishes) {
      final dishDetails = await getDishDetails(dish['dishId']);
      final dishQty = dish['quantity'] as double;
      for (var ing in dishDetails['ingredients']) {
        final ingId = ing['ingredientId'];
        final ingAmt = (ing['quantity'] as double) * dishQty;
        totalIngredientRequirement[ingId] =
            (totalIngredientRequirement[ingId] ?? 0) + ingAmt;
      }
    }
    // --- Add custom ingredients
    for (var cust in customIngredients) {
      final ingId = cust['ingredientId'];
      final ingAmt = cust['quantity'] as double;
      totalIngredientRequirement[ingId] =
          (totalIngredientRequirement[ingId] ?? 0) + ingAmt;
    }

    // --- Validate stock with inventory_service
    for (var ingId in totalIngredientRequirement.keys) {
      final ingDetails = await getIngredientDetails(
        ingId,
      ); // from inventory_service
      if (ingDetails['currentStock'] < totalIngredientRequirement[ingId]!) {
        throw Exception("Insufficient stock for ingredient $ingId");
      }
    }

    // --- Deduct ingredients using batched Firestore update
    final batch = FirebaseFirestore.instance.batch();
    for (var ingId in totalIngredientRequirement.keys) {
      final ingRef = FirebaseFirestore.instance
          .collection('ingredients')
          .doc(ingId);
      batch.update(ingRef, {
        'currentStock': FieldValue.increment(
          -totalIngredientRequirement[ingId]!,
        ),
      });
    }
    await batch.commit();

    // --- Save Order using the aliased model
    final orderId = FirebaseFirestore.instance.collection('orders').doc().id;
    final order = order_models.Order(
      orderId: orderId,
      dishes: orderedDishes,
      customIngredients: customIngredients,
      orderTime: DateTime.now(),
      processedBy: userId,
      ingredientUsage: totalIngredientRequirement,
    );
    await order_models.OrderService().createOrder(order);
  }

  // Placeholder: Implement with your dish_service.dart
  Future<Map<String, dynamic>> getDishDetails(String dishId) async {
    throw UnimplementedError();
  }

  // Placeholder: Implement with your inventory_service.dart
  Future<Map<String, dynamic>> getIngredientDetails(String ingredientId) async {
    throw UnimplementedError();
  }
}
