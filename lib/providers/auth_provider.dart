import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:billing_app/services/auth_service.dart';
import 'package:billing_app/models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _loadUserModel(user.uid);
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  // Load user model from Firestore
  Future<void> _loadUserModel(String uid) async {
    try {
      _userModel = await _authService.getUserData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user model: $e');
    }
  }

  // Sign in with email
  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      await _authService.signInWithEmail(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Create account
  Future<bool> createAccount(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      await _authService.createAccountWithEmail(email, password);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      await _authService.signInWithGoogle();
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
      _user = null;
      _userModel = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
    notifyListeners();
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;
    
    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
