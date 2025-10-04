import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/plot_model.dart';

/// Unified Memory Cache Manager - Level 1 Caching
/// Provides instant access to critical data without compromising any functionality
class UnifiedMemoryCache {
  // Singleton instance
  static UnifiedMemoryCache? _instance;
  static UnifiedMemoryCache get instance => _instance ??= UnifiedMemoryCache._();
  
  UnifiedMemoryCache._();

  // Memory cache storage
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, int> _accessCounts = {};
  final Map<String, CachePriority> _cachePriorities = {};
  
  // Cache configuration
  static const int _maxCacheSize = 50 * 1024 * 1024; // 50MB memory limit
  static const Duration _defaultExpiry = Duration(hours: 6);
  static const Duration _criticalExpiry = Duration(days: 7);
  
  int _currentCacheSize = 0;
  bool _isInitialized = false;
  
  // Performance monitoring
  final Map<String, int> _hitCounts = {};
  final Map<String, int> _missCounts = {};
  
  /// Initialize the memory cache system
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isInitialized = true;
    print('🧠 UnifiedMemoryCache: Initialized with ${_formatBytes(_maxCacheSize)} limit');
    
    // Start cleanup timer
    _startCleanupTimer();
  }
  
  /// Store data in memory cache with instant access
  Future<void> store(String key, dynamic data, {
    CachePriority priority = CachePriority.normal,
    Duration? expiry,
    bool compress = false,
  }) async {
    if (!_isInitialized) await initialize();
    
    try {
      // Calculate data size
      final dataSize = _calculateDataSize(data);
      
      // Check if we need to make space
      if (_currentCacheSize + dataSize > _maxCacheSize) {
        await _makeSpace(dataSize);
      }
      
      // Store the data
      _cache[key] = data;
      _cacheTimestamps[key] = DateTime.now();
      _accessCounts[key] = 0;
      _cachePriorities[key] = priority;
      
      _currentCacheSize += dataSize;
      
      print('🧠 Stored $key (${_formatBytes(dataSize)}) - Priority: $priority');
    } catch (e) {
      print('❌ Error storing $key: $e');
    }
  }
  
  /// Get data from memory cache with instant access
  T? get<T>(String key, {bool updateAccessCount = true}) {
    if (!_isInitialized) return null;
    
    try {
      if (_cache.containsKey(key)) {
        // Check if cache is expired
        final timestamp = _cacheTimestamps[key];
        if (timestamp != null && _isExpired(key, timestamp)) {
          _remove(key);
          _recordMiss(key);
          return null;
        }
        
        // Update access count
        if (updateAccessCount) {
          _accessCounts[key] = (_accessCounts[key] ?? 0) + 1;
        }
        
        _recordHit(key);
        return _cache[key] as T?;
      } else {
        _recordMiss(key);
        return null;
      }
    } catch (e) {
      print('❌ Error getting $key: $e');
      _recordMiss(key);
      return null;
    }
  }
  
  /// Store boundary polygons with instant access
  Future<void> storeBoundaries(List<BoundaryPolygon> boundaries) async {
    await store(
      'boundaries_all',
      boundaries,
      priority: CachePriority.critical,
      expiry: _criticalExpiry,
    );
    
    // Also store individual boundaries for quick access
    for (final boundary in boundaries) {
      await store(
        'boundary_${boundary.phaseName}',
        boundary,
        priority: CachePriority.critical,
        expiry: _criticalExpiry,
      );
    }
    
    print('🧠 Stored ${boundaries.length} boundaries in memory cache');
  }
  
  /// Get boundaries with instant access
  List<BoundaryPolygon>? getBoundaries() {
    return get<List<BoundaryPolygon>>('boundaries_all');
  }
  
  /// Get specific boundary with instant access
  BoundaryPolygon? getBoundary(String phaseName) {
    return get<BoundaryPolygon>('boundary_$phaseName');
  }
  
  /// Store plots with instant access
  Future<void> storePlots(List<PlotModel> plots, {
    String? viewportKey,
    double? zoomLevel,
  }) async {
    final key = viewportKey ?? 'plots_all';
    await store(
      key,
      plots,
      priority: CachePriority.high,
      expiry: _defaultExpiry,
    );
    
    // Store zoom-level specific plots
    if (zoomLevel != null) {
      await store(
        'plots_zoom_${zoomLevel.round()}',
        plots,
        priority: CachePriority.normal,
        expiry: _defaultExpiry,
      );
    }
    
    print('🧠 Stored ${plots.length} plots in memory cache');
  }
  
  /// Get plots with instant access
  List<PlotModel>? getPlots({String? viewportKey, double? zoomLevel}) {
    if (viewportKey != null) {
      return get<List<PlotModel>>(viewportKey);
    }
    
    if (zoomLevel != null) {
      return get<List<PlotModel>>('plots_zoom_${zoomLevel.round()}');
    }
    
    return get<List<PlotModel>>('plots_all');
  }
  
  /// Store map tiles with instant access
  Future<void> storeMapTile(String tileKey, Uint8List tileData) async {
    await store(
      'tile_$tileKey',
      tileData,
      priority: CachePriority.normal,
      expiry: const Duration(days: 7),
      compress: true,
    );
  }
  
  /// Get map tile with instant access
  Uint8List? getMapTile(String tileKey) {
    return get<Uint8List>('tile_$tileKey');
  }
  
  /// Store API response with instant access
  Future<void> storeApiResponse(String endpoint, dynamic response) async {
    await store(
      'api_$endpoint',
      response,
      priority: CachePriority.high,
      expiry: _defaultExpiry,
    );
  }
  
  /// Get API response with instant access
  T? getApiResponse<T>(String endpoint) {
    return get<T>('api_$endpoint');
  }
  
  /// Store processed GeoJSON with instant access
  Future<void> storeProcessedGeoJson(String key, Map<String, dynamic> geoJson) async {
    await store(
      'geojson_$key',
      geoJson,
      priority: CachePriority.critical,
      expiry: _criticalExpiry,
    );
  }
  
  /// Get processed GeoJSON with instant access
  Map<String, dynamic>? getProcessedGeoJson(String key) {
    return get<Map<String, dynamic>>('geojson_$key');
  }
  
  /// Check if data exists in cache
  bool contains(String key) {
    if (!_isInitialized) return false;
    
    if (_cache.containsKey(key)) {
      final timestamp = _cacheTimestamps[key];
      if (timestamp != null && _isExpired(key, timestamp)) {
        _remove(key);
        return false;
      }
      return true;
    }
    return false;
  }
  
  /// Remove specific data from cache
  void _remove(String key) {
    if (_cache.containsKey(key)) {
      final dataSize = _calculateDataSize(_cache[key]);
      _currentCacheSize -= dataSize;
      
      _cache.remove(key);
      _cacheTimestamps.remove(key);
      _accessCounts.remove(key);
      _cachePriorities.remove(key);
    }
  }
  
  /// Make space in cache by removing least important data
  Future<void> _makeSpace(int requiredSize) async {
    // Sort by priority and access count
    final sortedKeys = _cache.keys.toList()
      ..sort((a, b) {
        final priorityA = _cachePriorities[a] ?? CachePriority.normal;
        final priorityB = _cachePriorities[b] ?? CachePriority.normal;
        
        if (priorityA != priorityB) {
          return priorityA.index.compareTo(priorityB.index);
        }
        
        final accessA = _accessCounts[a] ?? 0;
        final accessB = _accessCounts[b] ?? 0;
        return accessA.compareTo(accessB);
      });
    
    // Remove least important data until we have enough space
    for (final key in sortedKeys) {
      if (_currentCacheSize + requiredSize <= _maxCacheSize) break;
      
      _remove(key);
    }
  }
  
  /// Check if cache entry is expired
  bool _isExpired(String key, DateTime timestamp) {
    final priority = _cachePriorities[key] ?? CachePriority.normal;
    final expiry = priority == CachePriority.critical ? _criticalExpiry : _defaultExpiry;
    
    return DateTime.now().difference(timestamp) > expiry;
  }
  
  /// Calculate data size for memory management
  int _calculateDataSize(dynamic data) {
    try {
      if (data is String) return data.length * 2; // UTF-16
      if (data is Uint8List) return data.length;
      if (data is List) return data.length * 100; // Estimate
      if (data is Map) return data.length * 200; // Estimate
      return 1000; // Default estimate
    } catch (e) {
      return 1000; // Default estimate
    }
  }
  
  /// Start cleanup timer for expired data
  void _startCleanupTimer() {
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _cleanupExpired();
    });
  }
  
  /// Cleanup expired data
  void _cleanupExpired() {
    final expiredKeys = <String>[];
    
    for (final entry in _cacheTimestamps.entries) {
      if (_isExpired(entry.key, entry.value)) {
        expiredKeys.add(entry.key);
      }
    }
    
    for (final key in expiredKeys) {
      _remove(key);
    }
    
    if (expiredKeys.isNotEmpty) {
      print('🧠 Cleaned up ${expiredKeys.length} expired cache entries');
    }
  }
  
  /// Record cache hit
  void _recordHit(String key) {
    _hitCounts[key] = (_hitCounts[key] ?? 0) + 1;
  }
  
  /// Record cache miss
  void _recordMiss(String key) {
    _missCounts[key] = (_missCounts[key] ?? 0) + 1;
  }
  
  /// Get cache statistics
  Map<String, dynamic> getStatistics() {
    final totalHits = _hitCounts.values.fold(0, (sum, count) => sum + count);
    final totalMisses = _missCounts.values.fold(0, (sum, count) => sum + count);
    final hitRate = totalHits + totalMisses > 0 ? totalHits / (totalHits + totalMisses) : 0.0;
    
    return {
      'cache_size': _cache.length,
      'memory_usage': _formatBytes(_currentCacheSize),
      'memory_limit': _formatBytes(_maxCacheSize),
      'usage_percentage': (_currentCacheSize / _maxCacheSize * 100).toStringAsFixed(1),
      'hit_rate': (hitRate * 100).toStringAsFixed(1),
      'total_hits': totalHits,
      'total_misses': totalMisses,
    };
  }
  
  /// Clear all cache data
  void clearAll() {
    _cache.clear();
    _cacheTimestamps.clear();
    _accessCounts.clear();
    _cachePriorities.clear();
    _currentCacheSize = 0;
    _hitCounts.clear();
    _missCounts.clear();
    
    print('🧠 Cleared all memory cache data');
  }
  
  /// Clear specific cache entry
  void clear(String key) {
    _remove(key);
    print('🧠 Cleared cache entry: $key');
  }
  
  /// Format bytes for display
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Cache priority levels for intelligent cache management
enum CachePriority {
  low,      // Can be removed first
  normal,   // Standard priority
  high,     // Keep longer
  critical, // Never remove unless expired
}

