import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/order_provider.dart';
import '../../services/activity_service.dart';

class StaffAuthScreen extends StatefulWidget {
  @override
  _StaffAuthScreenState createState() => _StaffAuthScreenState();
}

class _StaffAuthScreenState extends State<StaffAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  
  bool _isSignUp = true;
  bool _isLoading = false;
  
  // Controllers
  final _restaurantIdController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _restaurantIdController.dispose();
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
        // Staff Signup via AuthProvider
        final success = await authProvider.signUpStaff(
          restaurantId: _restaurantIdController.text.trim(),
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        if (success) {
          result = authProvider.currentUser;
        }
      } else {
        // Staff Signin via AuthProvider
        final success = await authProvider.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        
        if (success) {
          result = authProvider.currentUser;
        }
      }

      // Set restaurant ID in InventoryProvider and OrderProvider
      if (result != null && mounted) {
        final restaurantId = result['restaurantId'] as String;
        final username = result['username'] as String? ?? 'Staff';
        if (mounted) {
          Provider.of<InventoryProvider>(context, listen: false).setRestaurantId(restaurantId);
          Provider.of<OrderProvider>(context, listen: false).setRestaurantId(restaurantId);
          await Provider.of<InventoryProvider>(context, listen: false).loadInventory();
          await Provider.of<OrderProvider>(context, listen: false).loadOrderHistory();
          
          // Log staff login activity
          await ActivityService().logActivity(
            restaurantId: restaurantId,
            type: 'staff_login',
            itemName: username,
            description: 'Staff member logged in',
          );
        }
      }

      // Navigate to Staff Dashboard
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/staff-dashboard', arguments: result);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        title: Text(_isSignUp ? 'Staff Sign Up' : 'Staff Sign In'),
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
              Icon(Icons.people, size: 80, color: AppTheme.primaryBrown),
              const SizedBox(height: 30),

              // Restaurant ID (only for signup)
              if (_isSignUp)
                TextFormField(
                  controller: _restaurantIdController,
                  decoration: InputDecoration(
                    labelText: 'Restaurant ID',
                    prefixIcon: Icon(Icons.badge),
                    border: OutlineInputBorder(),
                    helperText: 'Get this from your restaurant admin',
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter restaurant ID' : null,
                ),
              if (_isSignUp) SizedBox(height: 15),

              // Username (only for signup)
              if (_isSignUp)
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Your Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                ),
              if (_isSignUp) SizedBox(height: 15),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter email';
                  if (!value.contains('@')) return 'Enter valid email';
                  return null;
                },
              ),
              SizedBox(height: 15),

              // Password
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) return 'Enter password';
                  if (value.length < 6) return 'Password must be 6+ characters';
                  return null;
                },
              ),
              SizedBox(height: 25),

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
                        _isSignUp ? 'Join as Staff' : 'Sign In',
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