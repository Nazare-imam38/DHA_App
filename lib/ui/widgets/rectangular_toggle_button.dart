import 'package:flutter/material.dart';

/// Rectangular toggle button widget
class RectangularToggleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onPressed;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? textColor;
  final Color? selectedTextColor;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final IconData? icon;

  const RectangularToggleButton({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onPressed,
    this.selectedColor,
    this.unselectedColor,
    this.textColor,
    this.selectedTextColor,
    this.width,
    this.height,
    this.padding,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height ?? 40,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                gradient: isSelected 
                    ? const LinearGradient(
                        colors: [Color(0xFF1E3C90), Color(0xFF20B2AA)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : LinearGradient(
                        colors: [Colors.grey[400]!, Colors.grey[500]!],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                icon ?? _getDefaultIcon(),
                color: Colors.white,
                size: 14,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected 
                    ? const Color(0xFF1E3C90)
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDefaultIcon() {
    if (text.toLowerCase().contains('amenities')) {
      return Icons.local_attraction;
    } else if (text.toLowerCase().contains('boundaries')) {
      return Icons.layers;
    }
    return Icons.tune;
  }
}
