import 'package:flutter/foundation.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?.role == 'admin';
  bool get isStaff => _currentUser?.role == 'staff';

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    setLoading(true);
    setError(null);

    try {
      // Simulate API call - replace with actual Firebase Auth
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock authentication logic
      if (username == 'admin' && password == 'admin123') {
        _currentUser = User(
          username: 'Admin User',
          email: 'admin@chefventory.com',
          role: 'admin',
        );
        setLoading(false);
        return true;
      } else if (username == 'staff' && password == 'staff123') {
        _currentUser = User(
          username: 'Staff User',
          email: 'staff@chefventory.com',
          role: 'staff',
        );
        setLoading(false);
        return true;
      } else {
        setError('Invalid credentials');
        setLoading(false);
        return false;
      }
    } catch (e) {
      setError('Login failed: ${e.toString()}');
      setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
