import 'package:flutter/material.dart';
import '../../../core/responsive/responsive_breakpoints.dart';
import '../../../core/responsive/responsive_helper.dart';

/// Responsive container that adapts to different screen sizes
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? mobileSmallWidth;
  final double? mobileWidth;
  final double? mobileLargeWidth;
  final double? tabletWidth;
  final double? desktopWidth;
  final EdgeInsets? mobileSmallPadding;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? mobileLargePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;
  final EdgeInsets? mobileSmallMargin;
  final EdgeInsets? mobileMargin;
  final EdgeInsets? mobileLargeMargin;
  final EdgeInsets? tabletMargin;
  final EdgeInsets? desktopMargin;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final BoxConstraints? constraints;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.mobileSmallWidth,
    this.mobileWidth,
    this.mobileLargeWidth,
    this.tabletWidth,
    this.desktopWidth,
    this.mobileSmallPadding,
    this.mobilePadding,
    this.mobileLargePadding,
    this.tabletPadding,
    this.desktopPadding,
    this.mobileSmallMargin,
    this.mobileMargin,
    this.mobileLargeMargin,
    this.tabletMargin,
    this.desktopMargin,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Get responsive width
    final width = ResponsiveBreakpoints.getResponsiveValue<double>(
      context,
      mobileSmall: mobileSmallWidth ?? mobileWidth ?? 0.95,
      mobile: mobileWidth ?? 0.9,
      mobileLarge: mobileLargeWidth ?? mobileWidth ?? 0.85,
      tablet: tabletWidth ?? 0.8,
      desktop: desktopWidth ?? 0.7,
    ) * screenWidth;

    // Get responsive padding
    final padding = ResponsiveBreakpoints.getResponsiveValue<EdgeInsets>(
      context,
      mobileSmall: mobileSmallPadding ?? mobilePadding ?? const EdgeInsets.all(8),
      mobile: mobilePadding ?? const EdgeInsets.all(12),
      mobileLarge: mobileLargePadding ?? mobilePadding ?? const EdgeInsets.all(16),
      tablet: tabletPadding ?? const EdgeInsets.all(20),
      desktop: desktopPadding ?? const EdgeInsets.all(24),
    );

    // Get responsive margin
    final margin = ResponsiveBreakpoints.getResponsiveValue<EdgeInsets>(
      context,
      mobileSmall: mobileSmallMargin ?? mobileMargin ?? EdgeInsets.zero,
      mobile: mobileMargin ?? EdgeInsets.zero,
      mobileLarge: mobileLargeMargin ?? mobileMargin ?? EdgeInsets.zero,
      tablet: tabletMargin ?? EdgeInsets.zero,
      desktop: desktopMargin ?? EdgeInsets.zero,
    );

    // Get responsive border radius
    final borderRadius = this.borderRadius ?? 
        BorderRadius.circular(ResponsiveHelper.getResponsiveBorderRadius(context));

    return Container(
      width: width,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        boxShadow: boxShadow,
        border: border,
      ),
      constraints: constraints,
      child: child,
    );
  }
}

/// Responsive padding widget
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobileSmallPadding;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? mobileLargePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobileSmallPadding,
    this.mobilePadding,
    this.mobileLargePadding,
    this.tabletPadding,
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveBreakpoints.getResponsiveValue<EdgeInsets>(
      context,
      mobileSmall: mobileSmallPadding ?? mobilePadding ?? const EdgeInsets.all(8),
      mobile: mobilePadding ?? const EdgeInsets.all(12),
      mobileLarge: mobileLargePadding ?? mobilePadding ?? const EdgeInsets.all(16),
      tablet: tabletPadding ?? const EdgeInsets.all(20),
      desktop: desktopPadding ?? const EdgeInsets.all(24),
    );

    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// Responsive margin widget
class ResponsiveMargin extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobileSmallMargin;
  final EdgeInsets? mobileMargin;
  final EdgeInsets? mobileLargeMargin;
  final EdgeInsets? tabletMargin;
  final EdgeInsets? desktopMargin;

  const ResponsiveMargin({
    super.key,
    required this.child,
    this.mobileSmallMargin,
    this.mobileMargin,
    this.mobileLargeMargin,
    this.tabletMargin,
    this.desktopMargin,
  });

  @override
  Widget build(BuildContext context) {
    final margin = ResponsiveBreakpoints.getResponsiveValue<EdgeInsets>(
      context,
      mobileSmall: mobileSmallMargin ?? mobileMargin ?? EdgeInsets.zero,
      mobile: mobileMargin ?? EdgeInsets.zero,
      mobileLarge: mobileLargeMargin ?? mobileMargin ?? EdgeInsets.zero,
      tablet: tabletMargin ?? EdgeInsets.zero,
      desktop: desktopMargin ?? EdgeInsets.zero,
    );

    return Container(
      margin: margin,
      child: child,
    );
  }
}
