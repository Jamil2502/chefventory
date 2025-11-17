import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/ingredient.dart';
import 'add_ingredient_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'THIS IS INVENTORY',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppTheme.primaryBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _navigateToAddIngredient(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddIngredientScreen()),
    );
  }
}