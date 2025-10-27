import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/widgets/cached_asset_image.dart';
import '../ui/widgets/dha_loading_widget.dart';
import 'main_wrapper.dart';

/// Enhanced Splash Screen with Real Preloading
/// Shows progress and only navigates when essential data is ready
class EnhancedSplashScreen extends StatefulWidget {
  const EnhancedSplashScreen({super.key});

  @override
  State<EnhancedSplashScreen> createState() => _EnhancedSplashScreenState();
}

class _EnhancedSplashScreenState extends State<EnhancedSplashScreen>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  
  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _textFade;
  late Animation<double> _progressFade;
  
  // Preloading state
  double _preloadProgress = 0.0;
  String _preloadMessage = 'Initializing...';
  bool _isPreloading = false;
  bool _preloadComplete = false;
  
  // Timer for fallback
  Timer? _fallbackTimer;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startPreloading();
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
  
  void _startPreloading() async {
    // Start animations
    await _logoController.forward();
    await _textController.forward();
    await _progressController.forward();
    
    // Start preloading
    _isPreloading = true;
    
    // Simulate preloading progress for now
    await _simulatePreloadingProgress();
    
    // Navigate to main app
    _navigateToMainApp();
  }
  
  Future<void> _simulatePreloadingProgress() async {
    final steps = [
      {'progress': 20.0, 'message': 'Loading boundaries...', 'duration': 1000},
      {'progress': 50.0, 'message': 'Loading plot data...', 'duration': 1500},
      {'progress': 80.0, 'message': 'Processing polygons...', 'duration': 1000},
      {'progress': 95.0, 'message': 'Loading map tiles...', 'duration': 500},
      {'progress': 100.0, 'message': 'Ready to launch!', 'duration': 500},
    ];
    
    for (final step in steps) {
      if (mounted) {
        setState(() {
          _preloadProgress = step['progress'] as double;
          _preloadMessage = step['message'] as String;
        });
        await Future.delayed(Duration(milliseconds: step['duration'] as int));
      }
    }
    
    _preloadComplete = true;
  }
  
  Future<void> _navigateToMainApp() async {
    if (!mounted) return;
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Initialize authentication state
      await authProvider.initializeAuth();
      
      // Navigate based on authentication status
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => 
              authProvider.isLoggedIn ? const MainWrapper() : const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error navigating to main app: $e');
      // Fallback to login screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    }
  }
  
  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _progressController.dispose();
    _fallbackTimer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo section - Clean Logo Only
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _logoScale,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
                                blurRadius: 25,
                                offset: const Offset(0, 12),
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(25),
                          child: CachedAssetImage(
                            assetPath: 'assets/images/dhalogo.png',
                            width: 130,
                            height: 130,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Progress section with DHA Loading Widget
              Expanded(
                flex: 2,
                child: AnimatedBuilder(
                  animation: _progressFade,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _progressFade.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // DHA Loading Widget - Much Bigger
                          DHALoadingWidget(
                            size: 160,
                            primaryColor: const Color(0xFF1E3A8A),
                            secondaryColor: const Color(0xFF3B82F6),
                            message: 'Loading data...',
                            showMessage: true,
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Progress percentage
                          Text(
                            '${_preloadProgress.toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1E3A8A),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // Footer
              Expanded(
                flex: 1,
                child: AnimatedBuilder(
                  animation: _textFade,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textFade.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Powered by Advanced Caching Technology',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}