import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'unified_memory_cache.dart';

/// Optimized Tile Cache with Level 1 Memory Cache
/// Provides instant access to map tiles while preserving all functionality
class OptimizedTileCache {
  static const String _cacheVersion = '2.0.0';
  static const int _maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int _maxCacheAge = 7 * 24 * 60 * 60 * 1000; // 7 days in milliseconds
  static const int _maxConcurrentDownloads = 5;
  
  static OptimizedTileCache? _instance;
  static OptimizedTileCache get instance => _instance ??= OptimizedTileCache._();
  
  OptimizedTileCache._();
  
  Directory? _cacheDirectory;
  final Map<String, Completer<Uint8List?>> _pendingDownloads = {};
  Map<String, DateTime> _cacheTimestamps = {};
  Map<String, int> _cacheSizes = {};
  int _totalCacheSize = 0;
  
  bool _isInitialized = false;
  Timer? _cleanupTimer;
  
  // Performance monitoring
  final Map<String, int> _performanceMetrics = {};
  
  /// Initialize the optimized tile cache
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Get cache directory
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDirectory = Directory('${appDir.path}/optimized_tile_cache');
      
      if (!await _cacheDirectory!.exists()) {
        await _cacheDirectory!.create(recursive: true);
      }
      
      // Load cache metadata
      await _loadCacheMetadata();
      
      // Start cleanup timer
      _startCleanupTimer();
      
