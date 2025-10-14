import 'package:flutter/material.dart';
import '../../../core/responsive/responsive_breakpoints.dart';
import '../../../core/responsive/responsive_helper.dart';

/// Responsive grid widget that adapts columns based on screen size
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double? mobileSmallSpacing;
  final double? mobileSpacing;
  final double? mobileLargeSpacing;
  final double? tabletSpacing;
  final double? desktopSpacing;
  final double? mobileSmallRunSpacing;
  final double? mobileRunSpacing;
  final double? mobileLargeRunSpacing;
  final double? tabletRunSpacing;
  final double? desktopRunSpacing;
  final double? mobileSmallChildAspectRatio;
  final double? mobileChildAspectRatio;
  final double? mobileLargeChildAspectRatio;
  final double? tabletChildAspectRatio;
  final double? desktopChildAspectRatio;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.mobileSmallSpacing,
    this.mobileSpacing,
    this.mobileLargeSpacing,
    this.tabletSpacing,
    this.desktopSpacing,
    this.mobileSmallRunSpacing,
    this.mobileRunSpacing,
    this.mobileLargeRunSpacing,
    this.tabletRunSpacing,
    this.desktopRunSpacing,
    this.mobileSmallChildAspectRatio,
    this.mobileChildAspectRatio,
    this.mobileLargeChildAspectRatio,
    this.tabletChildAspectRatio,
    this.desktopChildAspectRatio,
    this.shrinkWrap = true,
    this.physics,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveHelper.getResponsiveColumns(context);
    
    final crossAxisSpacing = ResponsiveBreakpoints.getResponsiveValue<double>(
      context,
      mobileSmall: mobileSmallSpacing ?? mobileSpacing ?? 8,
      mobile: mobileSpacing ?? 12,
      mobileLarge: mobileLargeSpacing ?? mobileSpacing ?? 16,
      tablet: tabletSpacing ?? 20,
      desktop: desktopSpacing ?? 24,
    );

    final mainAxisSpacing = ResponsiveBreakpoints.getResponsiveValue<double>(
      context,
      mobileSmall: mobileSmallRunSpacing ?? mobileRunSpacing ?? 8,
      mobile: mobileRunSpacing ?? 12,
      mobileLarge: mobileLargeRunSpacing ?? mobileRunSpacing ?? 16,
      tablet: tabletRunSpacing ?? 20,
      desktop: desktopRunSpacing ?? 24,
    );

    final childAspectRatio = ResponsiveBreakpoints.getResponsiveValue<double>(
      context,
      mobileSmall: mobileSmallChildAspectRatio ?? mobileChildAspectRatio ?? 1.2,
      mobile: mobileChildAspectRatio ?? 1.0,
      mobileLarge: mobileLargeChildAspectRatio ?? mobileChildAspectRatio ?? 0.9,
      tablet: tabletChildAspectRatio ?? 0.8,
      desktop: desktopChildAspectRatio ?? 0.7,
    );

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Responsive list view widget
class ResponsiveListView extends StatelessWidget {
  final List<Widget> children;
  final ScrollDirection scrollDirection;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;
  final double? mobileSmallSpacing;
  final double? mobileSpacing;
  final double? mobileLargeSpacing;
  final double? tabletSpacing;
  final double? desktopSpacing;

  const ResponsiveListView({
    super.key,
    required this.children,
    this.scrollDirection = ScrollDirection.vertical,
    this.shrinkWrap = true,
    this.physics,
    this.padding,
    this.mobileSmallSpacing,
    this.mobileSpacing,
    this.mobileLargeSpacing,
    this.tabletSpacing,
    this.desktopSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveBreakpoints.getResponsiveValue<double>(
      context,
      mobileSmall: mobileSmallSpacing ?? mobileSpacing ?? 8,
      mobile: mobileSpacing ?? 12,
      mobileLarge: mobileLargeSpacing ?? mobileSpacing ?? 16,
      tablet: tabletSpacing ?? 20,
      desktop: desktopSpacing ?? 24,
    );

    return ListView.separated(
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding,
      itemCount: children.length,
      separatorBuilder: (context, index) => SizedBox(
        width: scrollDirection == ScrollDirection.horizontal ? spacing : 0,
        height: scrollDirection == ScrollDirection.vertical ? spacing : 0,
      ),
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// Responsive horizontal list view
class ResponsiveHorizontalList extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final double? mobileSmallSpacing;
  final double? mobileSpacing;
  final double? mobileLargeSpacing;
  final double? tabletSpacing;
  final double? desktopSpacing;
  final double? mobileSmallItemWidth;
  final double? mobileItemWidth;
  final double? mobileLargeItemWidth;
  final double? tabletItemWidth;
  final double? desktopItemWidth;

  const ResponsiveHorizontalList({
    super.key,
    required this.children,
    this.padding,
    this.mobileSmallSpacing,
    this.mobileSpacing,
    this.mobileLargeSpacing,
    this.tabletSpacing,
    this.desktopSpacing,
    this.mobileSmallItemWidth,
    this.mobileItemWidth,
    this.mobileLargeItemWidth,
    this.tabletItemWidth,
    this.desktopItemWidth,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveBreakpoints.getResponsiveValue<double>(
      context,
      mobileSmall: mobileSmallSpacing ?? mobileSpacing ?? 8,
      mobile: mobileSpacing ?? 12,
      mobileLarge: mobileLargeSpacing ?? mobileSpacing ?? 16,
      tablet: tabletSpacing ?? 20,
      desktop: desktopSpacing ?? 24,
    );

    final itemWidth = ResponsiveBreakpoints.getResponsiveValue<double>(
      context,
      mobileSmall: mobileSmallItemWidth ?? mobileItemWidth ?? 140,
      mobile: mobileItemWidth ?? 160,
      mobileLarge: mobileLargeItemWidth ?? mobileItemWidth ?? 180,
      tablet: tabletItemWidth ?? 200,
      desktop: desktopItemWidth ?? 220,
    );

    return SizedBox(
      height: itemWidth * 1.2, // Assuming aspect ratio of 1.2
      child: ListView.separated(
        scrollDirection: ScrollDirection.horizontal,
        padding: padding,
        itemCount: children.length,
        separatorBuilder: (context, index) => SizedBox(width: spacing),
        itemBuilder: (context, index) => SizedBox(
          width: itemWidth,
          child: children[index],
        ),
      ),
    );
  }
}

/// Responsive card grid
class ResponsiveCardGrid extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsets? padding;
  final double? mobileSmallSpacing;
  final double? mobileSpacing;
  final double? mobileLargeSpacing;
  final double? tabletSpacing;
  final double? desktopSpacing;

  const ResponsiveCardGrid({
    super.key,
    required this.children,
    this.padding,
    this.mobileSmallSpacing,
    this.mobileSpacing,
    this.mobileLargeSpacing,
    this.tabletSpacing,
    this.desktopSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveGrid(
      children: children,
      padding: padding,
      mobileSmallSpacing: mobileSmallSpacing ?? mobileSpacing ?? 8,
      mobileSpacing: mobileSpacing ?? 12,
      mobileLargeSpacing: mobileLargeSpacing ?? mobileSpacing ?? 16,
      tabletSpacing: tabletSpacing ?? 20,
      desktopSpacing: desktopSpacing ?? 24,
      mobileSmallChildAspectRatio: 1.2,
      mobileChildAspectRatio: 1.0,
      mobileLargeChildAspectRatio: 0.9,
      tabletChildAspectRatio: 0.8,
      desktopChildAspectRatio: 0.7,
    );
  }
}
