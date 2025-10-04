import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/plot_model.dart';
import 'unified_memory_cache.dart';

/// Optimized Plots Cache with Level 1 Memory Cache
/// Provides instant access to plot data while preserving all functionality
class OptimizedPlotsCache {
  static const String _cacheVersion = '2.0.0';
  static bool _isInitialized = false;
  
  // Cache configuration
  static const Duration _plotCacheExpiry = Duration(hours: 6);
  static const Duration _apiCacheExpiry = Duration(hours: 2);
  static const int _maxPlotsPerViewport = 500;
  
  // Performance monitoring
  static final Map<String, int> _performanceMetrics = {};
  static final Map<String, DateTime> _lastFetchTimes = {};
  
  /// Initialize the optimized plots cache
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isInitialized = true;
    print('📊 OptimizedPlotsCache: Initializing with memory cache...');
    
    // Initialize memory cache
    await UnifiedMemoryCache.instance.initialize();
    
    print('📊 OptimizedPlotsCache: Initialized successfully');
  }
  
  /// Store plots with instant access
  static Future<void> storePlots(List<PlotModel> plots, {
    String? viewportKey,
    double? zoomLevel,
    LatLng? center,
    double? radius,
  }) async {
    if (!_isInitialized) await initialize();
    
    try {
      // Create cache key based on parameters
      String cacheKey = 'plots_all';
      if (viewportKey != null) {
        cacheKey = 'plots_viewport_$viewportKey';
      } else if (zoomLevel != null) {
        cacheKey = 'plots_zoom_${zoomLevel.round()}';
      }
      
      // Store in memory cache
      await UnifiedMemoryCache.instance.store(
        cacheKey,
        plots,
        priority: CachePriority.high,
        expiry: _plotCacheExpiry,
      );
      
      // Store zoom-level specific cache
      if (zoomLevel != null) {
        await UnifiedMemoryCache.instance.store(
          'plots_zoom_${zoomLevel.round()}',
          plots,
          priority: CachePriority.normal,
          expiry: _plotCacheExpiry,
        );
      }
      
      // Store viewport-specific cache
      if (center != null && radius != null) {
        final viewportKey = _createViewportKey(center, radius);
        await UnifiedMemoryCache.instance.store(
          'plots_viewport_$viewportKey',
          plots,
          priority: CachePriority.high,
          expiry: _plotCacheExpiry,
        );
      }
      
      _recordPerformance('plots_stored', plots.length);
      print('📊 OptimizedPlotsCache: Stored ${plots.length} plots with key: $cacheKey');
    } catch (e) {
      print('❌ OptimizedPlotsCache: Error storing plots: $e');
    }
  }
  
  /// Get plots with instant access
  static List<PlotModel>? getPlots({
    String? viewportKey,
    double? zoomLevel,
    LatLng? center,
    double? radius,
  }) {
    if (!_isInitialized) return null;
    
    try {
      // Try viewport-specific cache first
      if (viewportKey != null) {
        final plots = UnifiedMemoryCache.instance.get<List<PlotModel>>('plots_viewport_$viewportKey');
        if (plots != null) {
          _recordPerformance('cache_hit_viewport', 1);
          return plots;
        }
      }
      
      // Try zoom-level cache
      if (zoomLevel != null) {
        final plots = UnifiedMemoryCache.instance.get<List<PlotModel>>('plots_zoom_${zoomLevel.round()}');
        if (plots != null) {
          _recordPerformance('cache_hit_zoom', 1);
          return plots;
        }
      }
      
      // Try viewport bounds cache
      if (center != null && radius != null) {
        final viewportKey = _createViewportKey(center, radius);
        final plots = UnifiedMemoryCache.instance.get<List<PlotModel>>('plots_viewport_$viewportKey');
        if (plots != null) {
          _recordPerformance('cache_hit_bounds', 1);
          return plots;
        }
      }
      
      // Fallback to all plots cache
      final allPlots = UnifiedMemoryCache.instance.get<List<PlotModel>>('plots_all');
      if (allPlots != null) {
        _recordPerformance('cache_hit_all', 1);
        return allPlots;
      }
      
      _recordPerformance('cache_miss', 1);
      return null;
    } catch (e) {
      print('❌ OptimizedPlotsCache: Error getting plots: $e');
      _recordPerformance('cache_error', 1);
      return null;
    }
  }
  
  /// Store API response with instant access
  static Future<void> storeApiResponse(String endpoint, dynamic response) async {
    if (!_isInitialized) await initialize();
    
    try {
      await UnifiedMemoryCache.instance.store(
        'api_$endpoint',
        response,
        priority: CachePriority.high,
        expiry: _apiCacheExpiry,
      );
      
      _recordPerformance('api_stored', 1);
      print('📊 OptimizedPlotsCache: Stored API response for $endpoint');
    } catch (e) {
      print('❌ OptimizedPlotsCache: Error storing API response: $e');
    }
  }
  
  /// Get API response with instant access
  static T? getApiResponse<T>(String endpoint) {
    if (!_isInitialized) return null;
    
    try {
      final response = UnifiedMemoryCache.instance.get<T>('api_$endpoint');
      if (response != null) {
        _recordPerformance('api_cache_hit', 1);
      } else {
        _recordPerformance('api_cache_miss', 1);
      }
      return response;
    } catch (e) {
      print('❌ OptimizedPlotsCache: Error getting API response: $e');
      _recordPerformance('api_cache_error', 1);
      return null;
    }
  }
  
  /// Store processed GeoJSON with instant access
  static Future<void> storeProcessedGeoJson(String key, Map<String, dynamic> geoJson) async {
    if (!_isInitialized) await initialize();
    
    try {
      await UnifiedMemoryCache.instance.store(
        'geojson_$key',
        geoJson,
        priority: CachePriority.critical,
        expiry: const Duration(days: 7),
      );
      
      _recordPerformance('geojson_stored', 1);
      print('📊 OptimizedPlotsCache: Stored processed GeoJSON for $key');
    } catch (e) {
      print('❌ OptimizedPlotsCache: Error storing processed GeoJSON: $e');
    }
  }
  
  /// Get processed GeoJSON with instant access
  static Map<String, dynamic>? getProcessedGeoJson(String key) {
    if (!_isInitialized) return null;
    
    try {
      final geoJson = UnifiedMemoryCache.instance.get<Map<String, dynamic>>('geojson_$key');
      if (geoJson != null) {
        _recordPerformance('geojson_cache_hit', 1);
      } else {
        _recordPerformance('geojson_cache_miss', 1);
      }
      return geoJson;
    } catch (e) {
      print('❌ OptimizedPlotsCache: Error getting processed GeoJSON: $e');
      _recordPerformance('geojson_cache_error', 1);
      return null;
    }
  }
  
  /// Store filtered plots with instant access
  static Future<void> storeFilteredPlots(List<PlotModel> plots, Map<String, dynamic> filters) async {
    if (!_isInitialized) await initialize();
    
    try {
      final filterKey = _createFilterKey(filters);
      await UnifiedMemoryCache.instance.store(
        'filtered_plots_$filterKey',
        plots,
        priority: CachePriority.normal,
        expiry: const Duration(hours: 2),
      );
      
      _recordPerformance('filtered_stored', plots.length);
      print('📊 OptimizedPlotsCache: Stored ${plots.length} filtered plots');
    } catch (e) {
      print('❌ OptimizedPlotsCache: Error storing filtered plots: $e');
    }
  }
  
  /// Get filtered plots with instant access
  static List<PlotModel>? getFilteredPlots(Map<String, dynamic> filters) {
    if (!_isInitialized) return null;
    
    try {
      final filterKey = _createFilterKey(filters);
      final plots = UnifiedMemoryCache.instance.get<List<PlotModel>>('filtered_plots_$filterKey');
      if (plots != null) {
        _recordPerformance('filtered_cache_hit', 1);
      } else {
        _recordPerformance('filtered_cache_miss', 1);
      }
      return plots;
    } catch (e) {
      print('❌ OptimizedPlotsCache: Error getting filtered plots: $e');
      _recordPerformance('filtered_cache_error', 1);
      return null;
    }
  }
  
  /// Store plot statistics with instant access
  static Future<void> storePlotStatistics(Map<String, dynamic> stats) async {
    if (!_isInitialized) await initialize();
    
    try {
      await UnifiedMemoryCache.instance.store(
        'plot_statistics',
        stats,
        priority: CachePriority.high,
        expiry: const Duration(hours: 4),
      );
      
      _recordPerformance('stats_stored', 1);
      print('📊 OptimizedPlotsCache: Stored plot statistics');
    } catch (e) {
      print('❌ OptimizedPlotsCache: Error storing plot statistics: $e');
    }
  }
  
  /// Get plot statistics with instant access
  static Map<String, dynamic>? getPlotStatistics() {
    if (!_isInitialized) return null;
    
    try {
      final stats = UnifiedMemoryCache.instance.get<Map<String, dynamic>>('plot_statistics');
      if (stats != null) {
        _recordPerformance('stats_cache_hit', 1);
      } else {
        _recordPerformance('stats_cache_miss', 1);
      }
      return stats;
    } catch (e) {
      print('❌ OptimizedPlotsCache: Error getting plot statistics: $e');
      _recordPerformance('stats_cache_error', 1);
      return null;
    }
  }
  
  /// Create viewport key for caching
  static String _createViewportKey(LatLng center, double radius) {
    return '${center.latitude.toStringAsFixed(4)}_${center.longitude.toStringAsFixed(4)}_${radius.toStringAsFixed(1)}';
  }
  
  /// Create filter key for caching
  static String _createFilterKey(Map<String, dynamic> filters) {
    final sortedKeys = filters.keys.toList()..sort();
    final keyParts = <String>[];
    
    for (final key in sortedKeys) {
      final value = filters[key];
      if (value != null) {
        keyParts.add('${key}_${value}');
      }
    }
    
    return keyParts.join('_');
  }
  
  /// Record performance metrics
  static void _recordPerformance(String metric, int value) {
    _performanceMetrics[metric] = (_performanceMetrics[metric] ?? 0) + value;
  }
  
  /// Get performance statistics
  static Map<String, dynamic> getPerformanceStatistics() {
    final totalHits = (_performanceMetrics['cache_hit_viewport'] ?? 0) +
                     (_performanceMetrics['cache_hit_zoom'] ?? 0) +
                     (_performanceMetrics['cache_hit_bounds'] ?? 0) +
                     (_performanceMetrics['cache_hit_all'] ?? 0) +
                     (_performanceMetrics['api_cache_hit'] ?? 0) +
                     (_performanceMetrics['geojson_cache_hit'] ?? 0) +
                     (_performanceMetrics['filtered_cache_hit'] ?? 0) +
                     (_performanceMetrics['stats_cache_hit'] ?? 0);
    
    final totalMisses = (_performanceMetrics['cache_miss'] ?? 0) +
                       (_performanceMetrics['api_cache_miss'] ?? 0) +
                       (_performanceMetrics['geojson_cache_miss'] ?? 0) +
                       (_performanceMetrics['filtered_cache_miss'] ?? 0) +
                       (_performanceMetrics['stats_cache_miss'] ?? 0);
    
    final hitRate = totalHits + totalMisses > 0 ? totalHits / (totalHits + totalMisses) : 0.0;
    
    return {
      'cache_version': _cacheVersion,
      'total_hits': totalHits,
      'total_misses': totalMisses,
      'hit_rate': (hitRate * 100).toStringAsFixed(1),
      'plots_stored': _performanceMetrics['plots_stored'] ?? 0,
      'api_responses_stored': _performanceMetrics['api_stored'] ?? 0,
      'geojson_stored': _performanceMetrics['geojson_stored'] ?? 0,
      'filtered_plots_stored': _performanceMetrics['filtered_stored'] ?? 0,
      'stats_stored': _performanceMetrics['stats_stored'] ?? 0,
    };
  }
  
  /// Get cache statistics
  static Map<String, dynamic> getCacheStatistics() {
    return UnifiedMemoryCache.instance.getStatistics();
  }
  
  /// Clear all plots cache
  static void clearAllCache() {
    UnifiedMemoryCache.instance.clearAll();
    _performanceMetrics.clear();
    _lastFetchTimes.clear();
    print('📊 OptimizedPlotsCache: All cache cleared');
  }
  
  /// Clear specific cache entry
  static void clearCache(String key) {
    UnifiedMemoryCache.instance.clear(key);
    print('📊 OptimizedPlotsCache: Cleared cache entry: $key');
  }
  
  /// Check if plots are cached
  static bool hasPlotsCached({
    String? viewportKey,
    double? zoomLevel,
    LatLng? center,
    double? radius,
  }) {
    if (!_isInitialized) return false;
    
    if (viewportKey != null) {
      return UnifiedMemoryCache.instance.contains('plots_viewport_$viewportKey');
    }
    
    if (zoomLevel != null) {
      return UnifiedMemoryCache.instance.contains('plots_zoom_${zoomLevel.round()}');
    }
    
    if (center != null && radius != null) {
      final viewportKey = _createViewportKey(center, radius);
      return UnifiedMemoryCache.instance.contains('plots_viewport_$viewportKey');
    }
    
    return UnifiedMemoryCache.instance.contains('plots_all');
  }
  
  /// Get optimal plot count for zoom level
  static int getOptimalPlotCount(double zoomLevel) {
    if (zoomLevel < 12) return 50;
    if (zoomLevel < 15) return 200;
    return 500;
  }
  
  /// Check if plots should be rendered as polygons
  static bool shouldRenderPolygons(double zoomLevel) {
    return zoomLevel >= 12;
  }
  
  /// Check if plots should be rendered as detailed polygons
  static bool shouldRenderDetailedPolygons(double zoomLevel) {
    return zoomLevel >= 15;
  }
}
