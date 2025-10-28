import 'package:flutter/material.dart';
import 'cached_asset_image.dart';

class DHALoadingWidget extends StatefulWidget {
  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;
  final String? message;
  final bool showMessage;

  const DHALoadingWidget({
    Key? key,
    this.size = 80.0,
    this.primaryColor,
    this.secondaryColor,
    this.message,
    this.showMessage = false,
  }) : super(key: key);

  @override
  State<DHALoadingWidget> createState() => _DHALoadingWidgetState();
}

class _DHALoadingWidgetState extends State<DHALoadingWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? const Color(0xFF20B2AA);
    final secondaryColor = widget.secondaryColor ?? const Color(0xFF4CAF50);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer rotating ring
              AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value * 2 * 3.14159,
                    child: CustomPaint(
                      size: Size(widget.size, widget.size),
                      painter: _RotatingRingPainter(
                        color: primaryColor.withOpacity(0.3),
                        strokeWidth: 3.0,
                      ),
                    ),
                  );
                },
              ),
              
              // Middle rotating ring (opposite direction)
              AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: -_rotationAnimation.value * 2 * 3.14159,
                    child: CustomPaint(
                      size: Size(widget.size * 0.7, widget.size * 0.7),
                      painter: _RotatingRingPainter(
                        color: secondaryColor.withOpacity(0.4),
                        strokeWidth: 2.5,
                      ),
                    ),
                  );
                },
              ),
              
              // Inner pulsing ring
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: widget.size * 0.4,
                      height: widget.size * 0.4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryColor.withOpacity(0.6),
                          width: 2.0,
                        ),
                      ),
                    ),
                  );
                },
              ),
              
              // DHA Logo at center
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.8 + (_pulseAnimation.value - 1.0) * 0.2,
                     child: Container(
                       width: widget.size * 0.5,
                       height: widget.size * 0.5,
                       decoration: BoxDecoration(
                         shape: BoxShape.circle,
                         color: Colors.transparent,
                       ),
                      child: ClipOval(
                        child: CachedAssetImage(
                          assetPath: 'assets/images/dhalogo.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.apartment,
                                color: Colors.white,
                                size: 20,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        
        if (widget.showMessage && widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

class _RotatingRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _RotatingRingPainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth / 2;

    // Draw dashed circle
    const dashWidth = 8.0;
    const dashSpace = 4.0;
    const totalDashLength = dashWidth + dashSpace;
    final circumference = 2 * 3.14159 * radius;
    final numberOfDashes = (circumference / totalDashLength).floor();

    for (int i = 0; i < numberOfDashes; i++) {
      final startAngle = (i * totalDashLength / radius) - (3.14159 / 2);
      final endAngle = startAngle + (dashWidth / radius);
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        endAngle - startAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Full screen loading overlay
class DHALoadingOverlay extends StatelessWidget {
  final String? message;
  final Color? backgroundColor;

  const DHALoadingOverlay({
    Key? key,
    this.message,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? Colors.transparent,
      child: Center(
        child: DHALoadingWidget(
          size: 120,
          message: message ?? 'Loading...',
          showMessage: true,
        ),
      ),
    );
  }
}

// Compact loading indicator for buttons or small areas
class DHALoadingButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? color;

  const DHALoadingButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = color ?? const Color(0xFF20B2AA);
    
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 2,
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: DHALoadingWidget(
                size: 20,
                primaryColor: Colors.white,
                secondaryColor: Colors.white.withOpacity(0.7),
              ),
            )
          : Text(
              text,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
