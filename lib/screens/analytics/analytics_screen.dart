import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'THIS IS ANALYTICS',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppTheme.primaryBrown,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

}