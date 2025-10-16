import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:async';
import 'screens.dart';
import 'providers/simple_auth_provider.dart';
import 'providers/report_provider.dart';
import 'providers/notification_provider.dart';
import 'models/notification_model.dart';
import 'screens/create_report_screen.dart';
import 'screens/my_reports_screen.dart';
import 'screens/nearby_reports_screen.dart';
import 'screens/leaderboard/leaderboard_screen.dart';
import 'screens/start_screen.dart';
import 'screens/loading_screen.dart';
import 'utils/app_settings.dart' as AppUtils;
import 'api/api_service.dart';
import 'services/socket_service.dart';

class CustomLogo extends StatelessWidget {
  final double size;
  const CustomLogo({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        'assets/start-logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}

class LogoWithName extends StatelessWidget {
  final double logoSize;
  final double fontSize;
  const LogoWithName({super.key, this.logoSize = 40, this.fontSize = 24});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomLogo(size: logoSize),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'JANA SETU',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E4A6B),
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'Citizen Reporter',
              style: TextStyle(
                fontSize: fontSize * 0.5,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SimpleAuthProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppUtils.AppSettings.darkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          title: 'JANA SETU',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E4A6B)),
            useMaterial3: true,
            primaryColor: const Color(0xFF2E4A6B),
            scaffoldBackgroundColor: Colors.white,
            cardColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF2E4A6B),
              foregroundColor: Colors.white,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                foregroundColor: Colors.white,
                elevation: 0,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            cardTheme: CardThemeData(
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
            primaryColor: Colors.blue,
            scaffoldBackgroundColor: Colors.grey[900],
            cardColor: Colors.grey[850],
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[900],
              foregroundColor: Colors.white,
              elevation: 0,
              systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const LoadingScreen(),
        );
      },
    );
  }
}

