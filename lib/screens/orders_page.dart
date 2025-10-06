import 'package:flutter/material.dart';
import '../services/order_service.dart';

class OrdersPage extends StatefulWidget {
  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final OrderService _orderService = OrderService();

  // Dummy dish list (replace with real menu later)
  final List<Map<String, dynamic>> _dishes = [
    {"name": "Pasta", "ingredients": {"Tomato": 2, "Onion": 1}},
    {"name": "Pizza", "ingredients": {"Cheese": 3, "Tomato": 2}},
    {"name": "Salad", "ingredients": {"Lettuce": 2, "Cucumber": 1}},
  ];

  final Map<String, int> _dishQuantities = {};
  final Map<String, double> _customIngredients = {};

  final TextEditingController _ingredientController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Orders")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Text("Select Dishes", style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 10),

                  // Dish selection
                  ..._dishes.map((dish) {
                    return ListTile(
                      title: Text(dish["name"]),
                      trailing: SizedBox(
                        width: 120,
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  final current = _dishQuantities[dish["name"]] ?? 0;
                                  if (current > 0) {
                                    _dishQuantities[dish["name"]] = current - 1;
                                    if (_dishQuantities[dish["name"]] == 0) {
                                      _dishQuantities.remove(dish["name"]);
                                    }
                                  }
                                });
                              },
                            ),
                            Text("${_dishQuantities[dish["name"]] ?? 0}"),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  _dishQuantities[dish["name"]] =
                                      (_dishQuantities[dish["name"]] ?? 0) + 1;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  Divider(),
                  Text("Custom Ingredients", style: Theme.of(context).textTheme.titleLarge),
                  SizedBox(height: 10),

                  // Input fields for custom ingredient
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _ingredientController,
                          decoration: InputDecoration(
                            labelText: "Ingredient Name",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: TextField(
                          controller: _quantityController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Qty",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final name = _ingredientController.text.trim();
                          final qty = double.tryParse(_quantityController.text.trim()) ?? 0;

                          if (name.isNotEmpty && qty > 0) {
                            setState(() {
                              _customIngredients[name] = (_customIngredients[name] ?? 0) + qty;
                            });
                            _ingredientController.clear();
                            _quantityController.clear();
                          }
                        },
                        child: Text("Add"),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),

                  // List of custom ingredients
                  ..._customIngredients.entries.map((entry) => ListTile(
                        title: Text("${entry.key}"),
                        subtitle: Text("${entry.value} units"),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _customIngredients.remove(entry.key);
                            });
                          },
                        ),
                      )),
                ],
              ),
            ),

            // Confirm Button
            ElevatedButton(
              onPressed: () {
                final result =
                    _orderService.createOrder(_dishQuantities, _customIngredients);

                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(result["success"] ? "Order Confirmed" : "Order Failed"),
                    content: Text(result["message"]),
                    actions: [
                      TextButton(
                        child: Text("OK"),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                );
              },
              child: Text("Confirm Order"),
            ),
          ],
        ),
      ),
    );
  }
}
