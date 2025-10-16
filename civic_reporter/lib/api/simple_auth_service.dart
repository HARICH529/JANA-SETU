import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';

class SimpleAuthService {
  final ApiService _apiService = ApiService();

  // Register with backend only
  Future<Map<String, dynamic>?> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final result = await _apiService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
      
      // Store token if registration successful
      if (result['success'] == true && result['data']?['accessToken'] != null) {
        await _apiService.setToken(result['data']['accessToken']);
        await _saveLoginState(true);
      }
      
      return result;
    } catch (e) {
      print('Backend registration error: $e');
      return null;
    }
  }

  // Login with backend only
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _apiService.login(
        email: email,
        password: password,
      );
      
      // Store token if login successful
      if (result['success'] == true && result['data']?['accessToken'] != null) {
        await _apiService.setToken(result['data']['accessToken']);
        await _saveLoginState(true);
      }
      
      return result;
    } catch (e) {
      print('Backend login error: $e');
      return null;
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      final result = await _apiService.getProfile();
      print('Profile service result: $result');
      return result;
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _apiService.logout();
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await _apiService.clearToken();
      await _saveLoginState(false);
    }
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final token = await _apiService.getToken();
    return isLoggedIn && token != null;
  }
  
  // Save login state
  Future<void> _saveLoginState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', isLoggedIn);
  }
}
