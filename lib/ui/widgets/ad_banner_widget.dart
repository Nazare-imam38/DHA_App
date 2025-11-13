import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'cached_asset_image.dart';
import 'app_icons.dart';

class AdBannerWidget extends StatefulWidget {
  final String imagePath;
  final Duration autoDismissDuration;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const AdBannerWidget({
    super.key,
    required this.imagePath,
    this.autoDismissDuration = const Duration(seconds: 3),
    this.onTap,
    this.onDismiss,
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  bool _isVisible = true;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    // Start auto-dismiss timer
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
      setState(() {
        _isVisible = false;
      });
      widget.onDismiss?.call();
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) {
      return const SizedBox.shrink();
    }

    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
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
                borderRadius: BorderRadius.circular(12.r),
                child: CachedAssetImage(
                  assetPath: widget.imagePath,
                  width: double.infinity,
                  height: 80.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Close Button
            Positioned(
              top: 4.h,
              right: 4.w,
              child: GestureDetector(
                onTap: () {
                  _dismissTimer?.cancel();
                  _dismiss();
                },
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.close,
                    color: Colors.white,
                    size: 16.w,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

