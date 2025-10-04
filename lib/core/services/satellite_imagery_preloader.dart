import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'unified_cache_manager.dart';

/// Satellite Imagery Preloader
/// Preloads ArcGIS satellite tiles during splash screen for instant map performance
class SatelliteImageryPreloader {
  static bool _isPreloading = false;
  static bool _isPreloaded = false;
  static final Map<String, dynamic> _preloadStatus = {};
  
  // Progress tracking
  static double _currentProgress = 0.0;
  static String _currentMessage = 'Loading satellite imagery...';
  static final StreamController<PreloadProgress> _progressController = 
      StreamController<PreloadProgress>.broadcast();
  
  // DHA area configuration
  static const LatLng _dhaCenter = LatLng(33.5227, 73.0951);
  static const double _dhaRadius = 0.05; // ~5km radius around DHA
  static const List<int> _essentialZoomLevels = [12, 13, 14, 15, 16];
  static const int _tilesPerZoom = 9; // 3x3 grid per zoom level
  
  // ArcGIS satellite tile configuration
  static const String _arcgisBaseUrl = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile';
  static const int _tileSize = 256;
  static const Duration _tileTimeout = Duration(seconds: 5);
  
  /// Start satellite imagery preloading
  static Future<void> startPreloading() async {
    if (_isPreloading || _isPreloaded) return;
    
    _isPreloading = true;
    _currentProgress = 0.0;
    _currentMessage = 'Starting satellite imagery preload...';
    
    print('🛰️ SatelliteImageryPreloader: Starting satellite imagery preloading...');
    
    try {
      // Initialize cache manager
      await _updateProgress(0.0, 'Initializing cache...');
      await UnifiedCacheManager.instance.initialize();
      
      // Preload tiles for each zoom level
      int totalTiles = _essentialZoomLevels.length * _tilesPerZoom;
      int loadedTiles = 0;
      
      for (final zoom in _essentialZoomLevels) {
        await _updateProgress(
          (loadedTiles / totalTiles) * 100, 
          'Loading zoom level $zoom...'
        );
        
        final tilesLoaded = await _preloadTilesForZoom(zoom);
        loadedTiles += tilesLoaded;
        
        print('✅ Preloaded $tilesLoaded tiles for zoom level $zoom');
      }
      
      _isPreloaded = true;
      await _updateProgress(100.0, 'Satellite imagery ready!');
      
      print('🛰️ SatelliteImageryPreloader: ✅ ALL SATELLITE TILES PRELOADED');
      _printPreloadSummary();
      
    } catch (e) {
      print('❌ SatelliteImageryPreloader: Error during preloading: $e');
      await _updateProgress(_currentProgress, 'Error occurred, continuing...');
    } finally {
      _isPreloading = false;
    }
  }
  
  /// Preload tiles for a specific zoom level
  static Future<int> _preloadTilesForZoom(int zoom) async {
    int tilesLoaded = 0;
    
    // Calculate center tile coordinates
    final centerTile = _calculateTileCoordinates(_dhaCenter, zoom);
    
    // Preload 3x3 grid around center
    for (int x = centerTile['x']! - 1; x <= centerTile['x']! + 1; x++) {
      for (int y = centerTile['y']! - 1; y <= centerTile['y']! + 1; y++) {
        try {
          await _preloadSingleTile(zoom, x, y);
          tilesLoaded++;
        } catch (e) {
          print('❌ Failed to preload tile z:$zoom x:$x y:$y: $e');
        }
      }
    }
    
    return tilesLoaded;
  }
  
  /// Preload a single satellite tile
  static Future<void> _preloadSingleTile(int z, int x, int y) async {
    final tileUrl = '$_arcgisBaseUrl/$z/$y/$x';
    final cacheKey = 'satellite_tile_${z}_${x}_${y}';
    
    // Check if already cached
    final cached = await UnifiedCacheManager.instance.get<Uint8List>(cacheKey);
    if (cached != null) {
      return; // Already cached
    }
    
    try {
      // Download tile
      final response = await http.get(
        Uri.parse(tileUrl),
        headers: {
          'User-Agent': 'DHA-Marketplace/1.0',
          'Accept': 'image/png,image/jpeg,image/webp,*/*',
        },
      ).timeout(_tileTimeout);
      
      if (response.statusCode == 200) {
        // Cache the tile data
        await UnifiedCacheManager.instance.put(
          cacheKey, 
          response.bodyBytes,
          ttl: const Duration(hours: 24), // Cache for 24 hours
          preferredLevel: CacheLevel.memory,
        );
        
        print('✅ Cached satellite tile z:$z x:$x y:$y');
      } else {
        print('❌ Failed to download tile z:$z x:$x y:$y: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error downloading tile z:$z x:$x y:$y: $e');
    }
  }
  
  /// Calculate tile coordinates for a point using Web Mercator projection
  static Map<String, int> _calculateTileCoordinates(LatLng point, int zoom) {
    final n = 1 << zoom;
    
    // Longitude to X
    final x = ((point.longitude + 180) / 360 * n).floor();
    
    // Latitude to Y (Web Mercator formula)
    final latRad = _radians(point.latitude);
    final y = ((1 - (math.log(math.tan(math.pi / 4 + latRad / 2)) / math.pi)) / 2 * n).floor();
    
    return {'x': x, 'y': y};
  }
  
  /// Convert degrees to radians
  static double _radians(double degrees) => degrees * (math.pi / 180);
  
  /// Update progress and notify listeners
  static Future<void> _updateProgress(double progress, String message) async {
    _currentProgress = progress;
    _currentMessage = message;
    
    _progressController.add(PreloadProgress(
      progress: progress,
      message: message,
      isComplete: progress >= 100.0,
    ));
    
    print('📊 Satellite Progress: ${progress.toStringAsFixed(1)}% - $message');
  }
  
  /// Print preload summary
  static void _printPreloadSummary() {
    print('🛰️ ===== SATELLITE IMAGERY PRELOAD SUMMARY =====');
    print('🛰️ Zoom levels: ${_essentialZoomLevels.join(', ')}');
    print('🛰️ Tiles per zoom: $_tilesPerZoom');
    print('🛰️ Total tiles: ${_essentialZoomLevels.length * _tilesPerZoom}');
    print('🛰️ DHA Center: $_dhaCenter');
    print('🛰️ =============================================');
  }
  
  /// Get current progress
  static double get currentProgress => _currentProgress;
  
  /// Get current message
  static String get currentMessage => _currentMessage;
  
  /// Get progress stream
  static Stream<PreloadProgress> get progressStream => _progressController.stream;
  
  /// Check if preloading is complete
  static bool get isPreloaded => _isPreloaded;
  
  /// Check if preloading is in progress
  static bool get isPreloading => _isPreloading;
  
  /// Get preload status
  static Map<String, dynamic> getPreloadStatus() {
    return {
      'is_preloaded': _isPreloaded,
      'is_preloading': _isPreloading,
      'current_progress': _currentProgress,
      'current_message': _currentMessage,
      'zoom_levels': _essentialZoomLevels,
      'tiles_per_zoom': _tilesPerZoom,
    };
  }
  
  /// Dispose resources
  static void dispose() {
    _progressController.close();
  }
}

/// Progress data class for satellite imagery preloading
class PreloadProgress {
  final double progress;
  final String message;
  final bool isComplete;
  
  PreloadProgress({
    required this.progress,
    required this.message,
    required this.isComplete,
  });
}
