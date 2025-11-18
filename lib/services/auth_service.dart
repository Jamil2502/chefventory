import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Generate unique restaurant ID in format rest_001, rest_002, etc.
  Future<String> _generateRestaurantId() async {
    try {
      // Get the count of existing restaurants
      QuerySnapshot snapshot = await _db.collection('restaurants').get();
      int count = snapshot.docs.length + 1;
      return 'rest_${count.toString().padLeft(3, '0')}';
    } catch (e) {
      // Fallback to timestamp-based if query fails
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return 'rest_${timestamp % 10000}';
    }
  }

  // ========== ADMIN SIGNUP ==========
  Future<Map<String, dynamic>?> signUpAdmin({
    required String restaurantName,
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // 1. Create Firebase Auth user
      firebase_auth.UserCredential userCredential = 
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user!.uid;
      String restaurantId = await _generateRestaurantId();

      // 2. Create Restaurant document
      await _db.collection('restaurants').doc(restaurantId).set({
        'restaurantId': restaurantId,
        'name': restaurantName,
        'ownerId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      // 3. Create Admin user document
      // Ensure auth state & token are ready for Firestore security rules
      try {
        await userCredential.user?.reload();
        await userCredential.user?.getIdToken(true);
      } catch (_) {}

      await _db
          .collection('restaurants')
          .doc(restaurantId)
          .collection('users')
          .doc(userId)
          .set({
        'userId': userId,
        'username': username,
        'email': email,
        'role': 'admin',
        'restaurantId': restaurantId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 4. Store restaurant ID in user's custom claims (optional but useful)
      await _db.collection('userProfiles').doc(userId).set({
        'restaurantId': restaurantId,
        'role': 'admin',
        'email': email,
      });

      return {
        'userId': userId,
        'username': username,
        'email': email,
        'role': 'admin',
        'restaurantId': restaurantId,
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Signup failed: $e';
    }
  }

  // ========== STAFF SIGNUP ==========
  Future<Map<String, dynamic>?> signUpStaff({
    required String restaurantId,
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // STEP 0: Validate that restaurant exists before creating staff account
      final restaurantDoc = await _db.collection('restaurants').doc(restaurantId).get();
      if (!restaurantDoc.exists) {
        throw 'Restaurant ID not found. Please verify the ID with your admin.';
      }

      // STEP 1: Create Firebase Auth user (automatically signs in)
      firebase_auth.UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user!.uid;

      // Refresh token to ensure Firestore rules can read user document
      try {
        await userCredential.user?.reload();
        await userCredential.user?.getIdToken(true);
      } catch (_) {}

      // STEP 2: Write to userProfiles first (owner-created, no admin needed)
      await _db.collection('userProfiles').doc(userId).set({
        'userId': userId,
        'email': email,
        'username': username,
        'role': 'staff',
        'restaurantId': restaurantId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // STEP 3: Write to restaurant-scoped users collection
      await _db
          .collection('restaurants')
          .doc(restaurantId)
          .collection('users')
          .doc(userId)
          .set({
        'userId': userId,
        'username': username,
        'email': email,
        'role': 'staff',
        'restaurantId': restaurantId,
        'department': 'kitchen',
        'shift': 'morning',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {
        'userId': userId,
        'username': username,
        'email': email,
        'role': 'staff',
        'restaurantId': restaurantId,
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Staff signup failed: $e';
    }
  }

  // ========== SIGN IN (Works for both Admin and Staff) ==========
  Future<Map<String, dynamic>?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Sign in with Firebase Auth
      firebase_auth.UserCredential userCredential = 
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String userId = userCredential.user!.uid;

      // Refresh token to ensure Firestore rules can read user document
      try {
        await userCredential.user?.reload();
        await userCredential.user?.getIdToken(true);
      } catch (_) {}

      // 2. Get user profile to find restaurant ID
      DocumentSnapshot profileDoc = 
          await _db.collection('userProfiles').doc(userId).get();
      
      if (!profileDoc.exists) {
        throw 'User profile not found. Please contact support.';
      }

      Map<String, dynamic> profileData = profileDoc.data() as Map<String, dynamic>;
      String restaurantId = profileData['restaurantId'];

      // 3. Get full user details from restaurant's users collection
      DocumentSnapshot userDoc = await _db
          .collection('restaurants')
          .doc(restaurantId)
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw 'User data not found.';
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // 4. Check for concurrent sessions - prevent multiple logins of same account
      final sessionDoc = await _db.collection('activeSessions').doc(userId).get();
      if (sessionDoc.exists) {
        final sessionData = sessionDoc.data() as Map<String, dynamic>;
        final sessionId = sessionData['sessionId'] as String?;
        
        // If a session exists and is different, this is a concurrent login attempt
        if (sessionId != null) {
          throw 'This account is already logged in on another device. Please sign out from the other device first.';
        }
      }

      // 5. Create new session
      final newSessionId = DateTime.now().millisecondsSinceEpoch.toString();
      await _db.collection('activeSessions').doc(userId).set({
        'userId': userId,
        'sessionId': newSessionId,
        'email': userData['email'],
        'role': userData['role'],
        'restaurantId': restaurantId,
        'loginTime': FieldValue.serverTimestamp(),
        'lastActivity': FieldValue.serverTimestamp(),
      });

      return {
        'userId': userId,
        'sessionId': newSessionId,
        'username': userData['username'],
        'email': userData['email'],
        'role': userData['role'],
        'restaurantId': restaurantId,
        'department': userData['department'], // For staff
        'shift': userData['shift'], // For staff
      };
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Sign in failed: $e';
    }
  }

  // ========== SIGN OUT ==========
  Future<void> signOut() async {
    try {
      // Remove session from Firestore
      firebase_auth.User? firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        await _db.collection('activeSessions').doc(firebaseUser.uid).delete();
      }
    } catch (e) {
      print('Error removing session: $e');
    }
    
    // Sign out from Firebase Auth
    await _auth.signOut();
  }

  // ========== GET CURRENT USER ==========
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      firebase_auth.User? firebaseUser = _auth.currentUser;
      if (firebaseUser == null) return null;

      String userId = firebaseUser.uid;

      // Get user profile
      DocumentSnapshot profileDoc = 
          await _db.collection('userProfiles').doc(userId).get();
      
      if (!profileDoc.exists) return null;

      Map<String, dynamic> profileData = profileDoc.data() as Map<String, dynamic>;
      String restaurantId = profileData['restaurantId'];

      // Get full user details
      DocumentSnapshot userDoc = await _db
          .collection('restaurants')
          .doc(restaurantId)
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) return null;

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      return {
        'userId': userId,
        'username': userData['username'],
        'email': userData['email'],
        'role': userData['role'],
        'restaurantId': restaurantId,
      };
    } catch (e) {
      return null;
    }
  }

  // ========== PASSWORD RESET ==========
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ========== ERROR HANDLING ==========
  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'This email is already registered. Try signing in.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Try again later.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
