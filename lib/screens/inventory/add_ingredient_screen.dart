import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/ingredient.dart';

class AddIngredientScreen extends StatefulWidget {
  const AddIngredientScreen({super.key});

  @override
  State<AddIngredientScreen> createState() => _AddIngredientScreenState();
}

class _AddIngredientScreenState extends State<AddIngredientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  final _unitController = TextEditingController();
  final _thresholdController = TextEditingController();
  DateTime? _selectedExpiryDate;
  bool _hasExpiryDate = false;

  final List<String> _commonUnits = [
    'kg',
    'g',
    'lb',
    'oz',
    'pieces',
    'liters',
    'ml',
    'cups',
    'tbsp',
    'tsp',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _unitController.dispose();
    _thresholdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Ingredient'),
        actions: [
          TextButton(
            onPressed: _handleSave,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppTheme.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ingredient Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ingredient Name',
                  hintText: 'e.g., Tomatoes, Ground Beef',
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ingredient name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Stock Quantity and Unit
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'Initial Stock',
                        hintText: '0.0',
                        prefixIcon: Icon(Icons.scale),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final quantity = double.tryParse(value);
                        if (quantity == null || quantity < 0) {
                          return 'Invalid quantity';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _unitController.text.isNotEmpty
                          ? _unitController.text
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      items: _commonUnits.map((unit) {
                        return DropdownMenuItem(value: unit, child: Text(unit));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _unitController.text = value;
                        }
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Alert Threshold
              TextFormField(
                controller: _thresholdController,
                decoration: const InputDecoration(
                  labelText: 'Alert Threshold',
                  hintText: 'Minimum stock before alert',
                  prefixIcon: Icon(Icons.warning),
                  helperText: 'Alert when stock falls below this amount',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter alert threshold';
                  }
                  final threshold = double.tryParse(value);
                  if (threshold == null || threshold < 0) {
                    return 'Invalid threshold';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Expiry Date Toggle
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _hasExpiryDate,
                            onChanged: (value) {
                              setState(() {
                                _hasExpiryDate = value ?? false;
                                if (!_hasExpiryDate) {
                                  _selectedExpiryDate = null;
                                }
                              });
                            },
                          ),
                          const Text('Has expiry date'),
                        ],
                      ),
                      if (_hasExpiryDate) ...[
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _selectExpiryDate,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppTheme.grey.withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: AppTheme.grey,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _selectedExpiryDate != null
                                      ? 'Expires: ${_formatDate(_selectedExpiryDate!)}'
                                      : 'Select expiry date',
                                  style: TextStyle(
                                    color: _selectedExpiryDate != null
                                        ? AppTheme.black
                                        : AppTheme.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _handleSave,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Add Ingredient',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectExpiryDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _selectedExpiryDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedExpiryDate = date;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final stock = double.parse(_stockController.text);
      final unit = _unitController.text.trim();
      final threshold = double.parse(_thresholdController.text);

      final ingredient = Ingredient(
        name: name,
        initialStock: stock,
        unit: unit,
        expiryDate: _hasExpiryDate ? _selectedExpiryDate : null,
      );

      ingredient.updateAlertThreshold(threshold);

      final success = await Provider.of<InventoryProvider>(
        context,
        listen: false,
      ).addIngredient(ingredient);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name added successfully'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.of(context).pop();
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add ingredient'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }
}
