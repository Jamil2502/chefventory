import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/restaurant.dart';
import 'dart:math';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate Restaurant ID
  String _generateRestaurantId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  // Admin Sign Up
  Future<UserCredential?> adminSignUp({
    required String email,
    required String password,
    required String restaurantName,
  }) async {
    try {
      // Check if admin email already exists
      final existingAdmin = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .where('role', isEqualTo: 'admin')
          .get();

      if (existingAdmin.docs.isNotEmpty) {
        throw Exception('Admin with this email already exists');
      }

      // Create user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Generate restaurant ID
      String restaurantId = _generateRestaurantId();

      // Create restaurant document
      await _firestore.collection('restaurants').doc(restaurantId).set({
        'name': restaurantName,
        'adminEmail': email,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Create user document
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': 'admin',
        'restaurantId': restaurantId,
        'restaurantName': restaurantName,
        'isVerified': true,
        'createdAt': DateTime.now().toIso8601String(),
      });

      return userCredential;
    } catch (e) {
      throw Exception('Failed to create admin account: ${e.toString()}');
    }
  }

  // Staff Sign Up
  Future<String> staffSignUp({
    required String email,
    required String password,
    required String staffId,
    required String adminEmail,
  }) async {
    try {
      // Check if admin exists
      final adminQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: adminEmail)
          .where('role', isEqualTo: 'admin')
          .get();

      if (adminQuery.docs.isEmpty) {
        throw Exception('Admin with this email does not exist');
      }

      // Check if staff email already exists
      final existingStaff = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (existingStaff.docs.isNotEmpty) {
        throw Exception('Staff with this email already exists');
      }

      // Create user
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel admin = UserModel.fromMap(adminQuery.docs.first.data(), adminQuery.docs.first.id);

      // Create staff document (unverified)
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'role': 'staff',
        'staffId': staffId,
        'adminEmail': adminEmail,
        'restaurantId': admin.restaurantId,
        'restaurantName': admin.restaurantName,
        'isVerified': false,
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Generate OTP and send notification to admin
      String otp = _generateOTP();
      await _firestore.collection('staff_verifications').add({
        'staffEmail': email,
        'adminEmail': adminEmail,
        'otp': otp,
        'staffId': staffId,
        'createdAt': DateTime.now().toIso8601String(),
        'isUsed': false,
      });

      // In a real app, you would send an email here
      // For now, we'll return the OTP (in production, don't do this)
      return otp;
    } catch (e) {
      throw Exception('Failed to create staff account: ${e.toString()}');
    }
  }

  String _generateOTP() {
    Random rnd = Random();
    return (100000 + rnd.nextInt(900000)).toString();
  }

  // Sign In
  Future<UserCredential?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if user exists in Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        await _auth.signOut();
        throw Exception('User not found in database');
      }

      UserModel user = UserModel.fromMap(userDoc.data() as Map<String, dynamic>, userDoc.id);

      if (user.role == 'staff' && !user.isVerified) {
        await _auth.signOut();
        throw Exception('Staff account not verified by admin yet');
      }

      return userCredential;
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  // Get Current User
  Future<UserModel?> getCurrentUser() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;

    DocumentSnapshot userDoc = await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();

    if (!userDoc.exists) return null;

    return UserModel.fromMap(userDoc.data() as Map<String, dynamic>, userDoc.id);
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