      _isInitialized = true;
      print('🗺️ OptimizedTileCache: Initialized with ${_formatBytes(_maxCacheSize)} limit');
      print('🗺️ OptimizedTileCache: Cache directory: ${_cacheDirectory!.path}');
      print('🗺️ OptimizedTileCache: Total cache size: ${_formatBytes(_totalCacheSize)}');
    } catch (e) {
      print('❌ OptimizedTileCache: Failed to initialize: $e');
    }
  }
  
  /// Get tile with instant access from memory cache first, then disk cache
  Future<Uint8List?> getTile(String phaseId, int z, int x, int y) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    final cacheKey = _generateCacheKey(phaseId, z, x, y);
    
    // Check memory cache first (instant access)
    final memoryTile = UnifiedMemoryCache.instance.getMapTile(cacheKey);
    if (memoryTile != null) {
      _recordPerformance('memory_cache_hit', 1);
      print('🗺️ OptimizedTileCache: Memory cache hit for $cacheKey');
      return memoryTile;
    }
    
    // Check disk cache
    final cacheFile = File('${_cacheDirectory!.path}/$cacheKey.png');
    if (await cacheFile.exists()) {
      final fileStat = await cacheFile.stat();
      final age = DateTime.now().millisecondsSinceEpoch - fileStat.modified.millisecondsSinceEpoch;
      
      // Check if cache is still valid
      if (age < _maxCacheAge) {
        final tileData = await cacheFile.readAsBytes();
        
        // Store in memory cache for instant access
        await UnifiedMemoryCache.instance.storeMapTile(cacheKey, tileData);
        
        _updateCacheTimestamp(cacheKey, fileStat.modified);
        _recordPerformance('disk_cache_hit', 1);
        print('🗺️ OptimizedTileCache: Disk cache hit for $cacheKey');
        return tileData;
      } else {
        // Cache expired, delete file
        await cacheFile.delete();
        _removeFromCacheMetadata(cacheKey);
      }
    }
    
    // Download tile if not in cache or expired
    _recordPerformance('cache_miss', 1);
    return await _downloadTile(phaseId, z, x, y, cacheKey);
  }
  
  /// Download tile with concurrent request management
  Future<Uint8List?> _downloadTile(String phaseId, int z, int x, int y, String cacheKey) async {
    // Check if download is already in progress
    if (_pendingDownloads.containsKey(cacheKey)) {
      return await _pendingDownloads[cacheKey]!.future;
    }
    
    // Limit concurrent downloads
    if (_pendingDownloads.length >= _maxConcurrentDownloads) {
      await Future.delayed(const Duration(milliseconds: 100));
      return await _downloadTile(phaseId, z, x, y, cacheKey);
    }
    
    final completer = Completer<Uint8List?>();
    _pendingDownloads[cacheKey] = completer;
    
    try {
      final url = 'https://tiles.dhamarketplace.com/data/$phaseId/{z}/{x}/{y}.png'
          .replaceAll('{z}', z.toString())
          .replaceAll('{x}', x.toString())
          .replaceAll('{y}', y.toString());
      
      print('🌐 OptimizedTileCache: Downloading tile: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'DHA Marketplace Mobile App',
          'Accept': 'image/png',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        
        // Save to disk cache
        await _saveTileToCache(cacheKey, bytes);
        
        // Store in memory cache for instant access
        await UnifiedMemoryCache.instance.storeMapTile(cacheKey, bytes);
        
        _recordPerformance('download_success', 1);
        completer.complete(bytes);
        print('✅ OptimizedTileCache: Tile downloaded and cached: $cacheKey');
      } else {
        print('❌ OptimizedTileCache: Failed to download tile: ${response.statusCode}');
        _recordPerformance('download_failed', 1);
        completer.complete(null);
      }
    } catch (e) {
      print('❌ OptimizedTileCache: Error downloading tile: $e');
      _recordPerformance('download_error', 1);
      completer.complete(null);
    } finally {
      _pendingDownloads.remove(cacheKey);
    }
    
    return await completer.future;
  }
  
  /// Save tile to disk cache
  Future<void> _saveTileToCache(String cacheKey, Uint8List bytes) async {
    try {
      final cacheFile = File('${_cacheDirectory!.path}/$cacheKey.png');
      await cacheFile.writeAsBytes(bytes);
      
      // Update cache metadata
      _cacheTimestamps[cacheKey] = DateTime.now();
      _cacheSizes[cacheKey] = bytes.length;
      _totalCacheSize += bytes.length;
      
      // Check if we need to clean up old tiles
      if (_totalCacheSize > _maxCacheSize) {
        await _cleanupOldTiles();
      }
      
      print('🗺️ OptimizedTileCache: Tile saved to disk cache: $cacheKey');
    } catch (e) {
      print('❌ OptimizedTileCache: Error saving tile to cache: $e');
    }
  }
  
  /// Load cache metadata from SharedPreferences
  Future<void> _loadCacheMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = prefs.getString('tile_cache_metadata');
      
      if (cacheData != null) {
        final Map<String, dynamic> metadata = jsonDecode(cacheData);
        _cacheTimestamps = (metadata['timestamps'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, DateTime.parse(value)),
        );
        _cacheSizes = (metadata['sizes'] as Map<String, dynamic>).map(
          (key, value) => MapEntry(key, value as int),
        );
        _totalCacheSize = metadata['totalSize'] as int? ?? 0;
      }
    } catch (e) {
      print('❌ OptimizedTileCache: Error loading cache metadata: $e');
    }
  }
  
  /// Save cache metadata to SharedPreferences
  Future<void> _saveCacheMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadata = {
        'timestamps': _cacheTimestamps.map((key, value) => MapEntry(key, value.toIso8601String())),
        'sizes': _cacheSizes,
        'totalSize': _totalCacheSize,
        'version': _cacheVersion,
      };
      
      await prefs.setString('tile_cache_metadata', jsonEncode(metadata));
    } catch (e) {
      print('❌ OptimizedTileCache: Error saving cache metadata: $e');
    }
  }
  
  /// Update cache timestamp
  void _updateCacheTimestamp(String cacheKey, DateTime timestamp) {
    _cacheTimestamps[cacheKey] = timestamp;
  }
  
  /// Remove from cache metadata
  void _removeFromCacheMetadata(String cacheKey) {
    if (_cacheSizes.containsKey(cacheKey)) {
      _totalCacheSize -= _cacheSizes[cacheKey]!;
      _cacheSizes.remove(cacheKey);
    }
    _cacheTimestamps.remove(cacheKey);
  }
  
  /// Clean up old tiles to make space
  Future<void> _cleanupOldTiles() async {
    try {
      // Sort tiles by timestamp (oldest first)
      final sortedTiles = _cacheTimestamps.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      
      // Remove oldest tiles until we have enough space
      for (final entry in sortedTiles) {
        if (_totalCacheSize <= _maxCacheSize * 0.8) break; // Keep 20% buffer
        
        final cacheKey = entry.key;
        final cacheFile = File('${_cacheDirectory!.path}/$cacheKey.png');
        
        if (await cacheFile.exists()) {
          await cacheFile.delete();
        }
        
        _removeFromCacheMetadata(cacheKey);
      }
      
      // Save updated metadata
      await _saveCacheMetadata();
      
      print('🗺️ OptimizedTileCache: Cleaned up old tiles, current size: ${_formatBytes(_totalCacheSize)}');
    } catch (e) {
      print('❌ OptimizedTileCache: Error cleaning up old tiles: $e');
    }
  }
  
  /// Start cleanup timer for expired tiles
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _cleanupExpiredTiles();
    });
  }
  
  /// Clean up expired tiles
  Future<void> _cleanupExpiredTiles() async {
    try {
      final expiredKeys = <String>[];
      final now = DateTime.now();
      
      for (final entry in _cacheTimestamps.entries) {
        if (now.difference(entry.value).inMilliseconds > _maxCacheAge) {
          expiredKeys.add(entry.key);
        }
      }
      
      for (final cacheKey in expiredKeys) {
        final cacheFile = File('${_cacheDirectory!.path}/$cacheKey.png');
        if (await cacheFile.exists()) {
          await cacheFile.delete();
        }
        
        _removeFromCacheMetadata(cacheKey);
      }
      
      if (expiredKeys.isNotEmpty) {
        await _saveCacheMetadata();
        print('🗺️ OptimizedTileCache: Cleaned up ${expiredKeys.length} expired tiles');
      }
    } catch (e) {
      print('❌ OptimizedTileCache: Error cleaning up expired tiles: $e');
    }
  }
  
  /// Generate cache key for tile
  String _generateCacheKey(String phaseId, int z, int x, int y) {
    return '${phaseId}_${z}_${x}_${y}';
  }
  
  /// Record performance metrics
  void _recordPerformance(String metric, int value) {
    _performanceMetrics[metric] = (_performanceMetrics[metric] ?? 0) + value;
  }
  
  /// Get cache statistics
  Map<String, dynamic> getCacheStatistics() {
    final totalHits = (_performanceMetrics['memory_cache_hit'] ?? 0) + 
                     (_performanceMetrics['disk_cache_hit'] ?? 0);
    final totalMisses = _performanceMetrics['cache_miss'] ?? 0;
    final hitRate = totalHits + totalMisses > 0 ? totalHits / (totalHits + totalMisses) : 0.0;
    
    return {
      'cache_version': _cacheVersion,
      'total_size': _formatBytes(_totalCacheSize),
      'max_size': _formatBytes(_maxCacheSize),
      'usage_percentage': (_totalCacheSize / _maxCacheSize * 100).toStringAsFixed(1),
      'total_tiles': _cacheTimestamps.length,
      'hit_rate': (hitRate * 100).toStringAsFixed(1),
      'memory_hits': _performanceMetrics['memory_cache_hit'] ?? 0,
      'disk_hits': _performanceMetrics['disk_cache_hit'] ?? 0,
      'cache_misses': _performanceMetrics['cache_miss'] ?? 0,
      'downloads_successful': _performanceMetrics['download_success'] ?? 0,
      'downloads_failed': _performanceMetrics['download_failed'] ?? 0,
    };
  }
  
  /// Get memory cache statistics
  Map<String, dynamic> getMemoryCacheStatistics() {
    return UnifiedMemoryCache.instance.getStatistics();
  }
  
  /// Clear all cache data
  Future<void> clearAllCache() async {
    try {
      // Clear disk cache
      if (_cacheDirectory != null && await _cacheDirectory!.exists()) {
        await _cacheDirectory!.delete(recursive: true);
        await _cacheDirectory!.create(recursive: true);
      }
      
      // Clear memory cache
      UnifiedMemoryCache.instance.clearAll();
      
      // Reset metadata
      _cacheTimestamps.clear();
      _cacheSizes.clear();
      _totalCacheSize = 0;
      _performanceMetrics.clear();
      
      await _saveCacheMetadata();
      
      print('🗺️ OptimizedTileCache: All cache cleared');
    } catch (e) {
      print('❌ OptimizedTileCache: Error clearing cache: $e');
    }
  }
  
  /// Clear specific tile cache
  Future<void> clearTileCache(String phaseId, int z, int x, int y) async {
    try {
      final cacheKey = _generateCacheKey(phaseId, z, x, y);
      
      // Clear from disk cache
      final cacheFile = File('${_cacheDirectory!.path}/$cacheKey.png');
      if (await cacheFile.exists()) {
        await cacheFile.delete();
      }
      
      // Clear from memory cache
      UnifiedMemoryCache.instance.clear('tile_$cacheKey');
      
      // Remove from metadata
      _removeFromCacheMetadata(cacheKey);
      await _saveCacheMetadata();
      
      print('🗺️ OptimizedTileCache: Cleared tile cache for $cacheKey');
    } catch (e) {
      print('❌ OptimizedTileCache: Error clearing tile cache: $e');
    }
  }
  
  /// Format bytes for display
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
  
  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    _pendingDownloads.clear();
  }
}
