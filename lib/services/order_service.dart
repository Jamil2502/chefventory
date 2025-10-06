class OrderService {
  final Map<String, double> _stock = {
    "Tomato": 10,
    "Onion": 8,
    "Cheese": 5,
    "Lettuce": 6,
    "Cucumber": 4,
  };

  Map<String, dynamic> createOrder(
      Map<String, int> dishQuantities, Map<String, double> customIngredients) {
    // Calculate required ingredients
    final Map<String, double> required = {};

    // Dummy dish recipes
    final Map<String, Map<String, double>> recipes = {
      "Pasta": {"Tomato": 2, "Onion": 1},
      "Pizza": {"Cheese": 3, "Tomato": 2},
      "Salad": {"Lettuce": 2, "Cucumber": 1},
    };

    dishQuantities.forEach((dish, qty) {
      if (recipes.containsKey(dish)) {
        recipes[dish]!.forEach((ingredient, amount) {
          required[ingredient] = (required[ingredient] ?? 0) + amount * qty;
        });
      }
    });

    // Add custom ingredients
    customIngredients.forEach((ingredient, amount) {
      required[ingredient] = (required[ingredient] ?? 0) + amount;
    });

    // Validate stock
    for (final entry in required.entries) {
      final available = _stock[entry.key] ?? 0;
      if (available < entry.value) {
        return {
          "success": false,
          "message":
              "Insufficient stock for ${entry.key}. Required: ${entry.value}, Available: $available"
        };
      }
    }

    // Deduct stock
    required.forEach((ingredient, amount) {
      _stock[ingredient] = (_stock[ingredient] ?? 0) - amount;
    });

    return {
      "success": true,
      "message": "Order processed successfully!\nStock updated."
    };
  }
}
