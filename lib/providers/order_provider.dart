import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dish.dart';
import '../services/firebase_config.dart';

class OrderProvider with ChangeNotifier {
  late String _restaurantId;
  List<Map<String, dynamic>> _orderHistory = [];
  bool _isProcessing = false;
  String? _errorMessage;

  OrderProvider([String restaurantId = FirebaseConfig.defaultRestaurantId]) {
    _restaurantId = restaurantId;
  }

  String get restaurantId => _restaurantId;
  List<Map<String, dynamic>> get orderHistory => _orderHistory;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;

  // Method to set restaurant ID dynamically
  void setRestaurantId(String restaurantId) {
    _restaurantId = restaurantId;
    _orderHistory.clear();
    notifyListeners();
  }

  void setProcessing(bool processing) {
    _isProcessing = processing;
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

  /// Process an order and save to Firestore
  Future<bool> processOrder(List<Dish> dishes) async {
    setProcessing(true);
    try {
      final firestore = FirebaseFirestore.instance;
      final ordersRef = firestore
          .collection('restaurants')
          .doc(_restaurantId)
          .collection('orders');

      final orderId = ordersRef.doc().id;
      final orderData = {
        'orderId': orderId,
        'dishes': dishes.map((d) => d.toMap()).toList(),
        'totalItems': dishes.length,
        'totalPrice': dishes.fold<double>(0.0, (sum, d) => sum + d.basePrice),
        'status': 'completed',
        'createdAt': Timestamp.now(),
      };

      await ordersRef.doc(orderId).set(orderData);

      _orderHistory.insert(0, orderData);
      setProcessing(false);
      notifyListeners();
      return true;
    } catch (e) {
      setError('Failed to process order: ${e.toString()}');
      setProcessing(false);
      return false;
    }
  }

  /// Load order history from Firestore
  Future<void> loadOrderHistory() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final ordersRef = firestore
          .collection('restaurants')
          .doc(_restaurantId)
          .collection('orders');

      final snapshot = await ordersRef
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      _orderHistory = snapshot.docs
          .map((doc) => doc.data())
          .toList();
      notifyListeners();
    } catch (e) {
      setError('Failed to load order history: ${e.toString()}');
    }
  }

  /// Stream real-time order updates
  Stream<List<Map<String, dynamic>>> watchOrders() {
    final firestore = FirebaseFirestore.instance;
    final ordersRef = firestore
        .collection('restaurants')
        .doc(_restaurantId)
        .collection('orders');

    return ordersRef
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => doc.data())
          .toList();
    });
  }

  /// Get today's orders count
  Future<int> getTodayOrdersCount() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final ordersRef = firestore
          .collection('restaurants')
          .doc(_restaurantId)
          .collection('orders');

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await ordersRef
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get revenue for today
  Future<double> getTodayRevenue() async {
    try {
      final firestore = FirebaseFirestore.instance;
      final ordersRef = firestore
          .collection('restaurants')
          .doc(_restaurantId)
          .collection('orders');

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await ordersRef
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('createdAt', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      double total = 0;
      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['totalPrice'] is num) {
          total += (data['totalPrice'] as num).toDouble();
        }
      }
      return total;
    } catch (e) {
      return 0;
    }
  }
}
