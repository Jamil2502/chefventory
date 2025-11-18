import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivityService {
  static final ActivityService _instance = ActivityService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  factory ActivityService() {
    return _instance;
  }

  ActivityService._internal();

  /// Log an activity to Firestore
  Future<void> logActivity({
    required String restaurantId,
    required String type, // 'ingredient_added', 'dish_added', 'order_processed', etc.
    required String itemName,
    String? description,
  }) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        print('Cannot log activity: No user logged in');
        return;
      }

      await _firestore
          .collection('restaurants')
          .doc(restaurantId)
          .collection('activities')
          .add({
        'type': type,
        'itemName': itemName,
        'description': description ?? '',
        'userId': userId,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Error logging activity: $e');
    }
  }

  /// Get recent activities for a restaurant
  Stream<List<Map<String, dynamic>>> watchActivities(
    String restaurantId, {
    int limit = 20,
  }) {
    return _firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('activities')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'type': data['type'] ?? '',
          'itemName': data['itemName'] ?? '',
          'description': data['description'] ?? '',
          'userId': data['userId'] ?? '',
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        };
      }).toList();
    });
  }

  /// Get formatted activity message
  static String getActivityMessage(Map<String, dynamic> activity) {
    final type = activity['type'] as String;
    final itemName = activity['itemName'] as String;

    switch (type) {
      case 'ingredient_added':
        return '$itemName added to inventory';
      case 'ingredient_removed':
        return '$itemName removed from inventory';
      case 'ingredient_updated':
        return '$itemName stock updated';
      case 'dish_added':
        return 'New dish "$itemName" created';
      case 'dish_removed':
        return 'Dish "$itemName" removed';
      case 'order_processed':
        return 'Order processed: $itemName';
      case 'order_completed':
        return 'Order completed: $itemName';
      case 'staff_login':
        return '$itemName logged in';
      case 'stock_consumed':
        return 'Stock consumed for $itemName';
      default:
        return itemName;
    }
  }

  /// Get activity icon emoji based on type
  static String getActivityEmoji(String type) {
    switch (type) {
      case 'ingredient_added':
      case 'ingredient_removed':
      case 'ingredient_updated':
        return '🥬';
      case 'dish_added':
      case 'dish_removed':
        return '🍽️';
      case 'order_processed':
      case 'order_completed':
        return '📦';
      case 'staff_login':
        return '👤';
      case 'stock_consumed':
        return '📉';
      default:
        return '📝';
    }
  }
}