// Global list to store issues with sample data
List<Issue> reportedIssues = [
  Issue(
    id: '1',
    title: 'Broken Street Light',
    description: 'Street light has been flickering for weeks and now completely dark',
    imagePath: '/sample/streetlight.jpg',
    reportedAt: DateTime.now().subtract(const Duration(days: 3)),
    status: 'Pending',
    location: 'Lat: 28.6139, Lng: 77.2090',
    latitude: 28.6139,
    longitude: 77.2090,
    upvotes: 12,
    upvotedBy: ['user1', 'user2', 'user3', 'user4', 'user5', 'user6', 'user7', 'user8', 'user9', 'user10', 'user11', 'user12'],
    reportedBy: 'user123',
  ),
  Issue(
    id: '2',
    title: 'Pothole on Main Road',
    description: 'Large pothole causing traffic issues and vehicle damage',
    imagePath: '/sample/pothole.jpg',
    reportedAt: DateTime.now().subtract(const Duration(days: 1)),
    status: 'In Progress',
    location: 'Lat: 28.6129, Lng: 77.2095',
    latitude: 28.6129,
    longitude: 77.2095,
    upvotes: 8,
    upvotedBy: ['user1', 'user3', 'user5', 'user7', 'user9', 'user11', 'user13', 'user15'],
    voiceNote: 'voice_note_sample.m4a',
    reportedBy: 'user456',
  ),
  Issue(
    id: '3',
    title: 'Garbage Overflow',
    description: 'Dustbin overflowing for days, creating hygiene issues',
    imagePath: '/sample/garbage.jpg',
    reportedAt: DateTime.now().subtract(const Duration(hours: 12)),
    status: 'Pending',
    location: 'Lat: 28.6149, Lng: 77.2085',
    latitude: 28.6149,
    longitude: 77.2085,
    upvotes: 5,
    upvotedBy: ['user2', 'user4', 'user6', 'user8', 'user10'],
    reportedBy: 'user789',
  ),
  Issue(
    id: '4',
    title: 'Water Leakage',
    description: 'Continuous water leakage from municipal pipe',
    imagePath: '/sample/water.jpg',
    reportedAt: DateTime.now().subtract(const Duration(days: 5)),
    status: 'Fixed',
    location: 'Lat: 28.6119, Lng: 77.2100',
    latitude: 28.6119,
    longitude: 77.2100,
    upvotes: 3,
    upvotedBy: ['user1', 'user5', 'user9'],
    reportedBy: 'user123',
  ),
  Issue(
    id: '5',
    title: 'Broken Footpath',
    description: 'Footpath tiles are broken making it difficult to walk',
    imagePath: '/sample/footpath.jpg',
    reportedAt: DateTime.now().subtract(const Duration(hours: 6)),
    status: 'Pending',
    location: 'Lat: 28.6159, Lng: 77.2080',
    latitude: 28.6159,
    longitude: 77.2080,
    upvotes: 2,
    upvotedBy: ['user3', 'user7'],
    voiceNote: 'voice_note_footpath.m4a',
    reportedBy: 'user123',
  ),
  Issue(
    id: '6',
    title: 'Traffic Signal Not Working',
    description: 'Main intersection traffic light has been red for hours',
    imagePath: '/sample/traffic.jpg',
    reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
    status: 'Pending',
    location: 'Lat: 28.6169, Lng: 77.2075',
    latitude: 28.6169,
    longitude: 77.2075,
    upvotes: 15,
    upvotedBy: ['user1', 'user2', 'user3', 'user4', 'user5', 'user6', 'user7', 'user8', 'user9', 'user10', 'user11', 'user12', 'user13', 'user14', 'user15'],
    reportedBy: 'user456',
  ),
  Issue(
    id: '7',
    title: 'Stray Dogs Issue',
    description: 'Pack of stray dogs causing safety concerns for children',
    imagePath: '/sample/dogs.jpg',
    reportedAt: DateTime.now().subtract(const Duration(days: 2)),
    status: 'In Progress',
    location: 'Lat: 28.6109, Lng: 77.2105',
    latitude: 28.6109,
    longitude: 77.2105,
    upvotes: 7,
    upvotedBy: ['user2', 'user4', 'user6', 'user8', 'user10', 'user12', 'user14'],
    voiceNote: 'voice_note_dogs.m4a',
    reportedBy: 'user789',
  ),
];



class Issue {
  final String id;
  final String title;
  final String description;
  final String imagePath;
  final DateTime reportedAt;
  String status;
  final String location;
  final double? latitude;
  final double? longitude;
  final String? voiceNote;
  final String reportedBy;
  int upvotes;
  final List<String> upvotedBy;

  Issue({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.reportedAt,
    this.status = 'Pending',
    this.location = 'Location not available',
    this.latitude,
    this.longitude,
    this.voiceNote,
    required this.reportedBy,
    this.upvotes = 0,
    List<String>? upvotedBy,
  }) : upvotedBy = upvotedBy ?? [];

  void addUpvote(String userId) {
    if (!upvotedBy.contains(userId)) {
      upvotes++;
      upvotedBy.add(userId);
    }
  }

  void removeUpvote(String userId) {
    if (upvotedBy.contains(userId)) {
      upvotes--;
      upvotedBy.remove(userId);
    }
  }

