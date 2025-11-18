import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import 'inventory_provider.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  Map<String, dynamic>? _currentUser;
  String? _currentSessionId;
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? get currentUser => _currentUser;
  String? get currentSessionId => _currentSessionId;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _currentUser?['role'] == 'admin';
  bool get isStaff => _currentUser?['role'] == 'staff';
  String? get restaurantId => _currentUser?['restaurantId'];

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    
    _currentUser = await _authService.getCurrentUser();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signUpAdmin({
    required String restaurantName,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _authService.signUpAdmin(
        restaurantName: restaurantName,
        username: username,
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update inventory provider with correct restaurant ID
  void syncInventoryProvider(InventoryProvider inventoryProvider) {
    if (_currentUser != null && _currentUser!['restaurantId'] != null) {
      inventoryProvider.setRestaurantId(_currentUser!['restaurantId']);
    }
  }

  Future<bool> signUpStaff({
    required String restaurantId,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _authService.signUpStaff(
        restaurantId: restaurantId,
        username: username,
        email: email,
        password: password,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _currentUser = await _authService.signIn(
        email: email,
        password: password,
      );

      // Store session ID to track current session
      _currentSessionId = _currentUser?['sessionId'];

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    _currentSessionId = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

