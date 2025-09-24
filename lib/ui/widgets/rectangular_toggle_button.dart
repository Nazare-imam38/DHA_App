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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        height: height ?? 40,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? (selectedColor ?? const Color(0xFF1E3C90))
              : (unselectedColor ?? Colors.grey[200]),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? (selectedColor ?? const Color(0xFF1E3C90))
                : Colors.grey[400]!,
            width: 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: (selectedColor ?? const Color(0xFF1E3C90)).withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected 
                  ? (selectedTextColor ?? Colors.white)
                  : (textColor ?? Colors.black87),
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
