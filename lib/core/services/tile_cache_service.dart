import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// Advanced Tile Cache Service for DHA Marketplace
/// Provides intelligent caching, compression, and performance optimization
class TileCacheService {
  static const String _cacheVersion = '1.0.0';
  static const int _maxCacheSize = 100 * 1024 * 1024; // 100MB
  static const int _maxCacheAge = 7 * 24 * 60 * 60 * 1000; // 7 days in milliseconds
  static const int _maxConcurrentDownloads = 5;
  
  static TileCacheService? _instance;
  static TileCacheService get instance => _instance ??= TileCacheService._();
  
  TileCacheService._();

  Directory? _cacheDirectory;
  final Map<String, Completer<Uint8List?>> _pendingDownloads = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Map<String, int> _cacheSizes = {};
  int _totalCacheSize = 0;
  
  bool _isInitialized = false;
  Timer? _cleanupTimer;

  /// Initialize the cache service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Get cache directory
      final appDir = await getApplicationDocumentsDirectory();
      _cacheDirectory = Directory('${appDir.path}/tile_cache');
      
      if (!await _cacheDirectory!.exists()) {
        await _cacheDirectory!.create(recursive: true);
      }
      
      // Load cache metadata
      await _loadCacheMetadata();
      
      // Start cleanup timer
      _startCleanupTimer();
      
