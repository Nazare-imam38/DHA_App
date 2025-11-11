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
    // Calculate the perimeter of the rounded rectangle
    final perimeter = 2 * (size.width + size.height) - 8 * borderRadius + 2 * math.pi * borderRadius;
    
    // Define colors: teal to blue gradient
    final tealColor = Color(0xFF20B2AA); // Teal
    final blueColor = Color(0xFF1B5993); // Blue
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    // Draw a continuous running line around the border
    // The line length is about 25% of the perimeter for a nice running effect
    final lineLength = perimeter * 0.25;
    final startDistance = perimeter * progress;
    final endDistance = (startDistance + lineLength) % perimeter;
    
    // Create path for the running line
    final path = _createRunningLinePath(size, borderRadius, startDistance, endDistance, perimeter);
    
    // Create gradient effect along the line
    final numSegments = 30;
    final segmentLength = lineLength / numSegments;
    double currentPos = startDistance;
    
    for (int i = 0; i < numSegments; i++) {
      final segmentProgress = (currentPos % perimeter) / perimeter;
      final color = Color.lerp(tealColor, blueColor, segmentProgress)!;
      paint.color = color;
      
      final segmentStart = currentPos;
      final segmentEnd = (currentPos + segmentLength) % perimeter;
      
      final segmentPath = _createRunningLinePath(size, borderRadius, segmentStart, segmentEnd, perimeter);
      canvas.drawPath(segmentPath, paint);
      
      currentPos = segmentEnd;
    }
  }
  
  Path _createRunningLinePath(Size size, double radius, double startDistance, double endDistance, double totalPerimeter) {
    final path = Path();
    final halfBorder = borderWidth / 2;
    double currentDistance = startDistance;
    
    // Normalize distances to be within [0, totalPerimeter]
    startDistance = startDistance % totalPerimeter;
    endDistance = endDistance % totalPerimeter;
    
    // Handle wrap-around case
    bool wrapped = endDistance < startDistance;
    final targetDistance = wrapped ? totalPerimeter : endDistance;
    
    // Calculate edge lengths
    final topEdgeLength = size.width - 2 * radius;
    final rightEdgeLength = size.height - 2 * radius;
    final bottomEdgeLength = size.width - 2 * radius;
    final leftEdgeLength = size.height - 2 * radius;
    final cornerLength = math.pi * radius;
    
    // Calculate positions for each edge
    final topStart = 0.0;
    final topEnd = topEdgeLength;
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
    final topLeftCornerStart = leftEnd;
    final topLeftCornerEnd = topLeftCornerStart + cornerLength;
    
    // Draw the line segment
    _drawSegment(path, size, radius, halfBorder, currentDistance, targetDistance,
        topStart, topEnd, topRightCornerStart, topRightCornerEnd,
        rightStart, rightEnd, bottomRightCornerStart, bottomRightCornerEnd,
        bottomStart, bottomEnd, bottomLeftCornerStart, bottomLeftCornerEnd,
        leftStart, leftEnd, topLeftCornerStart, topLeftCornerEnd);
    
    // If wrapped, draw from start to endDistance
    if (wrapped) {
      currentDistance = 0;
      _drawSegment(path, size, radius, halfBorder, currentDistance, endDistance,
          topStart, topEnd, topRightCornerStart, topRightCornerEnd,
          rightStart, rightEnd, bottomRightCornerStart, bottomRightCornerEnd,
          bottomStart, bottomEnd, bottomLeftCornerStart, bottomLeftCornerEnd,
          leftStart, leftEnd, topLeftCornerStart, topLeftCornerEnd);
    }
    
    return path;
  }
  
  void _drawSegment(Path path, Size size, double radius, double halfBorder,
      double startDistance, double endDistance,
      double topStart, double topEnd, double topRightCornerStart, double topRightCornerEnd,
      double rightStart, double rightEnd, double bottomRightCornerStart, double bottomRightCornerEnd,
      double bottomStart, double bottomEnd, double bottomLeftCornerStart, double bottomLeftCornerEnd,
      double leftStart, double leftEnd, double topLeftCornerStart, double topLeftCornerEnd) {
    
    double currentDistance = startDistance;
    
    // Top edge (left to right)
    if (currentDistance < endDistance && currentDistance < topEnd) {
      final startX = math.max(0.0, currentDistance - topStart);
      final endX = math.min(endDistance - topStart, topEnd - topStart);
      if (endX > startX) {
        if (path.getBounds().isEmpty) {
          path.moveTo(radius + startX, halfBorder);
        }
        path.lineTo(radius + endX, halfBorder);
      }
      currentDistance = topStart + endX;
    }
    
    // Top-right corner
    if (currentDistance < endDistance && currentDistance < topRightCornerEnd) {
      final cornerStart = math.max(0.0, currentDistance - topRightCornerStart);
      final cornerEnd = math.min(endDistance - topRightCornerStart, topRightCornerEnd - topRightCornerStart);
      if (cornerEnd > cornerStart) {
        final startAngle = cornerStart / radius;
        final endAngle = cornerEnd / radius;
        path.addArc(
          Rect.fromLTWH(size.width - radius * 2, 0, radius * 2, radius * 2),
          startAngle,
          endAngle - startAngle,
        );
        currentDistance = topRightCornerStart + cornerEnd;
      }
    }
    
    // Right edge (top to bottom)
    if (currentDistance < endDistance && currentDistance < rightEnd) {
      final edgeStart = math.max(0.0, currentDistance - rightStart);
      final edgeEnd = math.min(endDistance - rightStart, rightEnd - rightStart);
      if (edgeEnd > edgeStart) {
        if (path.getBounds().isEmpty) {
          path.moveTo(size.width - halfBorder, radius + edgeStart);
        }
        path.lineTo(size.width - halfBorder, radius + edgeEnd);
        currentDistance = rightStart + edgeEnd;
      }
    }
    
    // Bottom-right corner
    if (currentDistance < endDistance && currentDistance < bottomRightCornerEnd) {
      final cornerStart = math.max(0.0, currentDistance - bottomRightCornerStart);
      final cornerEnd = math.min(endDistance - bottomRightCornerStart, bottomRightCornerEnd - bottomRightCornerStart);
      if (cornerEnd > cornerStart) {
        final startAngle = math.pi / 2 - cornerStart / radius;
        final endAngle = math.pi / 2 - cornerEnd / radius;
        path.addArc(
          Rect.fromLTWH(size.width - radius * 2, size.height - radius * 2, radius * 2, radius * 2),
          startAngle,
          endAngle - startAngle,
        );
        currentDistance = bottomRightCornerStart + cornerEnd;
      }
    }
    
    // Bottom edge (right to left)
    if (currentDistance < endDistance && currentDistance < bottomEnd) {
      final edgeStart = math.max(0.0, currentDistance - bottomStart);
      final edgeEnd = math.min(endDistance - bottomStart, bottomEnd - bottomStart);
      if (edgeEnd > edgeStart) {
        if (path.getBounds().isEmpty) {
          path.moveTo(size.width - radius - edgeStart, size.height - halfBorder);
        }
        path.lineTo(size.width - radius - edgeEnd, size.height - halfBorder);
        currentDistance = bottomStart + edgeEnd;
      }
    }
    
    // Bottom-left corner
    if (currentDistance < endDistance && currentDistance < bottomLeftCornerEnd) {
      final cornerStart = math.max(0.0, currentDistance - bottomLeftCornerStart);
      final cornerEnd = math.min(endDistance - bottomLeftCornerStart, bottomLeftCornerEnd - bottomLeftCornerStart);
      if (cornerEnd > cornerStart) {
        final startAngle = math.pi - cornerStart / radius;
        final endAngle = math.pi - cornerEnd / radius;
        path.addArc(
          Rect.fromLTWH(0, size.height - radius * 2, radius * 2, radius * 2),
          startAngle,
          endAngle - startAngle,
        );
        currentDistance = bottomLeftCornerStart + cornerEnd;
      }
    }
    
    // Left edge (bottom to top)
    if (currentDistance < endDistance && currentDistance < leftEnd) {
      final edgeStart = math.max(0.0, currentDistance - leftStart);
      final edgeEnd = math.min(endDistance - leftStart, leftEnd - leftStart);
      if (edgeEnd > edgeStart) {
        if (path.getBounds().isEmpty) {
          path.moveTo(halfBorder, size.height - radius - edgeStart);
        }
        path.lineTo(halfBorder, size.height - radius - edgeEnd);
        currentDistance = leftStart + edgeEnd;
      }
    }
    
    // Top-left corner
    if (currentDistance < endDistance && currentDistance < topLeftCornerEnd) {
      final cornerStart = math.max(0.0, currentDistance - topLeftCornerStart);
      final cornerEnd = math.min(endDistance - topLeftCornerStart, topLeftCornerEnd - topLeftCornerStart);
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
  }

  @override
  bool shouldRepaint(BorderProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.borderRadius != borderRadius;
  }
}