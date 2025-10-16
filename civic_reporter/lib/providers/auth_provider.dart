import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../api/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _user;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _authService.user.listen((User? user) {
      _user = user;
      if (user != null) {
        _fetchUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Try Firebase registration first
      var firebaseResult = await _authService.registerWithEmailAndPassword(email, password);
      
      // If Firebase registration fails due to existing email, try login instead
      if (firebaseResult == null) {
        firebaseResult = await _authService.signInWithEmailAndPassword(email, password);
        if (firebaseResult == null) {
          _setError('Firebase authentication failed');
          return false;
        }
      }

      // Register with backend (will handle existing users)
      final backendResult = await _authService.registerWithBackend(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      if (backendResult == null) {
        _setError('Backend registration failed');
        return false;
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      // Login with Firebase
      final firebaseResult = await _authService.signInWithEmailAndPassword(email, password);
      if (firebaseResult == null) {
        _setError('Firebase login failed');
        return false;
      }

      // Login with backend
      final backendResult = await _authService.loginWithBackend(
        email: email,
        password: password,
      );

      if (backendResult == null) {
        _setError('Backend login failed');
        return false;
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> authenticateWithFirebase({
    required String name,
    required String email,
    String? phone,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final result = await _authService.authenticateWithFirebase(
        name: name,
        email: email,
        phone: phone,
      );

      if (result == null) {
        _setError('Firebase authentication failed');
        return false;
      }

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      _userProfile = await _authService.getUserProfile();
      notifyListeners();
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _userProfile = null;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _setError(null);
  }
}
