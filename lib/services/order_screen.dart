import 'package:flutter/material.dart';
import 'package:chefventory/services/orders_service.dart' as order_models;
import 'package:chefventory/services/order_processing_service.dart';

const Map<int, Color> brownDerby = {
  50: Color(0xFFFCF8EE),
  100: Color(0xFFF5EBD0),
  200: Color(0xFFEBD49C),
  300: Color(0xFFE1BA68),
  400: Color(0xFFDAA345),
  500: Color(0xFFD1862F),
  600: Color(0xFFB86827),
  700: Color(0xFF9A4C23),
  800: Color(0xFF7E3D22),
  900: Color(0xFF68321F),
};

final MaterialColor brownDerbySwatch = MaterialColor(0xFFD1862F, brownDerby);

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen>
    with TickerProviderStateMixin {
  final OrderProcessingService _orderProcessingService =
      OrderProcessingService();
  final order_models.OrderService _orderService = order_models.OrderService();

  List<Map<String, dynamic>> selectedDishes = [];
  List<Map<String, dynamic>> customIngredients = [];
  bool isProcessing = false;
  String? errorMsg;
  String? successMsg;
  List<order_models.Order> orderHistory = [];

  late TabController _tabController;

  List<Map<String, dynamic>> dishes = [
    {
      'dishId': 'dish_1001',
      'name': 'Pasta Arrabiata',
      'description': 'Spicy pasta with tomato sauce and garlic',
      'price': 12.99,
      'category': 'Main Course',
    },
    {
      'dishId': 'dish_1002',
      'name': 'Margherita Pizza',
      'description': 'Classic pizza with tomato, mozzarella, and basil',
      'price': 15.99,
      'category': 'Main Course',
    },
    {
      'dishId': 'dish_1003',
      'name': 'Chicken Stir Fry',
      'description': 'Stir-fried chicken with bell peppers and onions',
      'price': 18.99,
      'category': 'Main Course',
    },
    {
      'dishId': 'dish_1004',
      'name': 'Caprese Salad',
      'description': 'Fresh tomatoes with mozzarella and basil',
      'price': 9.99,
      'category': 'Appetizer',
    },
    {
      'dishId': 'dish_1005',
      'name': 'Garlic Pasta',
      'description': 'Simple pasta with garlic and olive oil',
      'price': 10.99,
      'category': 'Main Course',
    },
  ];

  List<Map<String, dynamic>> ingredients = [
    {
      'ingredientId': 'ing_1001',
      'name': 'Tomato',
      'unit': 'g',
      'category': 'Vegetables',
      'currentStock': 5000.0,
      'alertThreshold': 300.0,
      'expiryDate': '2025-09-15',
    },
    {
      'ingredientId': 'ing_1002',
      'name': 'Onion',
      'unit': 'g',
      'category': 'Vegetables',
      'currentStock': 3000.0,
      'alertThreshold': 200.0,
      'expiryDate': '2025-09-20',
    },
    {
      'ingredientId': 'ing_1003',
      'name': 'Mozzarella Cheese',
      'unit': 'g',
      'category': 'Dairy',
      'currentStock': 2000.0,
      'alertThreshold': 400.0,
      'expiryDate': '2025-09-12',
    },
    {
      'ingredientId': 'ing_1004',
      'name': 'Pasta',
      'unit': 'g',
      'category': 'Grains',
      'currentStock': 150.0,
      'alertThreshold': 500.0,
      'expiryDate': '2026-01-15',
    },
    {
      'ingredientId': 'ing_1005',
      'name': 'Olive Oil',
      'unit': 'ml',
      'category': 'Oils',
      'currentStock': 800.0,
      'alertThreshold': 200.0,
      'expiryDate': '2025-12-31',
    },
    {
      'ingredientId': 'ing_1006',
      'name': 'Garlic',
      'unit': 'g',
      'category': 'Vegetables',
      'currentStock': 50.0,
      'alertThreshold': 100.0,
      'expiryDate': '2025-09-11',
    },
    {
      'ingredientId': 'ing_1007',
      'name': 'Bell Pepper',
      'unit': 'g',
      'category': 'Vegetables',
      'currentStock': 1200.0,
      'alertThreshold': 250.0,
      'expiryDate': '2025-09-18',
    },
    {
      'ingredientId': 'ing_1008',
      'name': 'Chicken Breast',
      'unit': 'g',
      'category': 'Meat',
      'currentStock': 2500.0,
      'alertThreshold': 600.0,
      'expiryDate': '2025-09-14',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    loadOrderHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadOrderHistory() async {
    try {
      final orders = await _orderService.fetchOrderHistory();
      setState(() {
        orderHistory = orders;
      });
    } catch (e) {
      setState(() {
        errorMsg = 'Failed to fetch order history.';
      });
    }
  }

  Future<void> processOrder() async {
    if (selectedDishes.isEmpty && customIngredients.isEmpty) {
      setState(() {
        errorMsg = 'Please select at least one dish or ingredient.';
      });
      return;
    }
    setState(() {
      isProcessing = true;
      errorMsg = null;
      successMsg = null;
    });
    try {
      await _orderProcessingService.processOrder(
        userId: 'user_1003',
        orderedDishes: selectedDishes,
        customIngredients: customIngredients,
      );
      setState(() {
        successMsg = "Order processed successfully!";
        selectedDishes.clear();
        customIngredients.clear();
      });
      await loadOrderHistory();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Order processed successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      setState(() {
        errorMsg = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(e.toString())),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  Widget _buildDishCard(Map<String, dynamic> dish) {
    final isSelected = selectedDishes.any((d) => d['dishId'] == dish['dishId']);
    final selectedDish = selectedDishes.firstWhere(
      (d) => d['dishId'] == dish['dishId'],
      orElse: () => {'quantity': 0.0},
    );

    return Card(
      elevation: isSelected ? 8 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: Colors.orange, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                _getDishIcon(dish['category']),
                color: Colors.orange.shade700,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dish['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    dish['description'] ?? dish['category'],
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${dish['price'].toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: dish['category'] == 'Appetizer'
                              ? Colors.blue.shade100
                              : Colors.purple.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          dish['category'],
                          style: TextStyle(
                            color: dish['category'] == 'Appetizer'
                                ? Colors.blue.shade700
                                : Colors.purple.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        selectedDishes.removeWhere(
                          (d) => d['dishId'] == dish['dishId'],
                        );
                        if (selectedDish['quantity'] > 1) {
                          selectedDishes.add({
                            'dishId': dish['dishId'],
                            'quantity': selectedDish['quantity'] - 1,
                          });
                        }
                      });
                    },
                    icon: const Icon(Icons.remove),
                    iconSize: 20,
                  ),
                  Container(
                    width: 50,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      selectedDish['quantity'].toStringAsFixed(0),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        selectedDishes.removeWhere(
                          (d) => d['dishId'] == dish['dishId'],
                        );
                        selectedDishes.add({
                          'dishId': dish['dishId'],
                          'quantity': (selectedDish['quantity'] as double) + 1,
                        });
                      });
                    },
                    icon: const Icon(Icons.add),
                    iconSize: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientCard(Map<String, dynamic> ingredient) {
    final isSelected = customIngredients.any(
      (i) => i['ingredientId'] == ingredient['ingredientId'],
    );
    final selectedIngredient = customIngredients.firstWhere(
      (i) => i['ingredientId'] == ingredient['ingredientId'],
      orElse: () => {'quantity': 0.0},
    );

    final currentStock = ingredient['currentStock'] as double;
    final alertThreshold = ingredient['alertThreshold'] as double;
    final isLowStock = currentStock <= alertThreshold;
    final isExpired = _isExpired(ingredient['expiryDate']);
    final isExpiringSoon = _isExpiringSoon(ingredient['expiryDate']);

    return Card(
      elevation: isSelected ? 8 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: Colors.green, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    _getIngredientIcon(ingredient['category']),
                    color: Colors.green.shade700,
                    size: 30,
                  ),
                ),
                if (isLowStock || isExpired || isExpiringSoon)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: isExpired || isLowStock
                            ? Colors.red
                            : Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isExpired || isLowStock ? Icons.error : Icons.warning,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ingredient['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          ingredient['category'],
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isLowStock || isExpired || isExpiringSoon) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: isExpired || isLowStock
                                ? Colors.red.shade100
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isExpired
                                ? 'EXPIRED'
                                : isLowStock
                                ? 'LOW STOCK'
                                : 'EXPIRES SOON',
                            style: TextStyle(
                              color: isExpired || isLowStock
                                  ? Colors.red.shade700
                                  : Colors.orange.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Stock: ${currentStock.toStringAsFixed(0)} ${ingredient['unit']}',
                        style: TextStyle(
                          color: isLowStock
                              ? Colors.red.shade700
                              : Colors.blue.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• Exp: ${ingredient['expiryDate']}',
                        style: TextStyle(
                          color: isExpired
                              ? Colors.red.shade700
                              : isExpiringSoon
                              ? Colors.orange.shade700
                              : Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextFormField(
                initialValue: selectedIngredient['quantity'] > 0
                    ? selectedIngredient['quantity'].toString()
                    : '',
                decoration: InputDecoration(
                  hintText: '0',
                  suffixText: ingredient['unit'],
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                onChanged: (val) {
                  final qty = double.tryParse(val);
                  setState(() {
                    customIngredients.removeWhere(
                      (i) => i['ingredientId'] == ingredient['ingredientId'],
                    );
                    if (qty != null && qty > 0) {
                      customIngredients.add({
                        'ingredientId': ingredient['ingredientId'],
                        'quantity': qty,
                      });
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    if (selectedDishes.isEmpty && customIngredients.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No items selected',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                'Add dishes or ingredients to create an order',
                style: TextStyle(color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    double totalPrice = 0;
    for (var dish in selectedDishes) {
      final dishData = dishes.firstWhere((d) => d['dishId'] == dish['dishId']);
      totalPrice += dishData['price'] * dish['quantity'];
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Order Summary',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Chip(
                  label: Text(
                    '${selectedDishes.length + customIngredients.length} items',
                  ),
                  backgroundColor: Colors.orange.shade100,
                ),
              ],
            ),
            const Divider(height: 24),
            if (selectedDishes.isNotEmpty) ...[
              const Text(
                'Dishes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...selectedDishes.map((dish) {
                final dishData = dishes.firstWhere(
                  (d) => d['dishId'] == dish['dishId'],
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${dishData['name']} x${dish['quantity'].toStringAsFixed(0)}',
                        ),
                      ),
                      Text(
                        '\$${(dishData['price'] * dish['quantity']).toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
            if (customIngredients.isNotEmpty) ...[
              const Text(
                'Custom Ingredients:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...customIngredients.map((ing) {
                final ingData = ingredients.firstWhere(
                  (i) => i['ingredientId'] == ing['ingredientId'],
                );
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '${ingData['name']}: ${ing['quantity']} ${ingData['unit']}',
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
            ],
            const Divider(),
            Row(
              children: [
                const Text(
                  'Total: ',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isProcessing ? null : processOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: brownDerby[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isProcessing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        "Process Order",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHistory() {
    if (orderHistory.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.history, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No order history',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                'Processed orders will appear here',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orderHistory.length,
      itemBuilder: (context, idx) {
        final order = orderHistory[idx];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                '${idx + 1}',
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              'Order #${order.orderId.substring(0, 8)}...',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('By: ${order.processedBy}'),
                Text('Time: ${_formatDateTime(order.orderTime)}'),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (order.dishes.isNotEmpty) ...[
                      const Text(
                        'Dishes:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...order.dishes.map(
                        (dish) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '• ${dish['dishId']} (Qty: ${dish['quantity']})',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (order.customIngredients.isNotEmpty) ...[
                      const Text(
                        'Custom Ingredients:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...order.customIngredients.map(
                        (ing) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '• ${ing['ingredientId']} (Qty: ${ing['quantity']})',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getDishIcon(String category) {
    switch (category.toLowerCase()) {
      case 'main course':
        return Icons.restaurant;
      case 'appetizer':
        return Icons.tapas;
      default:
        return Icons.restaurant_menu;
    }
  }

  IconData _getIngredientIcon(String category) {
    switch (category.toLowerCase()) {
      case 'vegetables':
        return Icons.eco;
      case 'dairy':
        return Icons.local_drink;
      case 'grains':
        return Icons.grain;
      case 'oils':
        return Icons.opacity;
      case 'meat':
        return Icons.set_meal;
      default:
        return Icons.inventory_2;
    }
  }

  bool _isExpired(String expiryDate) {
    try {
      final expiry = DateTime.parse(expiryDate);
      return expiry.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  bool _isExpiringSoon(String expiryDate) {
    try {
      final expiry = DateTime.parse(expiryDate);
      final now = DateTime.now();
      final daysUntilExpiry = expiry.difference(now).inDays;
      return daysUntilExpiry <= 7 && daysUntilExpiry >= 0;
    } catch (_) {
      return false;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brownDerby[50],
      appBar: AppBar(
        title: const Text(
          'Kitchen Orders',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: brownDerby[700],
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: brownDerby[100],
          tabs: const [
            Tab(icon: Icon(Icons.restaurant_menu), text: 'Dishes'),
            Tab(icon: Icon(Icons.add_circle), text: 'Ingredients'),
            Tab(icon: Icon(Icons.history), text: 'History'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.restaurant_menu,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Select Dishes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Chip(
                            label: Text('${selectedDishes.length} selected'),
                            backgroundColor: Colors.orange.shade100,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: dishes.length,
                        itemBuilder: (context, index) =>
                            _buildDishCard(dishes[index]),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.white,
                      child: Row(
                        children: [
                          const Icon(Icons.add_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text(
                            'Add Custom Ingredients',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Chip(
                            label: Text('${customIngredients.length} added'),
                            backgroundColor: Colors.green.shade100,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: ingredients.length,
                        itemBuilder: (context, index) =>
                            _buildIngredientCard(ingredients[index]),
                      ),
                    ),
                  ],
                ),
                _buildOrderHistory(),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: (selectedDishes.isNotEmpty || customIngredients.isNotEmpty)
          ? SizedBox(
              height: 265, // adjust based on your design/content
              child: _buildOrderSummary(),
            )
          : null,
    );
  }
}
