import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/currency.dart';
import '../../models/dish.dart';

class OrderProcessingScreen extends StatefulWidget {
  const OrderProcessingScreen({super.key});

  @override
  State<OrderProcessingScreen> createState() => _OrderProcessingScreenState();
}

class _OrderProcessingScreenState extends State<OrderProcessingScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'THIS IS ORDERS',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppTheme.primaryBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

}