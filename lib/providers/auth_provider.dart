import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';
import '../services/firebase_auth_service.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<bool> adminSignUp({
    required String email,
    required String password,
    required String restaurantName,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.adminSignUp(
        email: email,
        password: password,
        restaurantName: restaurantName,
      );

      _currentUser = await _authService.getCurrentUser();
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<String?> staffSignUp({
    required String email,
    required String password,
    required String staffId,
    required String adminEmail,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      String otp = await _authService.staffSignUp(
        email: email,
        password: password,
        staffId: staffId,
        adminEmail: adminEmail,
      );

      _setLoading(false);
      return otp; // In production, don't return OTP
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return null;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await _authService.signIn(email: email, password: password);
      _currentUser = await _authService.getCurrentUser();
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> checkAuthStatus() async {
    _currentUser = await _authService.getCurrentUser();
    notifyListeners();
  }
}