  bool hasUpvoted(String userId) {
    return upvotedBy.contains(userId);
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));

    _animationController.forward();
    
    // Check if user is already logged in
    Future.delayed(const Duration(seconds: 4), () async {
      if (mounted) {
        // Check for saved login credentials
        bool isLoggedIn = await AppUtils.AppSettings.checkLoginStatus();
        
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
              isLoggedIn ? const HomeScreen() : const LoginScreen(),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E4A6B),
              Color(0xFF7CB342),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const LogoWithName(logoSize: 100, fontSize: 36),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Empowering Citizens',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Building Better Communities Together',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),
              
              // Logo and Title Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const LogoWithName(logoSize: 60, fontSize: 28),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome Back!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue reporting civic issues',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Login Form Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email/Phone Field
                    const Text(
                      'Email/Phone Number',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Enter email or phone number',
                        prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Password Field
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3498DB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Register Link
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpScreen()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                  color: const Color(0xFF3498DB),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Debug Test Button
                    Center(
                      child: TextButton(
                        onPressed: () {
                          _emailController.text = 'mobiletest@example.com';
                          _passwordController.text = 'mobile123';
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Test credentials filled! Tap Sign In to test.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        child: const Text(
                          'Use Test Credentials',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Footer
              Text(
                'By signing in, you agree to our Terms of Service\nand Privacy Policy',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final authProvider = Provider.of<SimpleAuthProvider>(context, listen: false);
    final success = await authProvider.login(
      email: _emailController.text,
      password: _passwordController.text,
    );
    
    setState(() => _isLoading = false);

    if (success) {
      await AppUtils.AppSettings.setLoggedIn(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Welcome to JANA SETU! 🎉'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Login failed'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.05),
              
              // Logo and Title Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const LogoWithName(logoSize: 50, fontSize: 24),
                    const SizedBox(height: 16),
                    Text(
                      'Join JANA SETU',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your account to start reporting civic issues',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Sign Up Form Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name Field
                    const Text(
                      'Full Name',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your full name',
                        prefixIcon: Icon(Icons.person_outline, color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Mobile Number Field
                    const Text(
                      'Mobile Number',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: 'Enter your mobile number',
                        prefixIcon: Icon(Icons.phone_outlined, color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Email Field
                    const Text(
                      'Email Address',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Password Field
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Create a password',
                        prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.green, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8BC34A),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Login Link
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                            children: [
                              TextSpan(
                                text: 'Sign In',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Footer
              Text(
                'By creating an account, you agree to our\nTerms of Service and Privacy Policy',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _signUp() async {
    if (_nameController.text.isEmpty || 
        _mobileController.text.isEmpty || 
        _emailController.text.isEmpty || 
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final authProvider = Provider.of<SimpleAuthProvider>(context, listen: false);
    final success = await authProvider.register(
      email: _emailController.text,
      password: _passwordController.text,
      name: _nameController.text,
      phone: _mobileController.text,
    );
    
    setState(() => _isLoading = false);

    if (success) {
      AppUtils.AppSettings.userName = _nameController.text;
      AppUtils.AppSettings.userEmail = _emailController.text;
      await AppUtils.AppSettings.setLoggedIn(true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created successfully! Welcome to JANA SETU! 🎉'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.error ?? 'Registration failed'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}



class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<SimpleAuthProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      notificationProvider.fetchNotifications(authProvider);
    });
  }

  Future<bool> _showExitDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('NO', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('YES', style: TextStyle(color: Color(0xFF2E4A6B))),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _showExitDialog(context),
      child: Scaffold(
      appBar: _currentIndex == 2 ? null : AppBar(
        title: _currentIndex == 0 
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const CustomLogo(size: 28),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'JANA SETU',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(1, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Citizen Reporter',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ],
            )
          : Text(_getTitle()),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E4A6B), Color(0xFF1E3A5F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                      );
                    },
                  ),
                  if (notificationProvider.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${notificationProvider.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final authProvider = Provider.of<SimpleAuthProvider>(context, listen: false);
              final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
              await authProvider.signOut();
              notificationProvider.clearNotifications();
              await AppUtils.AppSettings.setLoggedIn(false);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF2E4A6B),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.leaderboard), label: 'Leaderboard'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('🔥 Main.dart FAB pressed - navigating to NearbyReportsScreen');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NearbyReportsScreen()),
          );
        },
        backgroundColor: const Color(0xFF7CB342),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0: 
        final reportProvider = Provider.of<ReportProvider>(context, listen: false);
        return 'Dashboard (${reportProvider.reports.length} Issues)';
      case 1: return 'Leaderboard';
      case 2: return 'Profile';
      default: return 'JANA SETU';
    }
  }

  Widget _getBody() {
    switch (_currentIndex) {
      case 0: return const DashboardTab();
      case 1: return const LeaderboardScreen();
      case 2: return const ProfileTab();
      default: return const Center(child: Text('Unknown screen'));
    }
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<SimpleAuthProvider>(context, listen: false);
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      notificationProvider.fetchNotifications(authProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return TextButton(
                onPressed: notificationProvider.notifications.isEmpty 
                  ? null 
                  : () => notificationProvider.markAllAsRead(),
                child: const Text('Mark All Read', style: TextStyle(color: Colors.white)),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (notificationProvider.notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No New Notifications', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Submit reports to get status updates', style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: notificationProvider.notifications.length,
            itemBuilder: (context, index) {
              final notification = notificationProvider.notifications[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: notification.isRead ? Colors.grey : Colors.blue,
                    child: Icon(
                      notification.type == 'status_update' ? Icons.update : Icons.thumb_up,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.message),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(notification.timestamp),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  onTap: () {
                    notificationProvider.markAsRead(notification.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inSeconds > 30) {
      return '${difference.inSeconds} second${difference.inSeconds > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> with WidgetsBindingObserver {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
      _startPeriodicRefresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh data when app comes back to foreground
      _refreshData();
    }
  }

  void _refreshData() {
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    final authProvider = Provider.of<SimpleAuthProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    
    reportProvider.fetchAllReports().then((_) {
      reportProvider.fetchUserReports().then((_) {
        notificationProvider.refreshNotifications(authProvider);
      });
    });
  }

  void _startPeriodicRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _refreshData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportProvider>(
      builder: (context, reportProvider, child) {
        if (reportProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (reportProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 80, color: Colors.red),
                SizedBox(height: 20),
                Text('Error: ${reportProvider.error}'),
                ElevatedButton(
                  onPressed: () => reportProvider.fetchAllReports(),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        final reports = reportProvider.reports;
        
        if (reports.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.dashboard, size: 80, color: Colors.blue),
            SizedBox(height: 20),
            Text('No Issues Reported Yet', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Tap the + button to report your first issue', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Stats Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.withOpacity(0.08), Colors.green.withOpacity(0.08)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.blue.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Total Issues', reports.length.toString(), Colors.blue, Icons.report, 'all')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('Pending', reports.where((r) => r.status.toLowerCase() == 'submitted' || r.status.toLowerCase() == 'pending').length.toString(), Colors.orange, Icons.pending, 'pending')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildStatCard('In Progress', reports.where((r) => r.status.toLowerCase() == 'acknowledged' || r.status.toLowerCase() == 'in_progress').length.toString(), Colors.blue, Icons.construction, 'in_progress')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('Resolved', reports.where((r) => r.status.toLowerCase() == 'resolved').length.toString(), Colors.green, Icons.check_circle, 'resolved')),
                  ],
                ),
              ],
            ),
          ),
          
          // Recent Issues Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Issues',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MyReportsScreen()),
                        );
                      },
                      child: const Text('My Reports'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final sortedReports = List.from(reports)
                      ..sort((a, b) => b.upvotes.compareTo(a.upvotes));
                    final report = sortedReports[index];
                    final authProvider = Provider.of<SimpleAuthProvider>(context, listen: false);
                    return GestureDetector(
                      onTap: () => _viewReportDetails(report),
                      child: Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: _getIssueColor(report.title),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Icon(
                                    _getIssueIcon(report.title),
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        report.title.replaceAll('"', ''),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(report.status),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          report.status.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () => _toggleUpvote(report),
                                      child: Consumer<SimpleAuthProvider>(
                                        builder: (context, auth, child) {
                                          final userId = auth.userProfile?['_id']?.toString() ?? '';
                                          final hasUpvoted = report.upvotedBy.contains(userId);
                                          
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: hasUpvoted 
                                                ? Colors.blue.withOpacity(0.2)
                                                : Colors.grey[200],
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: hasUpvoted 
                                                  ? Colors.blue
                                                  : Colors.grey,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  '↑',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: hasUpvoted 
                                                      ? Colors.blue
                                                      : Colors.grey[600],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${report.upvotes}',
                                                  style: TextStyle(
                                                    color: hasUpvoted 
                                                      ? Colors.blue
                                                      : Colors.grey[600],
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getSeverityColor(report.upvotes),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _getSeverityText(report.upvotes),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  void _toggleUpvote(report) async {
    final authProvider = Provider.of<SimpleAuthProvider>(context, listen: false);
    final apiService = ApiService();
    final token = await apiService.getToken();
    
    if (token == null || !authProvider.isAuthenticated) {
      _showLoginRequired();
      return;
    }
    
    final userId = authProvider.userProfile?['_id']?.toString() ?? '';
    final hasUpvoted = report.upvotedBy.contains(userId);
    
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    
    // Show immediate feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(hasUpvoted ? 'Removing upvote...' : 'Adding upvote...'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.blue,
      ),
    );
    
    try {
      final success = await reportProvider.upvoteReport(report.id);
      
      if (success) {
        // Refresh notifications after successful upvote
        notificationProvider.refreshNotifications(authProvider);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hasUpvoted ? 'Upvote removed!' : 'Report upvoted!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        final errorMessage = reportProvider.error ?? "Failed to update upvote";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  
  void _viewReportDetails(report) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ReportDetailScreen(report: report),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _showLoginRequired() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('You need to be logged in to upvote reports.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon, String filterType) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'submitted':
        return Colors.orange;
      case 'in_progress':
      case 'acknowledged':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getSeverityColor(int upvotes) {
    if (upvotes >= 10) return Colors.red[700]!;
    if (upvotes >= 5) return Colors.orange[700]!;
    if (upvotes >= 2) return Colors.yellow[700]!;
    return Colors.grey[600]!;
  }

  String _getSeverityText(int upvotes) {
    if (upvotes >= 10) return 'CRITICAL';
    if (upvotes >= 5) return 'HIGH';
    if (upvotes >= 2) return 'MEDIUM';
    return 'LOW';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getIssueColor(String title) {
    if (title.toLowerCase().contains('light')) return Colors.yellow[700]!;
    if (title.toLowerCase().contains('pothole') || title.toLowerCase().contains('road')) return Colors.brown;
    if (title.toLowerCase().contains('garbage') || title.toLowerCase().contains('waste')) return Colors.green;
    if (title.toLowerCase().contains('water') || title.toLowerCase().contains('leak')) return Colors.blue;
    if (title.toLowerCase().contains('footpath') || title.toLowerCase().contains('path')) return Colors.grey[700]!;
    if (title.toLowerCase().contains('traffic')) return Colors.red[700]!;
    if (title.toLowerCase().contains('dog')) return Colors.purple[700]!;
    return Colors.red[700]!;
  }

  IconData _getIssueIcon(String title) {
    if (title.toLowerCase().contains('light')) return Icons.lightbulb;
    if (title.toLowerCase().contains('pothole') || title.toLowerCase().contains('road')) return Icons.warning;
    if (title.toLowerCase().contains('garbage') || title.toLowerCase().contains('waste')) return Icons.delete;
    if (title.toLowerCase().contains('water') || title.toLowerCase().contains('leak')) return Icons.water_drop;
    if (title.toLowerCase().contains('footpath') || title.toLowerCase().contains('path')) return Icons.directions_walk;
    if (title.toLowerCase().contains('traffic')) return Icons.traffic;
    if (title.toLowerCase().contains('dog')) return Icons.pets;
    return Icons.report_problem;
  }
}

class FilteredIssuesScreen extends StatelessWidget {
  final String filterType;
  final String title;
  
  const FilteredIssuesScreen({super.key, required this.filterType, required this.title});

  @override
  Widget build(BuildContext context) {
    List<Issue> filteredIssues;
    
    if (filterType == 'all') {
      filteredIssues = reportedIssues;
    } else {
      filteredIssues = reportedIssues.where((issue) => issue.status == filterType).toList();
    }
    
    filteredIssues.sort((a, b) => b.upvotes.compareTo(a.upvotes));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('$title (${filteredIssues.length})'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: filteredIssues.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 80, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('No Issues Found', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredIssues.length,
              itemBuilder: (context, index) {
                final issue = filteredIssues[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IssueDetailScreen(issue: issue),
                      ),
                    );
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _getIssueColor(issue.title),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Icon(
                              _getIssueIcon(issue.title),
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  issue.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${issue.upvotes} upvotes • ${_getSeverityText(issue.upvotes)}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(issue.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              issue.status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'In Progress': return Colors.blue;
      case 'Fixed': return Colors.purple;
      case 'Resolved': return Colors.green;
      default: return Colors.grey;
    }
  }
  
  String _getSeverityText(int upvotes) {
    if (upvotes >= 10) return 'CRITICAL';
    if (upvotes >= 5) return 'HIGH';
    if (upvotes >= 2) return 'MEDIUM';
    return 'LOW';
  }
  
  Color _getIssueColor(String title) {
    if (title.toLowerCase().contains('light')) return Colors.yellow[700]!;
    if (title.toLowerCase().contains('pothole')) return Colors.brown;
    if (title.toLowerCase().contains('garbage')) return Colors.green;
    if (title.toLowerCase().contains('water')) return Colors.blue;
    if (title.toLowerCase().contains('traffic')) return Colors.red[700]!;
    return Colors.red[700]!;
  }
  
  IconData _getIssueIcon(String title) {
    if (title.toLowerCase().contains('light')) return Icons.lightbulb;
    if (title.toLowerCase().contains('pothole')) return Icons.warning;
    if (title.toLowerCase().contains('garbage')) return Icons.delete;
    if (title.toLowerCase().contains('water')) return Icons.water_drop;
    if (title.toLowerCase().contains('traffic')) return Icons.traffic;
    return Icons.report_problem;
  }
}

class ReportDetailScreen extends StatefulWidget {
  final dynamic report;
  
  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  bool _isUpdating = false;
  late String _currentStatus;
  final SocketService _socketService = SocketService();

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.report.status;
    _setupSocketConnection();
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }

  void _setupSocketConnection() {
    _socketService.connect();
    _socketService.joinReport(widget.report.id);
    
    _socketService.onStatusUpdate = (reportId, status) {
      if (reportId == widget.report.id && mounted) {
        setState(() {
          _currentStatus = status.toLowerCase();
          widget.report.status = status.toLowerCase();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report status updated to: ${status.toUpperCase()}'),
            backgroundColor: _getStatusColor(status.toLowerCase()),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    };
  }

  Future<void> _markAsResolved() async {
    setState(() => _isUpdating = true);
    
    try {
      final reportProvider = Provider.of<ReportProvider>(context, listen: false);
      final success = await reportProvider.updateReportStatus(widget.report.id);
      
      if (success) {
        setState(() {
          _currentStatus = 'resolved';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report marked as resolved!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(reportProvider.error ?? 'Failed to update report status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Report Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Icon(
                          _getIssueIcon(widget.report.title),
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.report.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${widget.report.upvotes} upvotes • ${_getSeverityText(widget.report.upvotes)}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(_currentStatus).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      _currentStatus.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.description, color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Description',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.report.description,
                            style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Location Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Location',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.report.address,
                            style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lat: ${widget.report.latitude.toStringAsFixed(6)}, Lng: ${widget.report.longitude.toStringAsFixed(6)}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Status Tracking Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.track_changes, color: Colors.blue, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Status Tracking',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildStatusTracker(),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Details Card
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'Report Details',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildDetailRow('Category', widget.report.category),
                          _buildDetailRow('Reported By', widget.report.userName),
                          _buildDetailRow('Date Reported', _formatDate(widget.report.createdAt)),
                          _buildDetailRow('Report ID', widget.report.id),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Image Card (if available)
                  if (widget.report.imageUrl != null)
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.image, color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  'Photo Evidence',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.report.imageUrl!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                  
                  // Mark as Resolved Button
                  Consumer<SimpleAuthProvider>(
                    builder: (context, authProvider, child) {
                      final userId = authProvider.userProfile?['_id']?.toString() ?? '';
                      final isUserReport = widget.report.userId == userId;
                      final canResolve = isUserReport && 
                          (_currentStatus.toLowerCase() == 'acknowledged' || 
                           _currentStatus.toLowerCase() == 'in_progress');
                      final isResolved = _currentStatus.toLowerCase() == 'resolved';
                      
                      if (!isUserReport) return const SizedBox.shrink();
                      
                      return SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isResolved ? null : (canResolve && !_isUpdating ? _markAsResolved : null),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isResolved 
                                ? Colors.green 
                                : (canResolve ? Colors.green : Colors.grey),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isUpdating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isResolved ? Icons.check_circle : Icons.check,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isResolved 
                                          ? 'Resolved' 
                                          : (canResolve ? 'Mark as Resolved' : 'Waiting for Acknowledgment'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'submitted':
        return Colors.orange;
      case 'in_progress':
      case 'acknowledged':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
  
  String _getSeverityText(int upvotes) {
    if (upvotes >= 10) return 'CRITICAL';
    if (upvotes >= 5) return 'HIGH';
    if (upvotes >= 2) return 'MEDIUM';
    return 'LOW';
  }
  
  Widget _buildStatusTracker() {
    final statuses = [
      {'name': 'Submitted', 'icon': Icons.send, 'key': 'submitted'},
      {'name': 'Acknowledged', 'icon': Icons.visibility, 'key': 'acknowledged'},
      {'name': 'Resolved', 'icon': Icons.check_circle, 'key': 'resolved'},
    ];
    
    final currentStatusIndex = _getCurrentStatusIndex(_currentStatus);
    
    return Column(
      children: [
        Row(
          children: statuses.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final isCompleted = index <= currentStatusIndex;
            final isCurrent = index == currentStatusIndex;
            
            return Expanded(
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.orange : Colors.grey[300],
                      shape: BoxShape.circle,
                      border: isCurrent ? Border.all(color: Colors.orange, width: 3) : null,
                    ),
                    child: Icon(
                      status['icon'] as IconData,
                      color: isCompleted ? Colors.white : Colors.grey[600],
                      size: 20,
                    ),
                  ),
                  if (index < statuses.length - 1)
                    Expanded(
                      child: Container(
                        height: 3,
                        color: isCompleted ? Colors.orange : Colors.grey[300],
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: statuses.asMap().entries.map((entry) {
            final index = entry.key;
            final status = entry.value;
            final isCompleted = index <= currentStatusIndex;
            
            return Expanded(
              child: Text(
                status['name'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                  color: isCompleted ? Colors.orange : Colors.grey[600],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _getStatusMessage(_currentStatus),
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  int _getCurrentStatusIndex(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
      case 'pending':
        return 0;
      case 'acknowledged':
      case 'in_progress':
        return 1;
      case 'resolved':
        return 2;
      default:
        return 0;
    }
  }
  
  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
      case 'pending':
        return 'Your report has been submitted and is waiting for review by authorities.';
      case 'acknowledged':
      case 'in_progress':
        return 'Your report has been acknowledged and is being worked on by the relevant department.';
      case 'resolved':
        return 'Great news! Your report has been resolved. Thank you for helping improve your community.';
      default:
        return 'Report status is being updated...';
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  IconData _getIssueIcon(String title) {
    if (title.toLowerCase().contains('light')) return Icons.lightbulb;
    if (title.toLowerCase().contains('pothole') || title.toLowerCase().contains('road')) return Icons.warning;
    if (title.toLowerCase().contains('garbage') || title.toLowerCase().contains('waste')) return Icons.delete;
    if (title.toLowerCase().contains('water') || title.toLowerCase().contains('leak')) return Icons.water_drop;
    if (title.toLowerCase().contains('footpath') || title.toLowerCase().contains('path')) return Icons.directions_walk;
    if (title.toLowerCase().contains('traffic')) return Icons.traffic;
    if (title.toLowerCase().contains('dog')) return Icons.pets;
    return Icons.report_problem;
  }
}

class IssueDetailScreen extends StatefulWidget {
  final Issue issue;
  
  const IssueDetailScreen({super.key, required this.issue});

  @override
  State<IssueDetailScreen> createState() => _IssueDetailScreenState();
}

class _IssueDetailScreenState extends State<IssueDetailScreen> {
  final String _currentUserId = 'user123';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.withOpacity(0.1), Colors.green.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getIssueColor(widget.issue.title),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      _getIssueIcon(widget.issue.title),
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.issue.title,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('${widget.issue.upvotes} upvotes • ${_getSeverityText(widget.issue.upvotes)}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Status Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildStatusTimeline(),
            const SizedBox(height: 20),
            if (widget.issue.status == 'Fixed' && widget.issue.reportedBy == _currentUserId)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton(
                  onPressed: _acknowledgeResolution,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Mark as Resolved', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.issue.description, style: TextStyle(fontSize: 16, color: Colors.grey[700])),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(child: Text(widget.issue.location)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _acknowledgeResolution() {
    setState(() {
      widget.issue.status = 'Resolved';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for confirming the resolution!'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  Widget _buildStatusTimeline() {
    final statuses = ['Reported', 'Under Review', 'In Progress', 'Fixed', 'Resolved'];
    final currentIndex = _getCurrentStatusIndex(widget.issue.status);
    
    return Column(
      children: statuses.asMap().entries.map((entry) {
        final index = entry.key;
        final status = entry.value;
        final isCompleted = index <= currentIndex;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCompleted ? Colors.green : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
              ),
              const SizedBox(width: 12),
              Text(status, style: TextStyle(color: isCompleted ? Colors.green : Colors.grey[600])),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  int _getCurrentStatusIndex(String status) {
    switch (status) {
      case 'Pending': return 1;
      case 'In Progress': return 2;
      case 'Fixed': return 3;
      case 'Resolved': return 4;
      default: return 0;
    }
  }
  
  String _getSeverityText(int upvotes) {
    if (upvotes >= 10) return 'CRITICAL';
    if (upvotes >= 5) return 'HIGH';
    if (upvotes >= 2) return 'MEDIUM';
    return 'LOW';
  }
  
  Color _getIssueColor(String title) {
    if (title.toLowerCase().contains('light')) return Colors.yellow[700]!;
    if (title.toLowerCase().contains('pothole')) return Colors.brown;
    if (title.toLowerCase().contains('garbage')) return Colors.green;
    if (title.toLowerCase().contains('water')) return Colors.blue;
    if (title.toLowerCase().contains('traffic')) return Colors.red[700]!;
    return Colors.red[700]!;
  }
  
  IconData _getIssueIcon(String title) {
    if (title.toLowerCase().contains('light')) return Icons.lightbulb;
    if (title.toLowerCase().contains('pothole')) return Icons.warning;
    if (title.toLowerCase().contains('garbage')) return Icons.delete;
    if (title.toLowerCase().contains('water')) return Icons.water_drop;
    if (title.toLowerCase().contains('traffic')) return Icons.traffic;
    return Icons.report_problem;
  }
}
