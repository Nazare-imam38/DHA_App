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
/// Draws a running LED effect that starts from top-right corner and moves around the border
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
    final halfBorder = borderWidth / 2;
    final adjustedRadius = borderRadius - halfBorder;
    
    // Calculate edge lengths
    final topEdgeLength = size.width - 2 * borderRadius;
    final rightEdgeLength = size.height - 2 * borderRadius;
    final bottomEdgeLength = size.width - 2 * borderRadius;
    final leftEdgeLength = size.height - 2 * borderRadius;
    final cornerLength = math.pi * adjustedRadius / 2; // Quarter circle for each corner
    
    // Total perimeter starting from top-right corner
    // Path: top-right corner → right edge → bottom-right corner → bottom edge → 
    //       bottom-left corner → left edge → top-left corner → top edge → back to top-right
    final perimeter = cornerLength + // Top-right corner (quarter circle)
                     rightEdgeLength + cornerLength + // Right edge + bottom-right corner
                     bottomEdgeLength + cornerLength + // Bottom edge + bottom-left corner
                     leftEdgeLength + cornerLength + // Left edge + top-left corner
                     topEdgeLength; // Top edge back to top-right corner
    
    // Define colors: teal to blue gradient
    final tealColor = Color(0xFF20B2AA); // Teal
    final blueColor = Color(0xFF1B5993); // Blue
    final brightColor = Colors.white; // Bright LED color
    
    // Running LED effect parameters
    final ledLength = perimeter * 0.2; // Length of the LED trail (20% of perimeter)
    final ledPosition = (progress * perimeter) % perimeter; // Current position of LED
    
    // Draw the running LED with trailing effect
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    // Draw the LED trail (fading from bright to dim)
    final numSegments = 40;
    for (int i = 0; i < numSegments; i++) {
      final segmentProgress = i / numSegments;
      final segmentStartDistance = (ledPosition - ledLength * (1 - segmentProgress)) % perimeter;
      final segmentEndDistance = (ledPosition - ledLength * (1 - (i + 1) / numSegments)) % perimeter;
      
      // Normalize to positive values
      final segmentStart = segmentStartDistance < 0 ? segmentStartDistance + perimeter : segmentStartDistance;
      final segmentEnd = segmentEndDistance < 0 ? segmentEndDistance + perimeter : segmentEndDistance;
      
      // Calculate opacity (brightest at the front, fading towards the back)
      final opacity = 1.0 - segmentProgress * 0.85; // Fade from 100% to 15%
      
      // Interpolate color from bright white to teal/blue
      final color = Color.lerp(
        brightColor.withOpacity(opacity),
        Color.lerp(tealColor, blueColor, 0.5)!.withOpacity(opacity * 0.6),
        segmentProgress * 0.8,
      )!;
      
      paint.color = color;
      
      // Draw the segment path
      final segmentPath = _createPathFromTopRight(
        size, 
        borderRadius, 
        adjustedRadius,
        halfBorder,
        segmentStart, 
        segmentEnd, 
        perimeter,
        topEdgeLength,
        rightEdgeLength,
        bottomEdgeLength,
        leftEdgeLength,
        cornerLength,
      );
      
      if (!segmentPath.getBounds().isEmpty) {
        canvas.drawPath(segmentPath, paint);
      }
    }
  }
  
  /// Create a path along the border starting from top-right corner
  /// Path order: top-right corner → right edge → bottom-right → bottom edge → 
  ///            bottom-left → left edge → top-left → top edge → back to top-right
  Path _createPathFromTopRight(
    Size size,
    double borderRadius,
    double adjustedRadius,
    double halfBorder,
    double startDistance,
    double endDistance,
    double totalPerimeter,
    double topEdgeLength,
    double rightEdgeLength,
    double bottomEdgeLength,
    double leftEdgeLength,
    double cornerLength,
  ) {
    final path = Path();
    
    // Normalize distances
    startDistance = startDistance % totalPerimeter;
    endDistance = endDistance % totalPerimeter;
    
    // Handle wrap-around
    bool wrapped = endDistance < startDistance;
    double currentDistance = startDistance;
    double targetDistance = wrapped ? totalPerimeter : endDistance;
    
    // Calculate segment boundaries starting from top-right corner
    double topRightCornerStart = 0;
    double topRightCornerEnd = cornerLength;
    double rightEdgeStart = topRightCornerEnd;
    double rightEdgeEnd = rightEdgeStart + rightEdgeLength;
    double bottomRightCornerStart = rightEdgeEnd;
    double bottomRightCornerEnd = bottomRightCornerStart + cornerLength;
    double bottomEdgeStart = bottomRightCornerEnd;
    double bottomEdgeEnd = bottomEdgeStart + bottomEdgeLength;
    double bottomLeftCornerStart = bottomEdgeEnd;
    double bottomLeftCornerEnd = bottomLeftCornerStart + cornerLength;
    double leftEdgeStart = bottomLeftCornerEnd;
    double leftEdgeEnd = leftEdgeStart + leftEdgeLength;
    double topLeftCornerStart = leftEdgeEnd;
    double topLeftCornerEnd = topLeftCornerStart + cornerLength;
    double topEdgeStart = topLeftCornerEnd;
    double topEdgeEnd = topEdgeStart + topEdgeLength;
    
    // Draw first segment (until wrap or end)
    _drawPathSegment(
      path, size, borderRadius, adjustedRadius, halfBorder,
      currentDistance, targetDistance,
      topRightCornerStart, topRightCornerEnd,
      rightEdgeStart, rightEdgeEnd,
      bottomRightCornerStart, bottomRightCornerEnd,
      bottomEdgeStart, bottomEdgeEnd,
      bottomLeftCornerStart, bottomLeftCornerEnd,
      leftEdgeStart, leftEdgeEnd,
      topLeftCornerStart, topLeftCornerEnd,
      topEdgeStart, topEdgeEnd,
    );
    
    // If wrapped, draw from 0 to endDistance
    if (wrapped) {
      _drawPathSegment(
        path, size, borderRadius, adjustedRadius, halfBorder,
        0, endDistance,
        topRightCornerStart, topRightCornerEnd,
        rightEdgeStart, rightEdgeEnd,
        bottomRightCornerStart, bottomRightCornerEnd,
        bottomEdgeStart, bottomEdgeEnd,
        bottomLeftCornerStart, bottomLeftCornerEnd,
        leftEdgeStart, leftEdgeEnd,
        topLeftCornerStart, topLeftCornerEnd,
        topEdgeStart, topEdgeEnd,
      );
    }
    
    return path;
  }
  
  void _drawPathSegment(
    Path path,
    Size size,
    double borderRadius,
    double adjustedRadius,
    double halfBorder,
    double startDistance,
    double endDistance,
    double topRightCornerStart,
    double topRightCornerEnd,
    double rightEdgeStart,
    double rightEdgeEnd,
    double bottomRightCornerStart,
    double bottomRightCornerEnd,
    double bottomEdgeStart,
    double bottomEdgeEnd,
    double bottomLeftCornerStart,
    double bottomLeftCornerEnd,
    double leftEdgeStart,
    double leftEdgeEnd,
    double topLeftCornerStart,
    double topLeftCornerEnd,
    double topEdgeStart,
    double topEdgeEnd,
  ) {
    double currentDistance = startDistance;
    
    // Top-right corner (starting point) - from top to right
    if (currentDistance < endDistance && currentDistance < topRightCornerEnd) {
      final cornerStart = math.max(0.0, currentDistance - topRightCornerStart);
      final cornerEnd = math.min(endDistance - topRightCornerStart, topRightCornerEnd - topRightCornerStart);
      if (cornerEnd > cornerStart) {
        final startAngle = -math.pi / 2 + cornerStart / adjustedRadius;
        final endAngle = -math.pi / 2 + cornerEnd / adjustedRadius;
        final centerX = size.width - borderRadius;
        final centerY = borderRadius;
        path.addArc(
          Rect.fromLTWH(centerX - adjustedRadius, centerY - adjustedRadius, adjustedRadius * 2, adjustedRadius * 2),
          startAngle,
          endAngle - startAngle,
        );
        currentDistance = topRightCornerStart + cornerEnd;
      }
    }
    
    // Right edge (top to bottom)
    if (currentDistance < endDistance && currentDistance < rightEdgeEnd) {
      final edgeStart = math.max(0.0, currentDistance - rightEdgeStart);
      final edgeEnd = math.min(endDistance - rightEdgeStart, rightEdgeEnd - rightEdgeStart);
      if (edgeEnd > edgeStart) {
        if (path.getBounds().isEmpty) {
          path.moveTo(size.width - halfBorder, borderRadius + edgeStart);
        }
        path.lineTo(size.width - halfBorder, borderRadius + edgeEnd);
        currentDistance = rightEdgeStart + edgeEnd;
      }
    }
    
    // Bottom-right corner
    if (currentDistance < endDistance && currentDistance < bottomRightCornerEnd) {
      final cornerStart = math.max(0.0, currentDistance - bottomRightCornerStart);
      final cornerEnd = math.min(endDistance - bottomRightCornerStart, bottomRightCornerEnd - bottomRightCornerStart);
      if (cornerEnd > cornerStart) {
        final startAngle = cornerStart / adjustedRadius;
        final endAngle = cornerEnd / adjustedRadius;
        final centerX = size.width - borderRadius;
        final centerY = size.height - borderRadius;
        path.addArc(
          Rect.fromLTWH(centerX - adjustedRadius, centerY - adjustedRadius, adjustedRadius * 2, adjustedRadius * 2),
          startAngle,
          endAngle - startAngle,
        );
        currentDistance = bottomRightCornerStart + cornerEnd;
      }
    }
    
    // Bottom edge (right to left)
    if (currentDistance < endDistance && currentDistance < bottomEdgeEnd) {
      final edgeStart = math.max(0.0, currentDistance - bottomEdgeStart);
      final edgeEnd = math.min(endDistance - bottomEdgeStart, bottomEdgeEnd - bottomEdgeStart);
      if (edgeEnd > edgeStart) {
        if (path.getBounds().isEmpty) {
          path.moveTo(size.width - borderRadius - edgeStart, size.height - halfBorder);
        }
        path.lineTo(size.width - borderRadius - edgeEnd, size.height - halfBorder);
        currentDistance = bottomEdgeStart + edgeEnd;
      }
    }
    
    // Bottom-left corner
    if (currentDistance < endDistance && currentDistance < bottomLeftCornerEnd) {
      final cornerStart = math.max(0.0, currentDistance - bottomLeftCornerStart);
      final cornerEnd = math.min(endDistance - bottomLeftCornerStart, bottomLeftCornerEnd - bottomLeftCornerStart);
      if (cornerEnd > cornerStart) {
        final startAngle = math.pi / 2 + cornerStart / adjustedRadius;
        final endAngle = math.pi / 2 + cornerEnd / adjustedRadius;
        final centerX = borderRadius;
        final centerY = size.height - borderRadius;
        path.addArc(
          Rect.fromLTWH(centerX - adjustedRadius, centerY - adjustedRadius, adjustedRadius * 2, adjustedRadius * 2),
          startAngle,
          endAngle - startAngle,
        );
        currentDistance = bottomLeftCornerStart + cornerEnd;
      }
    }
    
    // Left edge (bottom to top)
    if (currentDistance < endDistance && currentDistance < leftEdgeEnd) {
      final edgeStart = math.max(0.0, currentDistance - leftEdgeStart);
      final edgeEnd = math.min(endDistance - leftEdgeStart, leftEdgeEnd - leftEdgeStart);
      if (edgeEnd > edgeStart) {
        if (path.getBounds().isEmpty) {
          path.moveTo(halfBorder, size.height - borderRadius - edgeStart);
        }
        path.lineTo(halfBorder, size.height - borderRadius - edgeEnd);
        currentDistance = leftEdgeStart + edgeEnd;
      }
    }
    
    // Top-left corner
    if (currentDistance < endDistance && currentDistance < topLeftCornerEnd) {
      final cornerStart = math.max(0.0, currentDistance - topLeftCornerStart);
      final cornerEnd = math.min(endDistance - topLeftCornerStart, topLeftCornerEnd - topLeftCornerStart);
      if (cornerEnd > cornerStart) {
        final startAngle = math.pi + cornerStart / adjustedRadius;
        final endAngle = math.pi + cornerEnd / adjustedRadius;
        final centerX = borderRadius;
        final centerY = borderRadius;
        path.addArc(
          Rect.fromLTWH(centerX - adjustedRadius, centerY - adjustedRadius, adjustedRadius * 2, adjustedRadius * 2),
          startAngle,
          endAngle - startAngle,
        );
        currentDistance = topLeftCornerStart + cornerEnd;
      }
    }
    
    // Top edge (left to right) - back to start
    if (currentDistance < endDistance && currentDistance < topEdgeEnd) {
      final edgeStart = math.max(0.0, currentDistance - topEdgeStart);
      final edgeEnd = math.min(endDistance - topEdgeStart, topEdgeEnd - topEdgeStart);
      if (edgeEnd > edgeStart) {
        if (path.getBounds().isEmpty) {
          path.moveTo(borderRadius + edgeStart, halfBorder);
        }
        path.lineTo(borderRadius + edgeEnd, halfBorder);
      }
    }
  }

  @override
  bool shouldRepaint(BorderProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.borderRadius != borderRadius;
  }
}

