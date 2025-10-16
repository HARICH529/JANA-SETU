import 'package:flutter/material.dart';
import '../main.dart';
import '../utils/app_settings.dart' as AppUtils;
import 'start_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
    
    // Check login status and navigate
    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        bool isLoggedIn = await AppUtils.AppSettings.checkLoginStatus();
        
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
              isLoggedIn ? const HomeScreen() : const StartScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
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
                  
                  const SizedBox(height: 24),
                  
                  // App Name
                  const Text(
                    'JANA SETU',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E4A6B),
                      letterSpacing: 2.0,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    'CONNECTING GOVT. & CITIZENS',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF7A7A7A),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Loading Spinner
                  const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF9E9E9E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}