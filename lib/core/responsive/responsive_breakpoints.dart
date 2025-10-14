import 'package:flutter/material.dart';

/// Responsive breakpoints for different device types
class ResponsiveBreakpoints {
  // Device size breakpoints
  static const double mobileSmall = 320;   // iPhone SE, small phones
  static const double mobile = 480;        // Standard mobile phones
  static const double mobileLarge = 600;   // Large phones (iPhone Pro Max)
  static const double tablet = 768;        // Tablets (iPad)
  static const double tabletLarge = 1024;  // Large tablets (iPad Pro)
  static const double desktop = 1440;      // Desktop screens
  static const double desktopLarge = 1920; // Large desktop screens

  // Foldable device breakpoints
  static const double foldClosed = 600;    // Folded state
  static const double foldOpen = 1024;     // Unfolded state

  /// Check if current screen is mobile (small to large phones)
  static bool isMobile(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < tablet;
  }

  /// Check if current screen is small mobile
  static bool isMobileSmall(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < mobile;
  }

  /// Check if current screen is large mobile
  static bool isMobileLarge(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < tablet;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tablet && width < desktop;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= desktop;
  }

  /// Check if current screen is foldable in closed state
  static bool isFoldClosed(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < foldClosed;
  }

  /// Check if current screen is foldable in open state
  static bool isFoldOpen(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= foldOpen;
  }

  /// Get current device type as string
  static String getDeviceType(BuildContext context) {
    if (isMobileSmall(context)) return 'mobile_small';
    if (isMobileLarge(context)) return 'mobile_large';
    if (isTablet(context)) return 'tablet';
    if (isDesktop(context)) return 'desktop';
    return 'mobile';
  }

  /// Get responsive value based on screen size
  static T getResponsiveValue<T>(BuildContext context, {
    T? mobileSmall,
    T? mobile,
    T? mobileLarge,
    T? tablet,
    T? desktop,
  }) {
    if (isMobileSmall(context)) return mobileSmall ?? mobile ?? tablet ?? desktop!;
    if (isMobileLarge(context)) return mobileLarge ?? mobile ?? tablet ?? desktop!;
    if (isTablet(context)) return tablet ?? desktop ?? mobile!;
    if (isDesktop(context)) return desktop ?? tablet ?? mobile!;
    return mobile ?? tablet ?? desktop!;
  }
}
