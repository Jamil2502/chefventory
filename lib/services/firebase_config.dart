
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseConfig {
  static FirebaseFirestore get db => FirebaseFirestore.instance;
  
  static String get restaurantId => 'rest_001';
  
  
  // Users collection
  static CollectionReference get users => 
      db.collection('restaurants').doc(restaurantId).collection('users');
  
  // Ingredients collection 
  static CollectionReference get ingredients => 
      db.collection('restaurants').doc(restaurantId).collection('ingredients');
      
  // Dishes collection 
  static CollectionReference get dishes => 
      db.collection('restaurants').doc(restaurantId).collection('dishes');
      
  // Orders collection 
  static CollectionReference get orders => 
      db.collection('restaurants').doc(restaurantId).collection('orders');


  /// Generate unique ID for documents
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  /// Get current timestamp
  static Timestamp getCurrentTimestamp() {
    return Timestamp.now();
  }
  
  /// Convert DateTime to Firestore Timestamp
  static Timestamp? dateTimeToTimestamp(DateTime? dateTime) {
    return dateTime != null ? Timestamp.fromDate(dateTime) : null;
  }
  
  /// Convert Firestore Timestamp to DateTime
  static DateTime? timestampToDateTime(Timestamp? timestamp) {
    return timestamp?.toDate();
  }

  /// Handle Firestore errors
  static String getErrorMessage(dynamic error) {
    if (error.toString().contains('network')) {
      return 'Network error. Please check your connection.';
    } else if (error.toString().contains('permission')) {
      return 'Permission denied. Please contact admin.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }
}