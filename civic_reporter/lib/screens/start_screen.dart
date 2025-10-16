import 'package:flutter/material.dart';
import '../main.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              
              // Logo Section
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/start-logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title Section
              const Text(
                'JANA SETU',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E4A6B),
                  letterSpacing: 2.0,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'CONNECTING GOVT. & CITIZENS',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7A7A7A),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              
              const Spacer(flex: 2),
              
              // Login Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3498DB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'LOGIN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8BC34A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'SIGN UP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}