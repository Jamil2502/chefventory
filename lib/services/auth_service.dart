import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_config.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Sample users for development/testing
  final Map<String, Map<String, String>> _sampleUsers = {
    'manager@restaurant.com': {
      'password': 'admin123',
      'role': 'admin',
      'username': 'restaurant_manager',
      'userId': 'user_1001',
    },
    'chef@restaurant.com': {
      'password': 'admin123', 
      'role': 'admin',
      'username': 'head_chef',
      'userId': 'user_1002',
    },
    'staff1@restaurant.com': {
      'password': 'staff123',
      'role': 'staff',
      'username': 'kitchen_staff1',
      'userId': 'user_1003',
    },
    'staff2@restaurant.com': {
      'password': 'staff123',
      'role': 'staff', 
      'username': 'kitchen_staff2',
      'userId': 'user_1004',
    },
  };

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<Map<String, dynamic>> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Check if user exists in sample data
      if (_sampleUsers.containsKey(email.toLowerCase())) {
        final userData = _sampleUsers[email.toLowerCase()]!;
        
        // Validate password
        if (userData['password'] != password) {
          return {
            'success': false,
            'error': 'Invalid email or password',
          };
        }

        try {
          final userDoc = await _firestore
              .collection('users')
              .doc(userData['userId'])
              .get();

          if (userDoc.exists) {
            final firestoreData = userDoc.data()!;
            return {
              'success': true,
              'role': firestoreData['role'],
              'username': firestoreData['username'],
              'email': firestoreData['email'],
              'userId': userData['userId'],
            };
          } else {
            return {
              'success': true,
              'role': userData['role']!,
              'username': userData['username']!,
              'email': email,
              'userId': userData['userId']!,
            };
          }
        } catch (firestoreError) {
          return {
            'success': true,
            'role': userData['role']!,
            'username': userData['username']!,
            'email': email,
            'userId': userData['userId']!,
          };
        }
      } else {
        return {
          'success': false,
          'error': 'User not found',
        };
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email address';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many failed attempts. Please try again later';
          break;
        default:
          errorMessage = 'Authentication failed: ${e.message}';
      }
      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  Future<Map<String, dynamic>> signUpWithEmailAndPassword(
    String email,
    String password,
    String username,
    String role,
  ) async {
    try {

      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(result.user!.uid).set({
        'userId': result.user!.uid,
        'username': username,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'user': result.user,
        'role': role,
        'username': username,
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists with this email';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format';
          break;
        default:
          errorMessage = 'Registration failed: ${e.message}';
      }
      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred during registration.',
      };
    }
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  Future<bool> updateUserProfile({
    required String userId,
    String? username,
    String? email,
  }) async {
    try {
      Map<String, dynamic> updates = {};
      
      if (username != null) updates['username'] = username;
      if (email != null) updates['email'] = email;
      
      updates['lastUpdated'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('users')
          .doc(userId)
          .update(updates);

      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return {
        'success': true,
        'message': 'Password reset email sent successfully',
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email address';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email address format';
          break;
        default:
          errorMessage = 'Failed to send reset email: ${e.message}';
      }
      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'An unexpected error occurred.',
      };
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Future<bool> isAdmin(String userId) async {
    try {
      final userData = await getUserData(userId);
      return userData?['role'] == 'admin';
    } catch (e) {
      return false;
    }
  }

  Future<bool> isStaff(String userId) async {
    try {
      final userData = await getUserData(userId);
      return userData?['role'] == 'staff';
    } catch (e) {
      return false;
    }
  }

  Future<String?> getUserRole(String userId) async {
    try {
      final userData = await getUserData(userId);
      return userData?['role'];
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> validateSession() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final userData = await getUserData(user.uid);
      if (userData == null) return null;

      return {
        'userId': user.uid,
        'email': user.email,
        'username': userData['username'],
        'role': userData['role'],
        'isEmailVerified': user.emailVerified,
      };
    } catch (e) {
      print('Error validating session: $e');
      return null;
    }
  }


  List<Map<String, dynamic>> getSampleUsers() {
    return _sampleUsers.entries.map((entry) {
      return {
        'email': entry.key,
        'password': entry.value['password'],
        'role': entry.value['role'],
        'username': entry.value['username'],
        'userId': entry.value['userId'],
      };
    }).toList();
  }
}