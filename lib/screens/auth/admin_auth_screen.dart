import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/order_provider.dart';

class AdminAuthScreen extends StatefulWidget {
  @override
  _AdminAuthScreenState createState() => _AdminAuthScreenState();
}

class _AdminAuthScreenState extends State<AdminAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  
  bool _isSignUp = true;
  bool _isLoading = false;
  
  // Controllers
  final _restaurantNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _restaurantNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Map<String, dynamic>? result;

      if (_isSignUp) {
        // Admin Signup via AuthProvider
        final success = await authProvider.signUpAdmin(
          restaurantName: _restaurantNameController.text.trim(),
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        if (success) {
          result = authProvider.currentUser;
          // Show restaurant ID to admin
          if (result != null) {
            _showRestaurantIdDialog(result['restaurantId']);
          }
        }
      } else {
        // Admin Signin via AuthProvider
        final success = await authProvider.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        if (success) {
          result = authProvider.currentUser;
        }
      }

      // Sync restaurant ID with InventoryProvider and OrderProvider
      if (result != null && mounted) {
        final restaurantId = result['restaurantId'] as String;
        if (mounted) {
          Provider.of<InventoryProvider>(context, listen: false).setRestaurantId(restaurantId);
          Provider.of<OrderProvider>(context, listen: false).setRestaurantId(restaurantId);
          await Provider.of<InventoryProvider>(context, listen: false).loadInventory();
          await Provider.of<OrderProvider>(context, listen: false).loadOrderHistory();
        }
      }

      // Navigate to Admin Dashboard
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/admin-dashboard', arguments: result);
      }
      
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showRestaurantIdDialog(String restaurantId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Restaurant Created Successfully!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your Restaurant ID:'),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: SelectableText(
                restaurantId,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade900,
                ),
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Share this ID with your staff members so they can join your restaurant.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        title: Text(_isSignUp ? 'Admin Sign Up' : 'Admin Sign In'),
        backgroundColor: AppTheme.primaryBrown,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Icon(Icons.admin_panel_settings, size: 80, color: AppTheme.primaryBrown),
              const SizedBox(height: 30),

              // Restaurant Name (only for signup)
              if (_isSignUp)
                TextFormField(
                  controller: _restaurantNameController,
                  decoration: InputDecoration(
                    labelText: 'Restaurant Name',
                    prefixIcon: const Icon(Icons.restaurant),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppTheme.primaryBrown),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter restaurant name' : null,
                ),
              if (_isSignUp) const SizedBox(height: 15),

              // Username (only for signup)
              if (_isSignUp)
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Your Name',
                    prefixIcon: const Icon(Icons.person),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppTheme.primaryBrown),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                ),
              if (_isSignUp) const SizedBox(height: 15),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: const Icon(Icons.email),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.primaryBrown),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter email';
                  if (!value.contains('@')) return 'Enter valid email';
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Password
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTheme.primaryBrown),
                  ),
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter password';
                  if (value.length < 6) return 'Password must be 6+ characters';
                  return null;
                },
              ),
              const SizedBox(height: 25),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleAuth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isSignUp ? 'Create Admin Account' : 'Sign In',
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
              const SizedBox(height: 15),

              // Toggle Sign In/Sign Up
              TextButton(
                onPressed: () {
                  setState(() => _isSignUp = !_isSignUp);
                },
                child: Text(
                  _isSignUp
                      ? 'Already have an account? Sign In'
                      : 'Need an account? Sign Up',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
