import 'package:flutter/material.dart';

/// A widget that provides optimized caching for asset images
/// This widget uses Flutter's built-in image cache for better performance and memory management
class CachedAssetImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget Function(BuildContext, Object, StackTrace?)? errorBuilder;
  final Widget Function(BuildContext, String, dynamic)? placeholder;
  final Color? color;
  final BlendMode? colorBlendMode;
  final Alignment alignment;
  final ImageRepeat repeat;
  final bool matchTextDirection;
  final bool gaplessPlayback;
  final bool isAntiAlias;
  final FilterQuality filterQuality;

  const CachedAssetImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorBuilder,
    this.placeholder,
    this.color,
    this.colorBlendMode,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.gaplessPlayback = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.low,
  });

  @override
  Widget build(BuildContext context) {
    // Use a simple Image widget with AssetImage for better performance
    // The caching is handled by Flutter's image cache automatically
    return Image(
      image: AssetImage(assetPath),
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      alignment: alignment,
      repeat: repeat,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      filterQuality: filterQuality,
      errorBuilder: errorBuilder ?? (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Icon(
          Icons.error_outline,
          color: Colors.grey,
          size: 24,
        ),
      ),
    );
  }
}

/// A specialized widget for background images with optimized caching
class CachedAssetBackgroundImage extends StatelessWidget {
  final String assetPath;
  final Widget child;
  final BoxFit fit;
  final Alignment alignment;
  final ImageRepeat repeat;

  const CachedAssetBackgroundImage({
    super.key,
    required this.assetPath,
    required this.child,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(assetPath),
          fit: fit,
          alignment: alignment,
          repeat: repeat,
        ),
      ),
      child: child,
    );
  }
}

