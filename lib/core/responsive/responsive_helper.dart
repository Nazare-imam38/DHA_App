import 'package:flutter/material.dart';
import 'responsive_breakpoints.dart';

/// Helper class for responsive design utilities
class ResponsiveHelper {
  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return ResponsiveBreakpoints.getResponsiveValue<EdgeInsets>(
      context,
      mobileSmall: const EdgeInsets.all(8),
      mobile: const EdgeInsets.all(12),
      mobileLarge: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(20),
      desktop: const EdgeInsets.all(24),
    );
  }

  /// Get responsive horizontal padding
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    return ResponsiveBreakpoints.getResponsiveValue<EdgeInsets>(
      context,
      mobileSmall: const EdgeInsets.symmetric(horizontal: 8),
      mobile: const EdgeInsets.symmetric(horizontal: 12),
      mobileLarge: const EdgeInsets.symmetric(horizontal: 16),
      tablet: const EdgeInsets.symmetric(horizontal: 20),
      desktop: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  /// Get responsive vertical padding
  static EdgeInsets getResponsiveVerticalPadding(BuildContext context) {
    return ResponsiveBreakpoints.getResponsiveValue<EdgeInsets>(
      context,
      mobileSmall: const EdgeInsets.symmetric(vertical: 8),
      mobile: const EdgeInsets.symmetric(vertical: 12),
      mobileLarge: const EdgeInsets.symmetric(vertical: 16),
      tablet: const EdgeInsets.symmetric(vertical: 20),
      desktop: const EdgeInsets.symmetric(vertical: 24),
    );
  }

  /// Get responsive margin
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    return ResponsiveBreakpoints.getResponsiveValue<EdgeInsets>(
      context,
      mobileSmall: const EdgeInsets.all(4),
      mobile: const EdgeInsets.all(8),
      mobileLarge: const EdgeInsets.all(12),
      tablet: const EdgeInsets.all(16),
      desktop: const EdgeInsets.all(20),
    );
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, {
    double? mobileSmall,
    double? mobile,
    double? mobileLarge,
    double? tablet,
    double? desktop,
  }) {
    return ResponsiveBreakpoints.getResponsiveValue<double>(
      context,
      mobileSmall: mobileSmall ?? mobile ?? 12,
      mobile: mobile ?? 14,
      mobileLarge: mobileLarge ?? mobile ?? 16,
      tablet: tablet ?? 18,
      desktop: desktop ?? 20,
    );
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, {
    double? mobileSmall,
    double? mobile,
    double? mobileLarge,
    double? tablet,
    double? desktop,
  }) {
    return ResponsiveBreakpoints.getResponsiveValue<double>(
      context,
      mobileSmall: mobileSmall ?? mobile ?? 16,
      mobile: mobile ?? 20,
      mobileLarge: mobileLarge ?? mobile ?? 24,
      tablet: tablet ?? 28,
      desktop: desktop ?? 32,
    );
  }

  /// Get responsive width as percentage of screen width
  static double getResponsiveWidth(BuildContext context, {
    double? mobileSmall,
    double? mobile,
    double? mobileLarge,
    double? tablet,
    double? desktop,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final widthPercentage = ResponsiveBreakpoints.getResponsiveValue<double>(
      context,
      mobileSmall: mobileSmall ?? mobile ?? 0.95,
      mobile: mobile ?? 0.9,
      mobileLarge: mobileLarge ?? mobile ?? 0.85,
      tablet: tablet ?? 0.8,
      desktop: desktop ?? 0.7,
    );
    return screenWidth * widthPercentage;
  }

  /// Get responsive height as percentage of screen height
  static double getResponsiveHeight(BuildContext context, {
    double? mobileSmall,
    double? mobile,
    double? mobileLarge,
    double? tablet,
    double? desktop,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final heightPercentage = ResponsiveBreakpoints.getResponsiveValue<double>(
      context,
      mobileSmall: mobileSmall ?? mobile ?? 0.3,
      mobile: mobile ?? 0.4,
      mobileLarge: mobileLarge ?? mobile ?? 0.5,
      tablet: tablet ?? 0.6,
      desktop: desktop ?? 0.7,
    );
    return screenHeight * heightPercentage;
  }

  /// Get responsive grid columns
  static int getResponsiveColumns(BuildContext context) {
    return ResponsiveBreakpoints.getResponsiveValue<int>(
      context,
      mobileSmall: 1,
      mobile: 1,
      mobileLarge: 2,
      tablet: 3,
      desktop: 4,
    );
  }

  /// Get responsive card width
  static double getResponsiveCardWidth(BuildContext context) {
    return ResponsiveBreakpoints.getResponsiveValue<double>(
      context,
      mobileSmall: 140,
      mobile: 160,
      mobileLarge: 180,
      tablet: 200,
      desktop: 220,
    );
  }

  /// Get responsive card height
  static double getResponsiveCardHeight(BuildContext context) {
    return ResponsiveBreakpoints.getResponsiveValue<double>(
      context,
      mobileSmall: 120,
      mobile: 140,
      mobileLarge: 160,
      tablet: 180,
      desktop: 200,
    );
  }

  /// Get responsive border radius
  static double getResponsiveBorderRadius(BuildContext context) {
    return ResponsiveBreakpoints.getResponsiveValue<double>(
      context,
      mobileSmall: 8,
      mobile: 12,
      mobileLarge: 16,
      tablet: 20,
      desktop: 24,
    );
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context) {
    return ResponsiveBreakpoints.getResponsiveValue<double>(
      context,
      mobileSmall: 4,
      mobile: 8,
      mobileLarge: 12,
      tablet: 16,
      desktop: 20,
    );
  }

  /// Check if device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait orientation
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get responsive container constraints
  static BoxConstraints getResponsiveConstraints(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return ResponsiveBreakpoints.getResponsiveValue<BoxConstraints>(
      context,
      mobileSmall: BoxConstraints(
        maxWidth: screenWidth * 0.95,
        maxHeight: screenHeight * 0.8,
      ),
      mobile: BoxConstraints(
        maxWidth: screenWidth * 0.9,
        maxHeight: screenHeight * 0.85,
      ),
      mobileLarge: BoxConstraints(
        maxWidth: screenWidth * 0.85,
        maxHeight: screenHeight * 0.9,
      ),
      tablet: BoxConstraints(
        maxWidth: screenWidth * 0.8,
        maxHeight: screenHeight * 0.9,
      ),
      desktop: BoxConstraints(
        maxWidth: screenWidth * 0.7,
        maxHeight: screenHeight * 0.9,
      ),
    );
  }
}
