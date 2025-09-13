
import '../services/firebase_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SampleData {

  static Future<void> initializeDatabase() async {
    print(' Starting database initialization...');
    
    try {
      await _createSampleUsers();
      await _createSampleIngredients(); 
      await _createSampleDishes();
      await _createSampleOrders();
      
      print('Database initialization completed successfully!');
    } catch (e) {
      print('Database initialization failed: $e');
    }
  }

  // SAMPLE USERS 
  
  static Future<void> _createSampleUsers() async {
    print('Creating sample users...');
    
    final users = [
      {
        'userId': 'user_1001',
        'username': 'restaurant_manager',
        'email': 'manager@restaurant.com',
        'role': 'admin',
        'createdAt': FirebaseConfig.getCurrentTimestamp(),
      },
      {
        'userId': 'user_1002', 
        'username': 'head_chef',
        'email': 'chef@restaurant.com',
        'role': 'admin',
        'createdAt': FirebaseConfig.getCurrentTimestamp(),
      },
      {
        'userId': 'user_1003',
        'username': 'kitchen_staff1',
        'email': 'staff1@restaurant.com',
        'role': 'staff',
        'createdAt': FirebaseConfig.getCurrentTimestamp(),
      },
      {
        'userId': 'user_1004',
        'username': 'kitchen_staff2', 
        'email': 'staff2@restaurant.com',
        'role': 'staff',
        'createdAt': FirebaseConfig.getCurrentTimestamp(),
      },
    ];

    for (var user in users) {
      await FirebaseConfig.users.doc(user['userId'].toString()).set(user);
    }
    
    print('Created ${users.length} sample users');
  }

  // SAMPLE INGREDIENTS 
  
  static Future<void> _createSampleIngredients() async {
    print('Creating sample ingredients...');
    
    final ingredients = [
      {
        'ingredientId': 'ing_1001',
        'name': 'Tomato',
        'currentStock': 5000.0, // 5kg
        'unit': 'g',
        'expiryDate': '2025-09-15',
        'alertThreshold': 300.0,
        'lastUpdated': FirebaseConfig.getCurrentTimestamp(),
      },
      {
        'ingredientId': 'ing_1002',
        'name': 'Onion', 
        'currentStock': 3000.0, // 3kg
        'unit': 'g',
        'expiryDate': '2025-09-20',
        'alertThreshold': 200.0,
        'lastUpdated': FirebaseConfig.getCurrentTimestamp(),
      },
      {
        'ingredientId': 'ing_1003',
        'name': 'Mozzarella Cheese',
        'currentStock': 2000.0, // 2kg
        'unit': 'g', 
        'expiryDate': '2025-09-12', // Expires soon!
        'alertThreshold': 400.0,
        'lastUpdated': FirebaseConfig.getCurrentTimestamp(),
      },
      {
        'ingredientId': 'ing_1004',
        'name': 'Pasta',
        'currentStock': 150.0, // Low stock!
        'unit': 'g',
        'expiryDate': '2026-01-15',
        'alertThreshold': 500.0,
        'lastUpdated': FirebaseConfig.getCurrentTimestamp(),
      },
      {
        'ingredientId': 'ing_1005',
        'name': 'Olive Oil',
        'currentStock': 800.0,
        'unit': 'ml',
        'expiryDate': '2025-12-31',
        'alertThreshold': 200.0,
        'lastUpdated': FirebaseConfig.getCurrentTimestamp(),
      },
      {
        'ingredientId': 'ing_1006',
        'name': 'Garlic',
        'currentStock': 50.0, // Very low stock!
        'unit': 'g',
        'expiryDate': '2025-09-11', // Already expired!
        'alertThreshold': 100.0,
        'lastUpdated': FirebaseConfig.getCurrentTimestamp(),
      },
      {
        'ingredientId': 'ing_1007',
        'name': 'Bell Pepper',
        'currentStock': 1200.0,
        'unit': 'g', 
        'expiryDate': '2025-09-18',
        'alertThreshold': 250.0,
        'lastUpdated': FirebaseConfig.getCurrentTimestamp(),
      },
      {
        'ingredientId': 'ing_1008',
        'name': 'Chicken Breast',
        'currentStock': 2500.0,
        'unit': 'g',
        'expiryDate': '2025-09-14',
        'alertThreshold': 600.0,
        'lastUpdated': FirebaseConfig.getCurrentTimestamp(),
      },
    ];

    for (var ingredient in ingredients) {
      await FirebaseConfig.ingredients.doc(ingredient['ingredientId'].toString()).set(ingredient);
    }
    
    print('Created ${ingredients.length} sample ingredients');
  }

  // SAMPLE DISHES 
  
  static Future<void> _createSampleDishes() async {
    print('Creating sample dishes...');
    
    final dishes = [
      {
        'dishId': 'dish_1001',
        'name': 'Pasta Arrabiata',
        'description': 'Spicy pasta with tomato sauce and garlic',
        'basePrice': 12.99,
        'category': 'Main Course',
        'ingredientRequirements': {
          'ing_1001': 200.0, // Tomato: 200g
          'ing_1002': 50.0,  // Onion: 50g  
          'ing_1004': 150.0, // Pasta: 150g
          'ing_1005': 15.0,  // Olive Oil: 15ml
          'ing_1006': 10.0,  // Garlic: 10g
        },
        'createdAt': FirebaseConfig.getCurrentTimestamp(),
      },
      {
        'dishId': 'dish_1002',
        'name': 'Margherita Pizza',
        'description': 'Classic pizza with tomato, mozzarella, and basil',
        'basePrice': 15.99,
        'category': 'Main Course',
        'ingredientRequirements': {
          'ing_1001': 150.0, // Tomato: 150g
          'ing_1003': 200.0, // Mozzarella: 200g
          'ing_1005': 10.0,  // Olive Oil: 10ml
        },
        'createdAt': FirebaseConfig.getCurrentTimestamp(),
      },
      {
        'dishId': 'dish_1003',
        'name': 'Chicken Stir Fry',
        'description': 'Stir-fried chicken with bell peppers and onions',
        'basePrice': 18.99,
        'category': 'Main Course', 
        'ingredientRequirements': {
          'ing_1008': 300.0, // Chicken: 300g
          'ing_1007': 150.0, // Bell Pepper: 150g
          'ing_1002': 100.0, // Onion: 100g
          'ing_1006': 15.0,  // Garlic: 15g
          'ing_1005': 20.0,  // Olive Oil: 20ml
        },
        'createdAt': FirebaseConfig.getCurrentTimestamp(),
      },
      {
        'dishId': 'dish_1004',
        'name': 'Caprese Salad',
        'description': 'Fresh tomatoes with mozzarella and basil',
        'basePrice': 9.99,
        'category': 'Appetizer',
        'ingredientRequirements': {
          'ing_1001': 300.0, // Tomato: 300g (highest requirement!)
          'ing_1003': 150.0, // Mozzarella: 150g
          'ing_1005': 25.0,  // Olive Oil: 25ml
        },
        'createdAt': FirebaseConfig.getCurrentTimestamp(),
      },
      {
        'dishId': 'dish_1005',
        'name': 'Garlic Pasta',
        'description': 'Simple pasta with garlic and olive oil',
        'basePrice': 10.99,
        'category': 'Main Course',
        'ingredientRequirements': {
          'ing_1004': 200.0, // Pasta: 200g
          'ing_1006': 25.0,  // Garlic: 25g
          'ing_1005': 30.0,  // Olive Oil: 30ml (highest requirement!)
        },
        'createdAt': FirebaseConfig.getCurrentTimestamp(),
      },
    ];

    for (var dish in dishes) {
      await FirebaseConfig.dishes.doc(dish['dishId'].toString()).set(dish);
    }
    
    print('Created ${dishes.length} sample dishes');
  }

  // SAMPLE ORDERS 
  
  static Future<void> _createSampleOrders() async {
    print('Creating sample orders...');
    
    final orders = [
      {
        'orderId': 'order_1001',
        'dishId': 'dish_1001',
        'dishName': 'Pasta Arrabiata',
        'quantity': 2,
        'customIngredients': {
          'ing_1002': 50.0, // Extra 50g onion
        },
        'timestamp': FirebaseConfig.getCurrentTimestamp(),
        'processedBy': 'user_1003',
        'status': 'completed'
      },
      {
        'orderId': 'order_1002', 
        'dishId': 'dish_1002',
        'dishName': 'Margherita Pizza',
        'quantity': 1,
        'customIngredients': {},
        'timestamp': FirebaseConfig.getCurrentTimestamp(),
        'processedBy': 'user_1004',
        'status': 'completed'
      },
      {
        'orderId': 'order_1003',
        'dishId': 'dish_1003', 
        'dishName': 'Chicken Stir Fry',
        'quantity': 3,
        'customIngredients': {
          'ing_1007': 100.0, // Extra 100g bell pepper
        },
        'timestamp': FirebaseConfig.getCurrentTimestamp(),
        'processedBy': 'user_1003',
        'status': 'completed'
      },
    ];

    for (var order in orders) {
      await FirebaseConfig.orders.doc(order['orderId'].toString()).set(order);
    }
    
    print('Created ${orders.length} sample orders');
  }

  // CLEAR DATABASE 
  
  static Future<void> clearDatabase() async {
    print('Clearing database...');
    
    try {
      // Delete all documents in each collection
      await _clearCollection(FirebaseConfig.users);
      await _clearCollection(FirebaseConfig.ingredients);
      await _clearCollection(FirebaseConfig.dishes);
      await _clearCollection(FirebaseConfig.orders);
      
      print('Database cleared successfully');
    } catch (e) {
      print('Failed to clear database: $e');
    }
  }
  
 static Future<void> _clearCollection(CollectionReference collection) async {
    final snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }
}