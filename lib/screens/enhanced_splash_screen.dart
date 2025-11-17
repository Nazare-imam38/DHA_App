import 'dart:async';
import 'dart:math' as math;
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
  late AnimationController _borderProgressController;
  
  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoHeartbeatScale;
  late Animation<double> _dhaTextSlide;
  late Animation<double> _dhaTextOpacity;
  late Animation<double> _marketplaceTextSlide;
  late Animation<double> _marketplaceTextOpacity;
  late Animation<double> _progressFade;
  late Animation<double> _borderProgress;
  
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
    
    _borderProgressController = AnimationController(
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
    
    _borderProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _borderProgressController, curve: Curves.linear),
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
    
    // Step 7: Start border progress bar animation after text moves back into logo
    await Future.delayed(const Duration(milliseconds: 200));
    _borderProgressController.repeat(); // Start continuous border animation
    
    // Step 8: Start preloading
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
    _borderProgressController.dispose();
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
              // Logo - appears first with heartbeat animation and border progress bar
              AnimatedBuilder(
                animation: Listenable.merge([_logoScale, _logoOpacity, _logoHeartbeatScale, _borderProgressController]),
                builder: (context, child) {
                  // Combine initial scale with heartbeat scale
                  final combinedScale = _logoScale.value * _logoHeartbeatScale.value;
                  
                  return Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: combinedScale,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Border Progress Bar (drawn around the logo container)
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: CustomPaint(
                              painter: BorderProgressPainter(
                                progress: _borderProgress.value,
                                borderWidth: 5,
                                borderRadius: 30,
                              ),
                            ),
                          ),
                          // Logo Container
                          Container(
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
                        ],
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
                          fontFamily: 'Poppins',
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
                          fontFamily: 'Poppins',
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

/// Custom Painter for Border Progress Bar
/// Draws a progress bar that runs around the border of a rounded rectangle
class BorderProgressPainter extends CustomPainter {
  final double progress;
  final double borderWidth;
  final double borderRadius;
  
  BorderProgressPainter({
    required this.progress,
    required this.borderWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final halfBorder = borderWidth / 2;
    final adjustedRadius = borderRadius - halfBorder;
    
    // Calculate edge lengths
    final topEdgeLength = size.width - 2 * borderRadius;
    final rightEdgeLength = size.height - 2 * borderRadius;
    final bottomEdgeLength = size.width - 2 * borderRadius;
    final leftEdgeLength = size.height - 2 * borderRadius;
    final cornerLength = math.pi * adjustedRadius / 2; // Quarter circle for each corner
    
    // Calculate total perimeter starting from top-left corner
    // Path: top-left corner → top edge → top-right corner → right edge → 
    //       bottom-right corner → bottom edge → bottom-left corner → left edge → back to top-left
    final perimeter = cornerLength + // Top-left corner
                     topEdgeLength + cornerLength + // Top edge + top-right corner
                     rightEdgeLength + cornerLength + // Right edge + bottom-right corner
                     bottomEdgeLength + cornerLength + // Bottom edge + bottom-left corner
                     leftEdgeLength; // Left edge back to start
    
    // Calculate how far along the perimeter we should draw (0 to perimeter)
    final drawDistance = progress * perimeter;
    
    // Define colors: teal to blue gradient
    final tealColor = Color(0xFF20B2AA); // Teal
    final blueColor = Color(0xFF1B5993); // Blue
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    // Create path that traces the complete border from start to current progress
    final path = _createCompleteBorderPath(size, adjustedRadius, halfBorder, drawDistance, perimeter,
        topEdgeLength, rightEdgeLength, bottomEdgeLength, leftEdgeLength, cornerLength);
    
    // Create sweep gradient that follows the border path
    final sweepGradient = SweepGradient(
      center: Alignment.center,
      startAngle: 0.0,
      endAngle: 2 * math.pi,
      colors: [tealColor, blueColor, tealColor],
      stops: [0.0, 0.5, 1.0],
    );
    
    paint.shader = sweepGradient.createShader(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );
    
    // Draw the complete border path
    canvas.drawPath(path, paint);
  }
  
  Path _createCompleteBorderPath(Size size, double adjustedRadius, double halfBorder, 
      double drawDistance, double totalPerimeter,
      double topEdgeLength, double rightEdgeLength, double bottomEdgeLength, 
      double leftEdgeLength, double cornerLength) {
    final path = Path();
    double currentDistance = 0.0;
    
    // Calculate positions for each edge starting from top-left corner
    final topLeftCornerStart = 0.0;
    final topLeftCornerEnd = cornerLength;
    final topStart = topLeftCornerEnd;
    final topEnd = topStart + topEdgeLength;
    final topRightCornerStart = topEnd;
    final topRightCornerEnd = topRightCornerStart + cornerLength;
    final rightStart = topRightCornerEnd;
    final rightEnd = rightStart + rightEdgeLength;
    final bottomRightCornerStart = rightEnd;
    final bottomRightCornerEnd = bottomRightCornerStart + cornerLength;
    final bottomStart = bottomRightCornerEnd;
    final bottomEnd = bottomStart + bottomEdgeLength;
    final bottomLeftCornerStart = bottomEnd;
    final bottomLeftCornerEnd = bottomLeftCornerStart + cornerLength;
    final leftStart = bottomLeftCornerEnd;
    final leftEnd = leftStart + leftEdgeLength;
    
    // Start from top-left corner (at the point where the corner arc begins)
    path.moveTo(adjustedRadius, halfBorder);
    
    // Top-left corner (quarter circle from π to π/2)
    if (drawDistance > currentDistance) {
      if (drawDistance <= topLeftCornerEnd) {
        final cornerProgress = drawDistance / cornerLength;
        final sweepAngle = math.pi / 2 * cornerProgress;
        path.addArc(
          Rect.fromLTWH(0, 0, adjustedRadius * 2, adjustedRadius * 2),
          math.pi,
          sweepAngle,
        );
        return path;
      } else {
        path.addArc(
          Rect.fromLTWH(0, 0, adjustedRadius * 2, adjustedRadius * 2),
          math.pi,
          math.pi / 2,
        );
        currentDistance = topLeftCornerEnd;
      }
    }
    
    // Top edge (left to right)
    if (drawDistance > currentDistance) {
      if (drawDistance <= topEnd) {
        final edgeProgress = (drawDistance - currentDistance) / topEdgeLength;
        final endX = adjustedRadius + topEdgeLength * edgeProgress;
        path.lineTo(endX, halfBorder);
        return path;
      } else {
        path.lineTo(size.width - adjustedRadius, halfBorder);
        currentDistance = topEnd;
      }
    }
    
    // Top-right corner (quarter circle from π/2 to 0)
    if (drawDistance > currentDistance) {
      if (drawDistance <= topRightCornerEnd) {
        final cornerProgress = (drawDistance - currentDistance) / cornerLength;
        final sweepAngle = -math.pi / 2 * cornerProgress;
        path.addArc(
          Rect.fromLTWH(size.width - adjustedRadius * 2, 0, adjustedRadius * 2, adjustedRadius * 2),
          math.pi / 2,
          sweepAngle,
        );
        return path;
      } else {
        path.addArc(
          Rect.fromLTWH(size.width - adjustedRadius * 2, 0, adjustedRadius * 2, adjustedRadius * 2),
          math.pi / 2,
          -math.pi / 2,
        );
        currentDistance = topRightCornerEnd;
      }
    }
    
    // Right edge (top to bottom)
    if (drawDistance > currentDistance) {
      if (drawDistance <= rightEnd) {
        final edgeProgress = (drawDistance - currentDistance) / rightEdgeLength;
        final endY = adjustedRadius + rightEdgeLength * edgeProgress;
        path.lineTo(size.width - halfBorder, endY);
        return path;
      } else {
        path.lineTo(size.width - halfBorder, size.height - adjustedRadius);
        currentDistance = rightEnd;
      }
    }
    
    // Bottom-right corner (quarter circle from 0 to -π/2)
    if (drawDistance > currentDistance) {
      if (drawDistance <= bottomRightCornerEnd) {
        final cornerProgress = (drawDistance - currentDistance) / cornerLength;
        final sweepAngle = -math.pi / 2 * cornerProgress;
        path.addArc(
          Rect.fromLTWH(size.width - adjustedRadius * 2, size.height - adjustedRadius * 2, adjustedRadius * 2, adjustedRadius * 2),
          0.0,
          sweepAngle,
        );
        return path;
      } else {
        path.addArc(
          Rect.fromLTWH(size.width - adjustedRadius * 2, size.height - adjustedRadius * 2, adjustedRadius * 2, adjustedRadius * 2),
          0.0,
          -math.pi / 2,
        );
        currentDistance = bottomRightCornerEnd;
      }
    }
    
    // Bottom edge (right to left)
    if (drawDistance > currentDistance) {
      if (drawDistance <= bottomEnd) {
        final edgeProgress = (drawDistance - currentDistance) / bottomEdgeLength;
        final endX = size.width - adjustedRadius - bottomEdgeLength * edgeProgress;
        path.lineTo(endX, size.height - halfBorder);
        return path;
      } else {
        path.lineTo(adjustedRadius, size.height - halfBorder);
        currentDistance = bottomEnd;
      }
    }
    
    // Bottom-left corner (quarter circle from -π/2 to -π)
    if (drawDistance > currentDistance) {
      if (drawDistance <= bottomLeftCornerEnd) {
        final cornerProgress = (drawDistance - currentDistance) / cornerLength;
        final sweepAngle = -math.pi / 2 * cornerProgress;
        path.addArc(
          Rect.fromLTWH(0, size.height - adjustedRadius * 2, adjustedRadius * 2, adjustedRadius * 2),
          -math.pi / 2,
          sweepAngle,
        );
        return path;
      } else {
        path.addArc(
          Rect.fromLTWH(0, size.height - adjustedRadius * 2, adjustedRadius * 2, adjustedRadius * 2),
          -math.pi / 2,
          -math.pi / 2,
        );
        currentDistance = bottomLeftCornerEnd;
      }
    }
    
    // Left edge (bottom to top) - back to start
    if (drawDistance > currentDistance) {
      if (drawDistance <= leftEnd) {
        final edgeProgress = (drawDistance - currentDistance) / leftEdgeLength;
        final endY = size.height - adjustedRadius - leftEdgeLength * edgeProgress;
        path.lineTo(halfBorder, endY);
        return path;
      } else {
        // Complete the loop back to start
        path.lineTo(halfBorder, adjustedRadius);
        path.lineTo(adjustedRadius, halfBorder);
      }
    }
    
    return path;
  }
  

  @override
  bool shouldRepaint(BorderProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.borderRadius != borderRadius;
  }
}