      _isInitialized = true;
      print('🗂️ Tile Cache Service initialized');
      print('🗂️ Cache directory: ${_cacheDirectory!.path}');
      print('🗂️ Total cache size: ${_formatBytes(_totalCacheSize)}');
    } catch (e) {
      print('❌ Failed to initialize Tile Cache Service: $e');
    }
  }

  /// Get tile with caching
  Future<Uint8List?> getTile(String phaseId, int z, int x, int y) async {
    if (!_isInitialized) {
      await initialize();
    }

    final cacheKey = _generateCacheKey(phaseId, z, x, y);
    final cacheFile = File('${_cacheDirectory!.path}/$cacheKey.png');
    
    // Check if tile exists in cache
    if (await cacheFile.exists()) {
      final fileStat = await cacheFile.stat();
      final age = DateTime.now().millisecondsSinceEpoch - fileStat.modified.millisecondsSinceEpoch;
      
      // Check if cache is still valid
      if (age < _maxCacheAge) {
        _updateCacheTimestamp(cacheKey, fileStat.modified);
        print('🗂️ Cache hit: $cacheKey');
        return await cacheFile.readAsBytes();
      } else {
        // Cache expired, delete file
        await cacheFile.delete();
        _removeFromCacheMetadata(cacheKey);
      }
    }
    
    // Download tile if not in cache or expired
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
      
      print('🌐 Downloading tile: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'DHA Marketplace Mobile App',
          'Accept': 'image/png',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        
        // Save to cache
        await _saveTileToCache(cacheKey, bytes);
        
        completer.complete(bytes);
        print('✅ Tile downloaded and cached: $cacheKey');
      } else {
        print('❌ Failed to download tile: ${response.statusCode}');
        completer.complete(null);
      }
    } catch (e) {
      print('❌ Error downloading tile: $e');
      completer.complete(null);
    } finally {
      _pendingDownloads.remove(cacheKey);
    }
    
    return await completer.future;
  }

  /// Save tile to cache
  Future<void> _saveTileToCache(String cacheKey, Uint8List bytes) async {
    try {
      final cacheFile = File('${_cacheDirectory!.path}/$cacheKey.png');
      await cacheFile.writeAsBytes(bytes);
      
      // Update cache metadata
      _updateCacheMetadata(cacheKey, bytes.length);
      
      // Check cache size and cleanup if needed
      await _manageCacheSize();
    } catch (e) {
      print('❌ Failed to save tile to cache: $e');
    }
  }

  /// Generate cache key for tile
  String _generateCacheKey(String phaseId, int z, int x, int y) {
    return '${phaseId}_${z}_${x}_${y}';
  }

  /// Update cache metadata
  void _updateCacheMetadata(String cacheKey, int size) {
    final oldSize = _cacheSizes[cacheKey] ?? 0;
    _cacheSizes[cacheKey] = size;
    _cacheTimestamps[cacheKey] = DateTime.now();
    _totalCacheSize = _totalCacheSize - oldSize + size;
  }

  /// Update cache timestamp
  void _updateCacheTimestamp(String cacheKey, DateTime timestamp) {
    _cacheTimestamps[cacheKey] = timestamp;
  }

  /// Remove from cache metadata
  void _removeFromCacheMetadata(String cacheKey) {
    final size = _cacheSizes.remove(cacheKey) ?? 0;
    _cacheTimestamps.remove(cacheKey);
    _totalCacheSize -= size;
  }

  /// Manage cache size
  Future<void> _manageCacheSize() async {
    if (_totalCacheSize <= _maxCacheSize) return;
    
    print('🗂️ Cache size exceeded, cleaning up...');
    
    // Sort by timestamp (oldest first)
    final sortedEntries = _cacheTimestamps.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    // Remove oldest entries until under limit
    for (final entry in sortedEntries) {
      if (_totalCacheSize <= _maxCacheSize * 0.8) break; // Leave some buffer
      
      final cacheKey = entry.key;
      final cacheFile = File('${_cacheDirectory!.path}/$cacheKey.png');
      
      if (await cacheFile.exists()) {
        await cacheFile.delete();
        _removeFromCacheMetadata(cacheKey);
        print('🗑️ Removed old cache entry: $cacheKey');
      }
    }
  }

  /// Load cache metadata from storage
  Future<void> _loadCacheMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadataJson = prefs.getString('tile_cache_metadata');
      
      if (metadataJson != null) {
        final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;
        
        _totalCacheSize = metadata['totalSize'] ?? 0;
        
        final timestamps = metadata['timestamps'] as Map<String, dynamic>? ?? {};
        final sizes = metadata['sizes'] as Map<String, dynamic>? ?? {};
        
        for (final entry in timestamps.entries) {
          _cacheTimestamps[entry.key] = DateTime.fromMillisecondsSinceEpoch(entry.value);
        }
        
        for (final entry in sizes.entries) {
          _cacheSizes[entry.key] = entry.value;
        }
      }
    } catch (e) {
      print('❌ Failed to load cache metadata: $e');
    }
  }

  /// Save cache metadata to storage
  Future<void> _saveCacheMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final metadata = {
        'version': _cacheVersion,
        'totalSize': _totalCacheSize,
        'timestamps': _cacheTimestamps.map((k, v) => MapEntry(k, v.millisecondsSinceEpoch)),
        'sizes': _cacheSizes,
      };
      
      await prefs.setString('tile_cache_metadata', jsonEncode(metadata));
    } catch (e) {
      print('❌ Failed to save cache metadata: $e');
    }
  }

  /// Start cleanup timer
  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _performCleanup();
    });
  }

  /// Perform cache cleanup
  Future<void> _performCleanup() async {
    try {
      final now = DateTime.now();
      final expiredKeys = <String>[];
      
      for (final entry in _cacheTimestamps.entries) {
        final age = now.millisecondsSinceEpoch - entry.value.millisecondsSinceEpoch;
        if (age > _maxCacheAge) {
          expiredKeys.add(entry.key);
        }
      }
      
      for (final key in expiredKeys) {
        final cacheFile = File('${_cacheDirectory!.path}/$key.png');
        if (await cacheFile.exists()) {
          await cacheFile.delete();
        }
        _removeFromCacheMetadata(key);
      }
      
      if (expiredKeys.isNotEmpty) {
        print('🗑️ Cleaned up ${expiredKeys.length} expired cache entries');
        await _saveCacheMetadata();
      }
    } catch (e) {
      print('❌ Error during cache cleanup: $e');
    }
  }

  /// Clear all cache
  Future<void> clearCache() async {
    try {
      if (_cacheDirectory != null && await _cacheDirectory!.exists()) {
        await _cacheDirectory!.delete(recursive: true);
        await _cacheDirectory!.create(recursive: true);
      }
      
      _cacheTimestamps.clear();
      _cacheSizes.clear();
      _totalCacheSize = 0;
      
      await _saveCacheMetadata();
      print('🗑️ Cache cleared');
    } catch (e) {
      print('❌ Failed to clear cache: $e');
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStatistics() {
    return {
      'totalSize': _totalCacheSize,
      'formattedSize': _formatBytes(_totalCacheSize),
      'entryCount': _cacheTimestamps.length,
      'maxSize': _maxCacheSize,
      'formattedMaxSize': _formatBytes(_maxCacheSize),
      'usagePercentage': (_totalCacheSize / _maxCacheSize * 100).toStringAsFixed(1),
    };
  }

  /// Format bytes to human readable string
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
    _saveCacheMetadata();
  }
}
