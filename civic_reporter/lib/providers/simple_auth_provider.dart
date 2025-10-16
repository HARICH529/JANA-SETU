import 'package:flutter/foundation.dart';
import '../api/simple_auth_service.dart';

class SimpleAuthProvider with ChangeNotifier {
  final SimpleAuthService _authService = SimpleAuthService();
  
  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  
  SimpleAuthProvider() {
    _checkLoginState();
  }
  
  Future<void> _checkLoginState() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      _isAuthenticated = true;
      // Try to get user profile
      final profile = await _authService.getUserProfile();
      if (profile != null) {
        _userProfile = profile;
      }
      notifyListeners();
    }
  }

  Future<void> refreshUserProfile() async {
    try {
      _setLoading(true);
      _setError(null);
      print('Refreshing user profile...');
      final profile = await _authService.getUserProfile();
      print('Profile received: $profile');
      if (profile != null) {
        _userProfile = profile;
        print('Profile updated in provider: $_userProfile');
      } else {
        print('Profile is null');
        _setError('Failed to fetch profile');
      }
      notifyListeners();
    } catch (e) {
      print('Profile refresh error: $e');
      _setError('Failed to refresh profile: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Map<String, dynamic>? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

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

      final result = await _authService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );

      if (result != null && result['success'] == true) {
        _isAuthenticated = true;
        _userProfile = result['data']['user'];
        notifyListeners();
        return true;
      } else {
        _setError('Registration failed');
        return false;
      }
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

      final result = await _authService.login(
        email: email,
        password: password,
      );

      if (result != null && result['success'] == true) {
        _isAuthenticated = true;
        _userProfile = result['data']['user'];
        notifyListeners();
        return true;
      } else {
        _setError('Login failed');
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _isAuthenticated = false;
      _userProfile = null;
      notifyListeners();
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
