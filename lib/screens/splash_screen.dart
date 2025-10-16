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
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScale.value,
                    child: CachedAssetImage(
                      assetPath: 'assets/images/logo.png',
                      width: 160,
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                  );
              },
            ),

            const SizedBox(height: 8),

            // App Name
            AnimatedBuilder(
              animation: _textFade,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _textFade,
                  child: Column(
                    children: [
                      Text(
                        'Premium Property Solutions',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 60),

             // DHA Loading Indicator
             AnimatedBuilder(
               animation: _progressFade,
               builder: (context, child) {
                 return FadeTransition(
                   opacity: _progressFade,
                   child: DHALoadingWidget(
                     size: 120,
                     message: 'Loading...',
                     showMessage: true,
                   ),
                 );
               },
             ),
          ],
        ),
      ),
    );
  }
}

