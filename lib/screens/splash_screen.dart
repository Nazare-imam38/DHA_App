import 'dart:math' as math;
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
  late AnimationController _borderProgressController;
  
  late Animation<double> _logoScale;
  late Animation<double> _textFade;
  late Animation<double> _progressFade;
  late Animation<double> _borderProgress;

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
    
    _borderProgressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(); // Repeat continuously

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );
    
    _progressFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeIn),
    );
    
    _borderProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _borderProgressController, curve: Curves.linear),
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
    _borderProgressController.dispose();
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
              // DHA Logo - Extra Large and Prominent with Border Progress Bar
              AnimatedBuilder(
                animation: Listenable.merge([_logoController, _borderProgressController]),
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScale.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Border Progress Bar (drawn around the logo container)
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: CustomPaint(
                            painter: BorderProgressPainter(
                              progress: _borderProgress.value,
                              borderWidth: 5,
                              borderRadius: 40,
                            ),
                          ),
                        ),
                        // Logo Container
                        Container(
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
                      ],
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
    // Calculate the perimeter of the rounded rectangle
    final perimeter = 2 * (size.width + size.height) - 8 * borderRadius + 2 * math.pi * borderRadius;
    final progressLength = perimeter * progress;
    
    // Define colors: teal to blue gradient
    final tealColor = Color(0xFF20B2AA); // Teal
    final blueColor = Color(0xFF1B5993); // Blue
    
    // Create a path that follows the border
    final path = _createBorderPath(size, borderRadius);
    
    // Create a gradient shader along the path
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;
    
    // Draw the progress segment with gradient
    final progressPath = _getProgressPath(size, borderRadius, progressLength, perimeter);
    
    // Create gradient colors for the progress bar
    final colors = <Color>[];
    final stops = <double>[];
    final numStops = 20;
    
    for (int i = 0; i <= numStops; i++) {
      final t = i / numStops;
      colors.add(Color.lerp(tealColor, blueColor, t)!);
      stops.add(t);
    }
    
    // Draw segments with gradient effect
    final segmentLength = progressLength / numStops;
    double currentLength = 0;
    
    while (currentLength < progressLength) {
      final segmentStart = currentLength;
      final segmentEnd = (currentLength + segmentLength).clamp(0.0, progressLength);
      final segmentProgress = segmentStart / perimeter;
      
      // Interpolate color
      final color = Color.lerp(tealColor, blueColor, segmentProgress)!;
      paint.color = color;
      
      // Draw this segment
      final segmentPath = _getProgressPath(size, borderRadius, segmentEnd, perimeter, startDistance: segmentStart);
      canvas.drawPath(segmentPath, paint);
      
      currentLength = segmentEnd;
    }
  }
  
  Path _createBorderPath(Size size, double radius) {
    final path = Path();
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    path.addRRect(rrect);
    return path;
  }
  
  Path _getProgressPath(Size size, double radius, double progressLength, double totalPerimeter, {double startDistance = 0.0}) {
    final path = Path();
    double currentDistance = startDistance;
    final endDistance = progressLength;
    final halfBorder = borderWidth / 2;
    
    // Top edge (left to right)
    final topEdgeLength = size.width - 2 * radius;
    if (currentDistance < endDistance && currentDistance < topEdgeLength) {
      final startX = currentDistance;
      final endX = math.min(endDistance, topEdgeLength);
      if (endX > startX) {
        path.moveTo(radius + startX, halfBorder);
        path.lineTo(radius + endX, halfBorder);
      }
      currentDistance = endX;
    }
    
    // Top-right corner
    if (currentDistance < endDistance) {
      final cornerStart = math.max(0.0, currentDistance - topEdgeLength);
      final cornerEnd = math.min(math.pi * radius, endDistance - topEdgeLength);
      if (cornerEnd > cornerStart) {
        final startAngle = cornerStart / radius;
        final endAngle = cornerEnd / radius;
        path.addArc(
          Rect.fromLTWH(size.width - radius * 2, 0, radius * 2, radius * 2),
          startAngle,
          endAngle - startAngle,
        );
        currentDistance = topEdgeLength + cornerEnd;
      }
    }
    
    // Right edge (top to bottom)
    if (currentDistance < endDistance) {
      final rightEdgeStart = topEdgeLength + math.pi * radius;
      final rightEdgeLength = size.height - 2 * radius;
      final edgeStart = math.max(0.0, currentDistance - rightEdgeStart);
      final edgeEnd = math.min(rightEdgeLength, endDistance - rightEdgeStart);
      if (edgeEnd > edgeStart) {
        path.moveTo(size.width - halfBorder, radius + edgeStart);
        path.lineTo(size.width - halfBorder, radius + edgeEnd);
        currentDistance = rightEdgeStart + edgeEnd;
      }
    }
    
    // Bottom-right corner
    if (currentDistance < endDistance) {
      final bottomRightStart = topEdgeLength + math.pi * radius + (size.height - 2 * radius);
      final cornerStart = math.max(0.0, currentDistance - bottomRightStart);
      final cornerEnd = math.min(math.pi * radius, endDistance - bottomRightStart);
      if (cornerEnd > cornerStart) {
        final startAngle = math.pi / 2 - cornerStart / radius;
        final endAngle = math.pi / 2 - cornerEnd / radius;
        path.addArc(
          Rect.fromLTWH(size.width - radius * 2, size.height - radius * 2, radius * 2, radius * 2),
          startAngle,
          endAngle - startAngle,
        );
        currentDistance = bottomRightStart + cornerEnd;
      }
    }
    
    // Bottom edge (right to left)
    if (currentDistance < endDistance) {
      final bottomEdgeStart = topEdgeLength + math.pi * radius + (size.height - 2 * radius) + math.pi * radius;
      final bottomEdgeLength = size.width - 2 * radius;
      final edgeStart = math.max(0.0, currentDistance - bottomEdgeStart);
      final edgeEnd = math.min(bottomEdgeLength, endDistance - bottomEdgeStart);
      if (edgeEnd > edgeStart) {
        path.moveTo(size.width - radius - edgeStart, size.height - halfBorder);
        path.lineTo(size.width - radius - edgeEnd, size.height - halfBorder);
        currentDistance = bottomEdgeStart + edgeEnd;
      }
    }
    
    // Bottom-left corner
    if (currentDistance < endDistance) {
      final bottomLeftStart = topEdgeLength + math.pi * radius + (size.height - 2 * radius) + math.pi * radius + (size.width - 2 * radius);
      final cornerStart = math.max(0.0, currentDistance - bottomLeftStart);
      final cornerEnd = math.min(math.pi * radius, endDistance - bottomLeftStart);
      if (cornerEnd > cornerStart) {
        final startAngle = math.pi - cornerStart / radius;
        final endAngle = math.pi - cornerEnd / radius;
        path.addArc(
          Rect.fromLTWH(0, size.height - radius * 2, radius * 2, radius * 2),
          startAngle,
          endAngle - startAngle,
        );
        currentDistance = bottomLeftStart + cornerEnd;
      }
    }
    
    // Left edge (bottom to top)
    if (currentDistance < endDistance) {
      final leftEdgeStart = topEdgeLength + math.pi * radius + (size.height - 2 * radius) + math.pi * radius + (size.width - 2 * radius) + math.pi * radius;
      final leftEdgeLength = size.height - 2 * radius;
      final edgeStart = math.max(0.0, currentDistance - leftEdgeStart);
      final edgeEnd = math.min(leftEdgeLength, endDistance - leftEdgeStart);
      if (edgeEnd > edgeStart) {
        path.moveTo(halfBorder, size.height - radius - edgeStart);
        path.lineTo(halfBorder, size.height - radius - edgeEnd);
        currentDistance = leftEdgeStart + edgeEnd;
      }
    }
    
    // Top-left corner
    if (currentDistance < endDistance) {
      final topLeftStart = topEdgeLength + math.pi * radius + (size.height - 2 * radius) + math.pi * radius + (size.width - 2 * radius) + math.pi * radius + (size.height - 2 * radius);
      final cornerStart = math.max(0.0, currentDistance - topLeftStart);
      final cornerEnd = math.min(math.pi * radius, endDistance - topLeftStart);
      if (cornerEnd > cornerStart) {
        final startAngle = 3 * math.pi / 2 - cornerStart / radius;
        final endAngle = 3 * math.pi / 2 - cornerEnd / radius;
        path.addArc(
          Rect.fromLTWH(0, 0, radius * 2, radius * 2),
          startAngle,
          endAngle - startAngle,
        );
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

