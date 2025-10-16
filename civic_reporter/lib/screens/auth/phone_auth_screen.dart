import 'package:jana_setu/api/auth_service.dart';
import 'package:jana_setu/api/database_service.dart';
import 'package:jana_setu/screens/auth/complete_profile_screen.dart';
import 'package:jana_setu/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  String? _verificationId;
  bool _otpSent = false;
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final authService = context.read<AuthService>();

    setState(() {
      _loading = true;
      _error = '';
    });

    // Make sure to include the country code, e.g., +91 for India
    String phoneNumber = _phoneController.text.trim();
    if (!phoneNumber.startsWith('+')) {
      // A simple check, you might want a more robust validation
      setState(() {
        _error = 'Please include the country code (e.g., +91)';
        _loading = false;
      });
      return;
    }

    await authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval or instant verification
        await _signIn(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _error = e.message ?? 'Verification failed';
          _loading = false;
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _otpSent = true;
          _loading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  Future<void> _verifyOtp() async {
    if (_verificationId == null) return;

    setState(() => _loading = true);

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: _otpController.text.trim(),
    );

    await _signIn(credential);
  }

  Future<void> _signIn(PhoneAuthCredential credential) async {
    try {
      final authService = context.read<AuthService>();
      final userCredential = await authService.signInWithCredential(credential);
      final user = userCredential?.user;

      if (user != null) {
        // Check if user is new
        final userDoc = await DatabaseService(uid: user.uid).userDocument.get();
        if (!userDoc.exists) {
          // New user, navigate to complete profile screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => CompleteProfileScreen(user: user)),
            (route) => false,
          );
        } else {
          // Existing user, navigate to home
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? 'Failed to sign in';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Sign-In')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!_otpSent)
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number (e.g., +919876543210)'),
                keyboardType: TextInputType.phone,
              )
            else
              TextFormField(
                controller: _otpController,
                decoration: const InputDecoration(labelText: 'OTP'),
                keyboardType: TextInputType.number,
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loading ? null : (_otpSent ? _verifyOtp : _sendOtp),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(_otpSent ? 'Verify OTP' : 'Send OTP'),
            ),
            const SizedBox(height: 12),
            if (_error.isNotEmpty)
              Text(_error, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
