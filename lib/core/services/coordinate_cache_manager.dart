import 'dart:collection';
import 'package:latlong2/latlong.dart';
import '../../data/models/plot_model.dart';

/// Global coordinate cache manager for efficient memory management
/// Prevents repeated UTM coordinate conversions and manages memory usage
class CoordinateCacheManager {
  static final CoordinateCacheManager _instance = CoordinateCacheManager._internal();
  factory CoordinateCacheManager() => _instance;
  CoordinateCacheManager._internal();

  // Cache for converted coordinates
  final Map<int, List<List<LatLng>>> _coordinateCache = {};
  
  // Track cache usage for memory management
  final Queue<int> _cacheAccessOrder = Queue<int>();
  static const int _maxCacheSize = 1000; // Maximum number of plots to cache
  
  /// Get cached coordinates for a plot
  List<List<LatLng>>? getCachedCoordinates(int plotId) {
    if (_coordinateCache.containsKey(plotId)) {
      // Move to end of access queue (LRU)
      _cacheAccessOrder.remove(plotId);
      _cacheAccessOrder.add(plotId);
      return _coordinateCache[plotId];
    }
    return null;
  }
  
  /// Cache coordinates for a plot
  void cacheCoordinates(int plotId, List<List<LatLng>> coordinates) {
    // Remove oldest entries if cache is full
    while (_coordinateCache.length >= _maxCacheSize) {
      final oldestId = _cacheAccessOrder.removeFirst();
      _coordinateCache.remove(oldestId);
      print('CoordinateCacheManager: Removed oldest cache entry for plot $oldestId');
    }
    
    _coordinateCache[plotId] = coordinates;
    _cacheAccessOrder.add(plotId);
    print('CoordinateCacheManager: Cached coordinates for plot $plotId');
  }
  
  /// Pre-cache coordinates for multiple plots
  void preCacheCoordinates(List<PlotModel> plots) {
    print('CoordinateCacheManager: Pre-caching coordinates for ${plots.length} plots...');
    
    for (final plot in plots) {
      if (!_coordinateCache.containsKey(plot.id)) {
        // Trigger coordinate conversion and caching
        final coordinates = plot.polygonCoordinates;
        if (coordinates.isNotEmpty) {
          cacheCoordinates(plot.id, coordinates);
        }
      }
    }
    
    print('CoordinateCacheManager: Pre-caching completed. Cache size: ${_coordinateCache.length}');
  }
  
  /// Clear cache for specific plot
  void clearPlotCache(int plotId) {
    _coordinateCache.remove(plotId);
    _cacheAccessOrder.remove(plotId);
    print('CoordinateCacheManager: Cleared cache for plot $plotId');
  }
  
  /// Clear all cached coordinates
  void clearAllCache() {
    _coordinateCache.clear();
    _cacheAccessOrder.clear();
    print('CoordinateCacheManager: Cleared all cached coordinates');
  }
  
  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cached_plots': _coordinateCache.length,
      'max_cache_size': _maxCacheSize,
      'cache_usage_percent': (_coordinateCache.length / _maxCacheSize * 100).round(),
    };
  }
  
  /// Check if coordinates are cached for a plot
  bool isCached(int plotId) {
    return _coordinateCache.containsKey(plotId);
  }
  
  /// Get memory usage estimate (rough calculation)
  int getEstimatedMemoryUsage() {
    int totalPoints = 0;
    for (final coordinates in _coordinateCache.values) {
      for (final polygon in coordinates) {
        totalPoints += polygon.length;
      }
    }
    // Each LatLng is roughly 16 bytes (2 doubles)
    return totalPoints * 16;
  }
}
