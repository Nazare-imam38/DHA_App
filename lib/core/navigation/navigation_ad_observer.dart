import 'package:flutter/material.dart';
import '../../ui/widgets/navigation_ad_banner.dart';

class NavigationAdObserver extends NavigatorObserver {
  static int _navigationCount = 0;
  static bool _shouldShowAd = false;

  /// Reset navigation count (call this when app starts)
  static void reset() {
    _navigationCount = 0;
    _shouldShowAd = false;
  }

  /// Get whether ad should be shown
  static bool get shouldShowAd => _shouldShowAd;

  /// Reset ad flag after showing
  static void markAdShown() {
    _shouldShowAd = false;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _handleNavigation();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _handleNavigation();
    }
  }

  void _handleNavigation() {
    _navigationCount++;
    // Show ad on second navigation (when navigating to second screen)
    // This includes both tab switches and screen pushes
    if (_navigationCount >= 2 && !_shouldShowAd) {
      _shouldShowAd = true;
    }
  }
}

/// Widget that shows ad banner based on navigation
class NavigationAdOverlay extends StatefulWidget {
  final Widget child;
  final String adImagePath;
  final Duration autoDismissDuration;

  const NavigationAdOverlay({
    super.key,
    required this.child,
    required this.adImagePath,
    this.autoDismissDuration = const Duration(seconds: 3),
  });

  @override
  State<NavigationAdOverlay> createState() => _NavigationAdOverlayState();
}

class _NavigationAdOverlayState extends State<NavigationAdOverlay> {
  bool _showAd = false;

  @override
  void initState() {
    super.initState();
    // Check if ad should be shown
    _checkAdStatus();
  }

  void _checkAdStatus() {
    // Use a small delay to ensure navigation observer has updated
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && NavigationAdObserver.shouldShowAd) {
        setState(() {
          _showAd = true;
        });
        NavigationAdObserver.markAdShown();
      }
    });
  }

  void _onAdDismiss() {
    if (mounted) {
      setState(() {
        _showAd = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showAd)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: NavigationAdBanner(
                imagePath: widget.adImagePath,
                autoDismissDuration: widget.autoDismissDuration,
                onDismiss: _onAdDismiss,
              ),
            ),
          ),
      ],
    );
  }
}

