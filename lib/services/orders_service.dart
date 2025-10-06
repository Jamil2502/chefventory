import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String orderId;
  final List<Map<String, dynamic>> dishes;
  final List<Map<String, dynamic>> customIngredients;
  final DateTime orderTime;
  final String processedBy;
  final Map<String, double> ingredientUsage;

  Order({
    required this.orderId,
    required this.dishes,
    required this.customIngredients,
    required this.orderTime,
    required this.processedBy,
    required this.ingredientUsage,
  });

  Map<String, dynamic> toMap() => {
    'orderId': orderId,
    'dishes': dishes,
    'customIngredients': customIngredients,
    'orderTime': Timestamp.fromDate(orderTime),
    'processedBy': processedBy,
    'ingredientUsage': ingredientUsage,
  };

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      orderId: map['orderId'],
      dishes: List<Map<String, dynamic>>.from(map['dishes']),
      customIngredients: List<Map<String, dynamic>>.from(
        map['customIngredients'] ?? [],
      ),
      orderTime: (map['orderTime'] as Timestamp).toDate(),
      processedBy: map['processedBy'],
      ingredientUsage: Map<String, double>.from(map['ingredientUsage']),
    );
  }
}

class OrderService {
  final _orderCollection = FirebaseFirestore.instance.collection('orders');

  Future<void> createOrder(Order order) async {
    await _orderCollection.doc(order.orderId).set(order.toMap());
  }

  Future<List<Order>> fetchOrderHistory({String? userId}) async {
    QuerySnapshot snapshot;
    if (userId != null) {
      snapshot = await _orderCollection
          .where('processedBy', isEqualTo: userId)
          .orderBy('orderTime', descending: true)
          .get();
    } else {
      snapshot = await _orderCollection
          .orderBy('orderTime', descending: true)
          .get();
    }
    return snapshot.docs
        .map((doc) => Order.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }
}
