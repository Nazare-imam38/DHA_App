import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'cached_asset_image.dart';
import 'app_icons.dart';

class NavigationAdBanner extends StatefulWidget {
  final String imagePath;
  final Duration autoDismissDuration;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NavigationAdBanner({
    super.key,
    required this.imagePath,
    this.autoDismissDuration = const Duration(seconds: 3),
    this.onTap,
    this.onDismiss,
  });

  @override
  State<NavigationAdBanner> createState() => _NavigationAdBannerState();
}

class _NavigationAdBannerState extends State<NavigationAdBanner>
    with SingleTickerProviderStateMixin {
  bool _isVisible = true;
  Timer? _dismissTimer;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
    _startDismissTimer();
  }

  void _startDismissTimer() {
    _dismissTimer?.cancel();
    _dismissTimer = Timer(widget.autoDismissDuration, () {
      if (mounted && _isVisible) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    if (mounted) {
      _animationController.reverse().then((_) {
        if (mounted) {
          setState(() {
            _isVisible = false;
          });
          widget.onDismiss?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: 375.w,
            maxHeight: 400.h,
          ),
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Ad Image
              GestureDetector(
                onTap: () {
                  _dismissTimer?.cancel();
                  widget.onTap?.call();
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: CachedAssetImage(
                    assetPath: widget.imagePath,
                    width: 375.w,
                    height: 400.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              // Close Button
              Positioned(
                top: 8.h,
                right: 8.w,
                child: GestureDetector(
                  onTap: () {
                    _dismissTimer?.cancel();
                    _dismiss();
                  },
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      AppIcons.close,
                      color: Colors.white,
                      size: 20.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

