import 'package:flutter/material.dart';
import 'package:chefventory/services/dish_services.dart';
import 'package:chefventory/models/dish.dart';
import 'package:chefventory/models/ingredient.dart';

class AddDishScreen extends StatefulWidget {
  const AddDishScreen({super.key});

  @override
  State<AddDishScreen> createState() => _AddDishScreenState();
}

class _AddDishScreenState extends State<AddDishScreen> {
  final _formKey = GlobalKey<FormState>();//check if entered data is correct before saving data 
  final _dishNameController = TextEditingController();//keeping track of text user types in search box
  final _ingredientSearchController = TextEditingController();//same here

  List<Ingredient> searchResults = [];
  Map<String, double> selectedIngredients = {}; // map to store chosen ingredients and quantities 
  List<Dish> dishes = [];

  @override
  void initState() {
    super.initState();
    dishes = [];
  }

  void _searchIngredients(String query) { //everytime the backend sends new results dart suns setState to update and show in UI 
    DishService().searchIngredients(query).listen((results) {//everytime a new value is emitted the callback function is executed 
      setState(() => searchResults = results);
    });
  }

  void _addIngredient(String name, double quantity) {
    setState(() => selectedIngredients[name] = quantity);
  }

  Future<void> _submitDish() async {
    if (_formKey.currentState!.validate() && selectedIngredients.isNotEmpty) {
      final dish = Dish(
        name: _dishNameController.text,
        description: "Enter description", 
        basePrice: 0.0,  
        ingredientRequirements: selectedIngredients,
        category: "Enter category", 
      );
      
      
      await DishService().addDish(dish);

       setState(() {
        dishes.add(dish); 
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dish added successfully!')),
      );

      _formKey.currentState!.reset();
      setState(() {
        _dishNameController.clear();
        _ingredientSearchController.clear();
        selectedIngredients.clear();
        searchResults.clear();
      });
    }
  }
  
  Widget _buildDishList() {
    if (dishes.isEmpty) return Container();
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: dishes.map((dish) {
          return Card(
            child: ListTile(
              title: Text(dish.name),
              subtitle: Text(
                dish.ingredientRequirements.entries
                    .map((e) => '${e.key} (${e.value})')
                    .join(', '),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7EEE9),
      appBar: AppBar(
        title: const Text('Add Dish', style: TextStyle(color: Color(0xFFF8EBE3))),
        backgroundColor: const Color(0xFF8D5C2C),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildDishList(),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 7,
                  margin: const EdgeInsets.all(25),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: _dishNameController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter dish name';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: "Dish Name",
                              prefixIcon: const Icon(Icons.restaurant),
                              filled: true,
                              fillColor: Colors.brown[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _ingredientSearchController,
                            onChanged: _searchIngredients,
                            decoration: InputDecoration(
                              labelText: "Search Ingredient",
                              prefixIcon: const Icon(Icons.local_grocery_store),
                              filled: true,
                              fillColor: Colors.brown[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          ...searchResults.map((ingredient) => ListTile(
                            title: Text(ingredient.name),
                            trailing: TextButton(
                              child: const Text('Add'),
                              onPressed: () async {
                                double qty = 0;
                                await showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text('Enter quantity for ${ingredient.name}'),
                                      content: TextField(
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: "Quantity (e.g. 50)",
                                        ),
                                        onChanged: (val) {
                                          qty = double.tryParse(val) ?? 0;
                                        },
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            if (qty > 0) _addIngredient(ingredient.name, qty);
                                          },
                                          child: const Text('Add'),
                                        ),
                                      ],
                                    ));
                              },
                            ),
                          )),
                          if (selectedIngredients.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            Wrap(
                              spacing: 10,
                              children: selectedIngredients.entries.map((entry) => Chip(
                                label: Text('${entry.key} (${entry.value})'),
                                deleteIcon: const Icon(Icons.cancel),
                                onDeleted: () {
                                  setState(() { selectedIngredients.remove(entry.key); });
                                },
                              )).toList(),
                            ),
                          ],
                          const SizedBox(height: 36),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.add_circle_outline , color:Color(0xFFF8EBE3)),
                              label: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text("Add Dish", style: TextStyle(fontSize: 18 , color:Color(0xFFF8EBE3))),
                              ),
                              onPressed: _submitDish,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.brown,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}