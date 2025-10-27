import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/widgets/dha_loading_widget.dart';
import '../ui/widgets/cached_asset_image.dart';
import 'main_wrapper.dart';
import '../core/services/unified_memory_cache.dart';
import '../core/services/satellite_imagery_preloader.dart';
import '../core/services/enhanced_startup_preloader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _progressController;
  
  late Animation<double> _logoScale;
  late Animation<double> _textFade;
  late Animation<double> _progressFade;

  @override
  void initState() {
    super.initState();
    
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

    _startAnimations();
    _initializeApp();
  }

  void _startAnimations() async {
    await _logoController.forward();
    await _textController.forward();
    await _progressController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      print('🚀 Starting enhanced app initialization...');
      
      // Start satellite imagery preloading in parallel
      final satellitePreloadFuture = SatelliteImageryPreloader.startPreloading();
      
      // Start enhanced startup preloading in parallel
      final startupPreloadFuture = EnhancedStartupPreloader.startEnhancedPreloading();
      
      // Wait for animations to complete (minimum 3 seconds)
      await Future.delayed(const Duration(seconds: 3));
      
      // Wait for both preloading operations to complete
      await Future.wait([
        satellitePreloadFuture,
        startupPreloadFuture,
      ]);
      
      print('✅ All preloading operations completed');
      
      if (mounted) {
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
    } catch (e) {
      print('❌ Error during app initialization: $e');
      // Continue with navigation even if preloading fails
      if (mounted) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await authProvider.initializeAuth();
        
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A), // Dark blue at top
              Color(0xFF3B82F6), // Lighter blue at bottom
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // DHA Logo - Extra Large and Prominent
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScale.value,
                    child: Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 40,
                            offset: Offset(0, 20),
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(40),
                      child: CachedAssetImage(
                        assetPath: 'assets/images/dhalogo.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 100),

              // Enhanced Loading Indicator
              AnimatedBuilder(
                animation: _progressFade,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _progressFade,
                    child: Column(
                      children: [
                        Text(
                          'Loading plot data...',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: 250,
                          height: 6,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                width: 250 * 0.5, // 50% progress
                                height: 6,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '50%',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1.0,
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

