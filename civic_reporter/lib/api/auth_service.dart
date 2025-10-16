import 'package:firebase_auth/firebase_auth.dart';
import '../api/api_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _apiService = ApiService();

  // Stream for auth state changes
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // Get current user
  User? get currentUser {
    return _auth.currentUser;
  }

  // Sign in with email & password
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Register with email & password
  Future<UserCredential?> registerWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } catch (e) {
      print('Registration error: $e');
      return null;
    }
  }

  // Sign in with credential (used for phone auth)
  Future<UserCredential?> signInWithCredential(AuthCredential credential) async {
    try {
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Verify Phone Number
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _apiService.logout();
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  // Backend integration methods
  Future<Map<String, dynamic>?> registerWithBackend({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      return await _apiService.register(
        email: email,
        password: password,
        name: name,
        phone: phone,
      );
    } catch (e) {
      print('Backend registration error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> loginWithBackend({
    required String email,
    required String password,
  }) async {
    try {
      return await _apiService.login(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Backend login error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> authenticateWithFirebase({
    required String name,
    required String email,
    String? phone,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final idToken = await user.getIdToken();
        if (idToken != null) {
          return await _apiService.firebaseAuth(
            idToken: idToken,
            name: name,
            email: email,
            phone: phone,
          );
        }
      }
      return null;
    } catch (e) {
      print('Firebase backend auth error: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      return await _apiService.getProfile();
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }
}
