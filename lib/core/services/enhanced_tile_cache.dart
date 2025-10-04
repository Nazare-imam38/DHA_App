import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'unified_cache_manager.dart';

/// Enhanced Tile Cache for Satellite Imagery
/// Provides intelligent caching and preloading for ArcGIS satellite tiles
class EnhancedTileCache {
  static EnhancedTileCache? _instance;
  static EnhancedTileCache get instance => _instance ??= EnhancedTileCache._();
  
  EnhancedTileCache._();
  
  // Cache configuration
  static const String _cachePrefix = 'satellite_tile_';
  static const Duration _tileTTL = Duration(hours: 24);
  static const int _maxCacheSize = 100; // Maximum number of tiles to cache
  
  // ArcGIS satellite tile configuration
  static const String _arcgisBaseUrl = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile';
  static const int _tileSize = 256;
  
  /// Get satellite tile with intelligent caching
  static Future<Uint8List?> getSatelliteTile(int z, int x, int y) async {
    final cacheKey = '$_cachePrefix${z}_${x}_${y}';
    
    try {
      // Try to get from cache first
      final cachedTile = await UnifiedCacheManager.instance.get<Uint8List>(cacheKey);
      if (cachedTile != null) {
        print('✅ Cache hit for satellite tile z:$z x:$x y:$y');
        return cachedTile;
      }
      
      // If not in cache, download and cache it
      print('🌐 Downloading satellite tile z:$z x:$x y:$y');
      final tileData = await _downloadTile(z, x, y);
      
      if (tileData != null) {
        // Cache the tile
        await UnifiedCacheManager.instance.put(
          cacheKey,
          tileData,
          ttl: _tileTTL,
          preferredLevel: CacheLevel.memory,
        );
        print('✅ Cached satellite tile z:$z x:$x y:$y');
        return tileData;
      }
      
      return null;
    } catch (e) {
      print('❌ Error getting satellite tile z:$z x:$x y:$y: $e');
      return null;
    }
  }
  
  /// Download satellite tile from ArcGIS
  static Future<Uint8List?> _downloadTile(int z, int x, int y) async {
    try {
      final url = '$_arcgisBaseUrl/$z/$y/$x';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'DHA-Marketplace/1.0',
          'Accept': 'image/png,image/jpeg,image/webp,*/*',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        print('❌ Failed to download tile: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error downloading tile: $e');
      return null;
    }
  }
  
  /// Preload tiles for a specific area and zoom levels
  static Future<void> preloadTilesForArea({
    required LatLng center,
    required double radius,
    required List<int> zoomLevels,
  }) async {
    print('🛰️ Preloading satellite tiles for area around $center');
    
    for (final zoom in zoomLevels) {
      final centerTile = _calculateTileCoordinates(center, zoom);
      final tilesToPreload = _calculateTilesInRadius(center, radius, zoom);
      
      print('🛰️ Preloading ${tilesToPreload.length} tiles for zoom $zoom');
      
      for (final tile in tilesToPreload) {
        try {
          await getSatelliteTile(zoom, tile['x']!, tile['y']!);
        } catch (e) {
          print('❌ Failed to preload tile z:$zoom x:${tile['x']} y:${tile['y']}: $e');
        }
      }
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
  
  /// Calculate tiles within a radius of a center point
  static List<Map<String, int>> _calculateTilesInRadius(LatLng center, double radius, int zoom) {
    final tiles = <Map<String, int>>[];
    final centerTile = _calculateTileCoordinates(center, zoom);
    
    // Calculate how many tiles to cover the radius
    final tilesPerDegree = 1 << zoom;
    final tilesPerRadius = (radius * tilesPerDegree / 111.32).ceil(); // Approximate conversion
    
    // Create a grid of tiles around the center
    for (int x = centerTile['x']! - tilesPerRadius; x <= centerTile['x']! + tilesPerRadius; x++) {
      for (int y = centerTile['y']! - tilesPerRadius; y <= centerTile['y']! + tilesPerRadius; y++) {
        tiles.add({'x': x, 'y': y});
      }
    }
    
    return tiles;
  }
  
  /// Convert degrees to radians
  static double _radians(double degrees) => degrees * (math.pi / 180);
  
  /// Clear all cached tiles
  static Future<void> clearCache() async {
    await UnifiedCacheManager.instance.clear(_cachePrefix);
    print('🗑️ Cleared satellite tile cache');
  }
  
  /// Get cache statistics
  static Map<String, dynamic> getCacheStatistics() {
    return UnifiedCacheManager.instance.getStatistics();
  }
}