/// Optimized BoundaryPolygon class for memory cache
class BoundaryPolygon {
  final String phaseName;
  final List<List<LatLng>> polygons;
  final Color color;
  final IconData icon;
  
  // Cached properties for performance
  LatLng? _cachedCenter;
  Map<String, LatLng>? _cachedBounds;
  
  BoundaryPolygon({
    required this.phaseName,
    required this.polygons,
    required this.color,
    required this.icon,
  });
  
  /// Get center point (cached for performance)
  LatLng get center {
    if (_cachedCenter != null) return _cachedCenter!;
    
    if (polygons.isEmpty) {
      _cachedCenter = const LatLng(0, 0);
      return _cachedCenter!;
    }
    
    double totalLat = 0;
    double totalLng = 0;
    int pointCount = 0;
    
    for (final polygon in polygons) {
      for (final point in polygon) {
        totalLat += point.latitude;
        totalLng += point.longitude;
        pointCount++;
      }
    }
    
    _cachedCenter = pointCount > 0 
        ? LatLng(totalLat / pointCount, totalLng / pointCount)
        : const LatLng(0, 0);
    
    return _cachedCenter!;
  }
  
  /// Get bounds (cached for performance)
  Map<String, LatLng> get bounds {
    if (_cachedBounds != null) return _cachedBounds!;
    
    if (polygons.isEmpty) {
      _cachedBounds = {
        'north': const LatLng(0, 0),
        'south': const LatLng(0, 0),
        'east': const LatLng(0, 0),
        'west': const LatLng(0, 0),
      };
      return _cachedBounds!;
    }
    
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;
    
    for (final polygon in polygons) {
      for (final point in polygon) {
        minLat = min(minLat, point.latitude);
        maxLat = max(maxLat, point.latitude);
        minLng = min(minLng, point.longitude);
        maxLng = max(maxLng, point.longitude);
      }
    }
    
    _cachedBounds = {
      'north': LatLng(maxLat, 0),
      'south': LatLng(minLat, 0),
      'east': LatLng(0, maxLng),
      'west': LatLng(0, minLng),
    };
    
    return _cachedBounds!;
  }
}
