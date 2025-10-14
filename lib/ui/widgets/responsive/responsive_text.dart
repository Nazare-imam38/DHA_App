import 'package:flutter/material.dart';
import '../../../core/responsive/responsive_breakpoints.dart';
import '../../../core/responsive/responsive_helper.dart';

/// Responsive text widget that adapts font size and styling based on screen size
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? mobileSmallStyle;
  final TextStyle? mobileStyle;
  final TextStyle? mobileLargeStyle;
  final TextStyle? tabletStyle;
  final TextStyle? desktopStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? mobileSmallFontSize;
  final double? mobileFontSize;
  final double? mobileLargeFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final String? fontFamily;
  final double? height;
  final double? letterSpacing;

  const ResponsiveText(
    this.text, {
    super.key,
    this.mobileSmallStyle,
    this.mobileStyle,
    this.mobileLargeStyle,
    this.tabletStyle,
    this.desktopStyle,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.mobileSmallFontSize,
    this.mobileFontSize,
    this.mobileLargeFontSize,
    this.tabletFontSize,
    this.desktopFontSize,
    this.fontWeight,
    this.color,
    this.fontFamily,
    this.height,
    this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = ResponsiveBreakpoints.getResponsiveValue<double>(
      context,
      mobileSmall: mobileSmallFontSize ?? mobileFontSize ?? 12,
      mobile: mobileFontSize ?? 14,
      mobileLarge: mobileLargeFontSize ?? mobileFontSize ?? 16,
      tablet: tabletFontSize ?? 18,
      desktop: desktopFontSize ?? 20,
    );

    final style = ResponsiveBreakpoints.getResponsiveValue<TextStyle>(
      context,
      mobileSmall: mobileSmallStyle ?? _createTextStyle(fontSize),
      mobile: mobileStyle ?? _createTextStyle(fontSize),
      mobileLarge: mobileLargeStyle ?? _createTextStyle(fontSize),
      tablet: tabletStyle ?? _createTextStyle(fontSize),
      desktop: desktopStyle ?? _createTextStyle(fontSize),
    );

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  TextStyle _createTextStyle(double fontSize) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: fontFamily,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}

/// Responsive heading widget
class ResponsiveHeading extends StatelessWidget {
  final String text;
  final int level; // 1-6 for h1-h6
  final TextAlign? textAlign;
  final Color? color;
  final String? fontFamily;

  const ResponsiveHeading(
    this.text, {
    super.key,
    this.level = 1,
    this.textAlign,
    this.color,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = _getFontSizeForLevel(context, level);
    final fontWeight = _getFontWeightForLevel(level);

    return ResponsiveText(
      text,
      mobileSmallFontSize: fontSize * 0.8,
      mobileFontSize: fontSize * 0.9,
      mobileLargeFontSize: fontSize,
      tabletFontSize: fontSize * 1.1,
      desktopFontSize: fontSize * 1.2,
      fontWeight: fontWeight,
      color: color,
      fontFamily: fontFamily,
      textAlign: textAlign,
    );
  }

  double _getFontSizeForLevel(BuildContext context, int level) {
    final baseFontSize = ResponsiveHelper.getResponsiveFontSize(context);
    
    switch (level) {
      case 1: return baseFontSize * 2.5; // h1
      case 2: return baseFontSize * 2.0; // h2
      case 3: return baseFontSize * 1.75; // h3
      case 4: return baseFontSize * 1.5; // h4
      case 5: return baseFontSize * 1.25; // h5
      case 6: return baseFontSize * 1.0; // h6
      default: return baseFontSize * 2.5;
    }
  }

  FontWeight _getFontWeightForLevel(int level) {
    switch (level) {
      case 1: return FontWeight.w900;
      case 2: return FontWeight.w800;
      case 3: return FontWeight.w700;
      case 4: return FontWeight.w600;
      case 5: return FontWeight.w500;
      case 6: return FontWeight.w400;
      default: return FontWeight.w900;
    }
  }
}

/// Responsive body text widget
class ResponsiveBodyText extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;
  final String? fontFamily;
  final double? height;

  const ResponsiveBodyText(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.fontFamily,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveText(
      text,
      mobileSmallFontSize: 12,
      mobileFontSize: 14,
      mobileLargeFontSize: 16,
      tabletFontSize: 18,
      desktopFontSize: 20,
      fontWeight: FontWeight.w400,
      color: color,
      fontFamily: fontFamily,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      height: height,
    );
  }
}

/// Responsive caption text widget
class ResponsiveCaption extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;
  final String? fontFamily;

  const ResponsiveCaption(
    this.text, {
    super.key,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveText(
      text,
      mobileSmallFontSize: 10,
      mobileFontSize: 12,
      mobileLargeFontSize: 14,
      tabletFontSize: 16,
      desktopFontSize: 18,
      fontWeight: FontWeight.w400,
      color: color,
      fontFamily: fontFamily,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
