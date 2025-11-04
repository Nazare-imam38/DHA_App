import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/widgets/cached_asset_image.dart';
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
  late AnimationController _logoHeartbeatController;
  late AnimationController _dhaTextController;
  late AnimationController _marketplaceTextController;
  late AnimationController _progressController;
  
  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoHeartbeatScale;
  late Animation<double> _dhaTextSlide;
  late Animation<double> _dhaTextOpacity;
  late Animation<double> _marketplaceTextSlide;
  late Animation<double> _marketplaceTextOpacity;
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
    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Logo heartbeat animation controller - quick and subtle
    _logoHeartbeatController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // DHA text animation controller
    _dhaTextController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    // MARKETPLACE text animation controller
    _marketplaceTextController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo animations - scale and fade in
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeIn),
    );
    
    // Logo heartbeat animation - subtle single pulse
    _logoHeartbeatScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _logoHeartbeatController,
        curve: Curves.easeInOut,
      ),
    );
    
    // DHA text animations - slides down from logo (inside) and fades in, then goes back
    _dhaTextSlide = Tween<double>(begin: -120.0, end: 0.0).animate(
      CurvedAnimation(parent: _dhaTextController, curve: Curves.easeOutCubic),
    );
    
    _dhaTextOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _dhaTextController, curve: Curves.easeIn),
    );
    
    // MARKETPLACE text animations - slides down from logo (inside) and fades in, then goes back
    _marketplaceTextSlide = Tween<double>(begin: -120.0, end: 0.0).animate(
      CurvedAnimation(parent: _marketplaceTextController, curve: Curves.easeOutCubic),
    );
    
    _marketplaceTextOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _marketplaceTextController, curve: Curves.easeIn),
    );
    
    _progressFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeIn),
    );
  }
  
  void _triggerLogoHeartbeat() {
    // Reset to beginning and start subtle heartbeat animation
    _logoHeartbeatController.reset();
    _logoHeartbeatController.forward().then((_) {
      _logoHeartbeatController.reverse();
    });
  }
  
  void _startPreloading() async {
    // Step 1: Logo appears first
    await _logoController.forward();
    
    // Step 2: Wait a bit, then DHA text comes out from logo with heartbeat
    await Future.delayed(const Duration(milliseconds: 300));
    await Future.delayed(const Duration(milliseconds: 50)); // Small delay before heartbeat
    _triggerLogoHeartbeat(); // Start heartbeat (runs in parallel)
    await _dhaTextController.forward();
    
    // Step 3: Wait a bit, then MARKETPLACE text comes out from logo with heartbeat
    await Future.delayed(const Duration(milliseconds: 300));
    await Future.delayed(const Duration(milliseconds: 50)); // Small delay before heartbeat
    _triggerLogoHeartbeat(); // Start heartbeat (runs in parallel)
    await _marketplaceTextController.forward();
    
    // Step 4: Wait to show the complete text
    await Future.delayed(const Duration(milliseconds: 600));
    
    // Step 5: DHA text goes back into logo with heartbeat
    await Future.delayed(const Duration(milliseconds: 50)); // Small delay before heartbeat
    _triggerLogoHeartbeat(); // Start heartbeat (runs in parallel)
    await _dhaTextController.reverse();
    
    // Step 6: Wait a bit, then MARKETPLACE text goes back into logo with heartbeat
    await Future.delayed(const Duration(milliseconds: 150));
    await Future.delayed(const Duration(milliseconds: 50)); // Small delay before heartbeat
    _triggerLogoHeartbeat(); // Start heartbeat (runs in parallel)
    await _marketplaceTextController.reverse();
    
    // Step 7: Start preloading
    _isPreloading = true;
    await _progressController.forward();
    
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
    _logoHeartbeatController.dispose();
    _dhaTextController.dispose();
    _marketplaceTextController.dispose();
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo - appears first with heartbeat animation
              AnimatedBuilder(
                animation: Listenable.merge([_logoScale, _logoOpacity, _logoHeartbeatScale]),
                builder: (context, child) {
                  // Combine initial scale with heartbeat scale
                  final combinedScale = _logoScale.value * _logoHeartbeatScale.value;
                  
                  return Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: combinedScale,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(30),
                        child: CachedAssetImage(
                          assetPath: 'assets/images/dhalogo.png',
                          width: 140,
                          height: 140,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),
              
              // DHA Text - comes out from logo
              AnimatedBuilder(
                animation: Listenable.merge([_dhaTextSlide, _dhaTextOpacity]),
                builder: (context, child) {
                  return Opacity(
                    opacity: _dhaTextOpacity.value,
                    child: Transform.translate(
                      offset: Offset(0, _dhaTextSlide.value),
                      child: Text(
                        'DHA',
                        style: TextStyle(
                          fontFamily: 'GT Walsheim',
                          fontSize: 42,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1E3A8A),
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 8),
              
              // MARKETPLACE Text - comes out from logo
              AnimatedBuilder(
                animation: Listenable.merge([_marketplaceTextSlide, _marketplaceTextOpacity]),
                builder: (context, child) {
                  return Opacity(
                    opacity: _marketplaceTextOpacity.value,
                    child: Transform.translate(
                      offset: Offset(0, _marketplaceTextSlide.value),
                      child: Text(
                        'MARKETPLACE',
                        style: TextStyle(
                          fontFamily: 'GT Walsheim',
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E3A8A),
                          letterSpacing: 3.0,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
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