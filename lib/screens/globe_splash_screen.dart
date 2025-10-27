import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/widgets/cached_asset_image.dart';
import 'main_wrapper.dart';

class GlobeSplashScreen extends StatefulWidget {
  const GlobeSplashScreen({super.key});

  @override
  State<GlobeSplashScreen> createState() => _GlobeSplashScreenState();
}

class _GlobeSplashScreenState extends State<GlobeSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  
  late Animation<double> _logoScale;
  late Animation<double> _textFade;
  late Animation<double> _progressFade;
  
  double _currentProgress = 0.0;
  String _currentMessage = 'Initializing...';
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLoadingSequence();
  }
  
  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    
    _progressFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeIn),
    );
  }
  
  void _startLoadingSequence() async {
    // Start animations
    await _logoController.forward();
    await _textController.forward();
    await _progressController.forward();
    
    // Initialize app
    await _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    try {
      // Stage 1: App Initialization (0-20%)
      _updateProgress(0.1, 'Initializing app...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Stage 2: Basic Setup (20-40%)
      _updateProgress(0.2, 'Setting up services...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Stage 3: Authentication Check (40-60%)
      _updateProgress(0.4, 'Checking authentication...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Stage 4: Final Setup (60-100%)
      _updateProgress(0.6, 'Preparing app...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      _updateProgress(0.8, 'Almost ready...');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Stage 5: Complete (100%)
      _updateProgress(1.0, 'Ready to launch!');
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Navigate to main app
      if (mounted) {
        await _navigateToMainApp();
      }
      
    } catch (e) {
      await _handleLoadingError(e);
    }
  }
  
  void _updateProgress(double progress, String message) {
    if (mounted) {
      setState(() {
        _currentProgress = progress;
        _currentMessage = message;
      });
    }
  }
  
  Future<void> _navigateToMainApp() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Initialize authentication state
    await authProvider.initializeAuth();
    
    // Navigate based on authentication status
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
            authProvider.isLoggedIn ? MainWrapper() : LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }
  
  Future<void> _handleLoadingError(dynamic error) async {
    _updateProgress(0.0, 'Error loading app...');
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      // Navigate to login screen on error
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }
  

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // DHA Logo (not rotated)
              AnimatedBuilder(
                animation: _logoScale,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScale.value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF20B2AA).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: CachedAssetImage(
                          assetPath: 'assets/images/dhalogo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFF20B2AA),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.home,
                                color: Colors.white,
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 30),
              
              // App Title
              AnimatedBuilder(
                animation: _textFade,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _textFade,
                    child: Column(
                      children: [
                        Text(
                          'DHA Marketplace',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A2E),
                            shadows: [
                              Shadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Premium Property Solutions',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF1A1A2E).withOpacity(0.7),
                            shadows: [
                              Shadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 5,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 60),
              
              // Loading Progress
              AnimatedBuilder(
                animation: _progressFade,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _progressFade,
                    child: Column(
                      children: [
                        // Progress Bar
                        Container(
                          width: 280,
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: const Color(0xFF1A1A2E).withOpacity(0.2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: _currentProgress,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFF20B2AA),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Progress Text
                        Text(
                          _currentMessage,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1A1A2E).withOpacity(0.8),
                            shadows: [
                              Shadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 5,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Percentage
                        Text(
                          '${(_currentProgress * 100).toInt()}%',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF20B2AA),
                            shadows: [
                              Shadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 5,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}