import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:email_validator/email_validator.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  // School email domains for validation
  final List<String> _allowedDomains = [
    'school.edu',
    'university.edu',
    'college.edu',
    'student.edu',
    // Add more school domains as needed
  ];

  /// Validates if email is from an educational institution
  bool isValidSchoolEmail(String email) {
    if (!EmailValidator.validate(email)) return false;
    
    String domain = email.split('@').last.toLowerCase();
    return _allowedDomains.any((allowedDomain) => domain.endsWith(allowedDomain));
  }

  /// Register a new user
  Future<String?> register({
    required String email,
    required String password,
    required String name,
    required UserType userType,
    String? teacherId,
  }) async {
    try {
      // Validate school email for students
      if (userType == UserType.student && !isValidSchoolEmail(email)) {
        return 'Please use a valid school email address';
      }

      // Create user with Firebase Auth
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Create user model
        final user = UserModel(
          id: credential.user!.uid,
          email: email,
          name: name,
          userType: userType,
          teacherId: teacherId,
          createdAt: DateTime.now(),
        );

        // Save user data locally
        await _saveUserData(user);
        _currentUser = user;

        // Update display name
        await credential.user!.updateDisplayName(name);

        return null; // Success
      }
      return 'Registration failed';
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);
    } catch (e) {
      return 'An unexpected error occurred: ${e.toString()}';
    }
  }

  /// Sign in existing user
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        // Load user data
        UserModel? user = await _loadUserData(credential.user!.uid);
        if (user != null) {
          _currentUser = user;
          return null; // Success
        } else {
          // User data not found, might need to complete registration
          return 'User profile not found. Please contact administrator.';
        }
      }
      return 'Sign in failed';
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);
    } catch (e) {
      return 'An unexpected error occurred: ${e.toString()}';
    }
  }

  /// Sign out user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      await _clearUserData();
    } catch (e) {
      // Handle error silently or show notification
    }
  }

  /// Reset password
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthError(e);
    } catch (e) {
      return 'Failed to send reset email';
    }
  }

  /// Check if teacher ID exists (mock implementation)
  Future<bool> teacherIdExists(String teacherId) async {
    // TODO: Implement actual teacher ID validation with backend
    // For now, return true for demo purposes
    await Future.delayed(const Duration(milliseconds: 500));
    return teacherId.isNotEmpty && teacherId.length >= 3;
  }

  /// Initialize auth state
  Future<void> initialize() async {
    User? firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      _currentUser = await _loadUserData(firebaseUser.uid);
    }
  }

  /// Save user data to local storage
  Future<void> _saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user.toMap()));
  }

  /// Load user data from local storage
  Future<UserModel?> _loadUserData(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    String? userData = prefs.getString('user_data');
    if (userData != null) {
      try {
        Map<String, dynamic> userMap = json.decode(userData);
        if (userMap['id'] == userId) {
          return UserModel.fromMap(userMap);
        }
      } catch (e) {
        // Invalid data, clear it
        await prefs.remove('user_data');
      }
    }
    return null;
  }

  /// Clear user data from local storage
  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
  }

  /// Handle Firebase Auth errors
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak';
      case 'email-already-in-use':
        return 'An account already exists for this email';
      case 'user-not-found':
        return 'No user found for this email';
      case 'wrong-password':
        return 'Wrong password provided';
      case 'user-disabled':
        return 'This user account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support';
      case 'invalid-email':
        return 'The email address is not valid';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}