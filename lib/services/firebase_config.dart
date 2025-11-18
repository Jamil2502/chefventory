
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseConfig {
  // Default restaurant id used by the app unless overridden
  static const String defaultRestaurantId = 'rest_001';

  static final FirebaseFirestore db = FirebaseFirestore.instance;

  /// Top-level restaurants collection
  static CollectionReference get restaurants => db.collection('restaurants');

  /// Returns the `dishes` subcollection for the given restaurant
  static CollectionReference<Map<String, dynamic>> dishes(String restaurantId) =>
      db.collection('restaurants').doc(restaurantId).collection('dishes');

  /// Returns the `ingredients` subcollection for the given restaurant
  static CollectionReference<Map<String, dynamic>> ingredients(String restaurantId) =>
      db.collection('restaurants').doc(restaurantId).collection('ingredients');

  /// Returns the `orders` subcollection for the given restaurant
  static CollectionReference<Map<String, dynamic>> orders(String restaurantId) =>
      db.collection('restaurants').doc(restaurantId).collection('orders');
}