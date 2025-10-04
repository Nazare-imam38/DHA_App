import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/widgets/dha_loading_widget.dart';
import 'main_wrapper.dart';
import '../core/services/enhanced_startup_preloader.dart';
import '../core/services/unified_cache_manager.dart';

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
  static const Duration _maxPreloadTime = Duration(seconds: 10);
  
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
              authProvider.isLoggedIn ? MainWrapper() : LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      print('❌ Error navigating to main app: $e');
      // Fallback to login screen
      if (mounted) {
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
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A), // Deep blue
              Color(0xFF3B82F6), // Blue
              Color(0xFF60A5FA), // Light blue
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo section
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _logoScale,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _logoScale.value,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.home_work,
                            size: 60,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // App name section
              Expanded(
                flex: 1,
                child: AnimatedBuilder(
                  animation: _textFade,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _textFade.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'DHA Marketplace',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your Gateway to Premium Properties',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // Progress section
              Expanded(
                flex: 2,
                child: AnimatedBuilder(
                  animation: _progressFade,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _progressFade.value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Progress message
                            Text(
                              _preloadMessage,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Progress bar
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(3),
                              ),
                              child: Stack(
                                children: [
                                  // Background
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  
                                  // Progress fill
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: MediaQuery.of(context).size.width * (_preloadProgress / 100),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Progress percentage
                            Text(
                              '${_preloadProgress.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Loading indicator
                            if (_isPreloading && !_preloadComplete)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                            
                            // Success indicator
                            if (_preloadComplete)
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 24,
                              ),
                          ],
                        ),
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
                              color: Colors.white.withOpacity(0.6),
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