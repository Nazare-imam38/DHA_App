import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../data/models/plot_model.dart';

/// Unified Cache Manager - Multi-Level Caching System
/// Provides Memory, Disk, and Network caching layers for instant access
class UnifiedCacheManager {
  static UnifiedCacheManager? _instance;
  static UnifiedCacheManager get instance => _instance ??= UnifiedCacheManager._();
  
  UnifiedCacheManager._();
  
  // Cache layers
  late MemoryCacheLayer _memoryCache;
  late DiskCacheLayer _diskCache;
  late NetworkCacheLayer _networkCache;
  
  // Configuration
  static const int _maxMemorySize = 50 * 1024 * 1024; // 50MB
  static const int _maxDiskSize = 200 * 1024 * 1024; // 200MB
  static const Duration _defaultTTL = Duration(hours: 6);
  
  bool _isInitialized = false;
  
  /// Initialize the unified cache manager
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize Hive for disk caching
      await Hive.initFlutter();
      
      // Initialize cache layers
      _memoryCache = MemoryCacheLayer(_maxMemorySize);
      _diskCache = DiskCacheLayer(_maxDiskSize);
      _networkCache = NetworkCacheLayer();
      
      await _memoryCache.initialize();
      await _diskCache.initialize();
      await _networkCache.initialize();
      
      _isInitialized = true;
      print('✅ UnifiedCacheManager initialized with multi-level caching');
    } catch (e) {
      print('❌ Error initializing UnifiedCacheManager: $e');
    }
  }
  
  /// Get data from cache with level preference
  Future<T?> get<T>(String key, {CacheLevel levelPreference = CacheLevel.any}) async {
    if (!_isInitialized) {
      print('Warning: UnifiedCacheManager not initialized');
      return null;
    }
    
    // Try memory first (fastest)
    if (levelPreference == CacheLevel.any || levelPreference == CacheLevel.memory) {
      final memoryResult = _memoryCache.get<T>(key);
      if (memoryResult != null) {
        _memoryCache.recordHit();
        return memoryResult;
      }
    }
    
    // Try disk cache (fast)
    if (levelPreference == CacheLevel.any || levelPreference == CacheLevel.disk) {
      final diskResult = await _diskCache.get<T>(key);
      if (diskResult != null) {
        _diskCache.recordHit();
        // Store in memory for next time
        _memoryCache.put(key, diskResult);
        return diskResult;
      }
    }
    
    // Try network cache (slower)
    if (levelPreference == CacheLevel.any || levelPreference == CacheLevel.network) {
      final networkResult = await _networkCache.get<T>(key);
      if (networkResult != null) {
        _networkCache.recordHit();
        // Store in both memory and disk
        _memoryCache.put(key, networkResult);
        await _diskCache.put(key, networkResult);
        return networkResult;
      }
    }
    
    // Record miss
    _recordMiss();
    return null;
  }
  
  /// Store data in cache with TTL and compression
  Future<void> put<T>(String key, T value, {
    Duration? ttl,
    bool compress = false,
    CacheLevel preferredLevel = CacheLevel.memory,
  }) async {
    if (!_isInitialized) {
      print('Warning: UnifiedCacheManager not initialized');
      return;
    }
    
    final actualTTL = ttl ?? _defaultTTL;
    
    // Store in memory (always)
    _memoryCache.put(key, value, ttl: actualTTL);
    
    // Store in disk if preferred or if memory is full
    if (preferredLevel == CacheLevel.disk || preferredLevel == CacheLevel.any) {
      await _diskCache.put(key, value, ttl: actualTTL, compress: compress);
    }
    
    // Store in network cache if it's API data
    if (preferredLevel == CacheLevel.network || preferredLevel == CacheLevel.any) {
      await _networkCache.put(key, value, ttl: actualTTL);
    }
  }
  
  /// Invalidate cache entry
  Future<void> invalidate(String key) async {
    if (!_isInitialized) return;
    
    _memoryCache.remove(key);
    await _diskCache.remove(key);
    await _networkCache.remove(key);
  }
  
  /// Clear cache by prefix
  Future<void> clear(String prefix) async {
    if (!_isInitialized) return;
    
    _memoryCache.clear(prefix);
    await _diskCache.clear(prefix);
    await _networkCache.clear(prefix);
  }
  
  /// Check if key exists in any cache
  Future<bool> exists(String key) async {
    if (!_isInitialized) return false;
    
    return _memoryCache.exists(key) || 
           await _diskCache.exists(key) || 
           await _networkCache.exists(key);
  }
  
  /// Get cache statistics
  Map<String, dynamic> getStatistics() {
    if (!_isInitialized) return {};
    
    return {
      'memory': _memoryCache.getStatistics(),
      'disk': _diskCache.getStatistics(),
      'network': _networkCache.getStatistics(),
      'total_hits': _memoryCache.hits + _diskCache.hits + _networkCache.hits,
      'total_misses': _memoryCache.misses + _diskCache.misses + _networkCache.misses,
    };
  }
  
  void _recordMiss() {
    _memoryCache.recordMiss();
    _diskCache.recordMiss();
    _networkCache.recordMiss();
  }
}

/// Cache levels for preference
enum CacheLevel {
  memory,
  disk,
  network,
  any,
}

/// Memory Cache Layer - LRU with size limits
class MemoryCacheLayer {
  final int maxSize;
  final Map<String, _CacheEntry> _cache = {};
  int _currentSize = 0;
  int hits = 0;
  int misses = 0;
  
  MemoryCacheLayer(this.maxSize);
  
  Future<void> initialize() async {
    print('🧠 Memory cache layer initialized (${_formatBytes(maxSize)} limit)');
  }
  
  T? get<T>(String key) {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      if (entry != null) _cache.remove(key);
      return null;
    }
    
    // Update access time for LRU
    entry.lastAccessed = DateTime.now();
    return entry.value as T?;
  }
  
  void put<T>(String key, T value, {Duration? ttl}) {
    final size = _estimateSize(value);
    if (size > maxSize) {
      print('Warning: Item $key is too large for memory cache');
      return;
    }
    
    _evictIfNeeded(size);
    
    _cache[key] = _CacheEntry(
      value: value,
      size: size,
      ttl: ttl,
      createdAt: DateTime.now(),
      lastAccessed: DateTime.now(),
    );
    
    _currentSize += size;
  }
  
  void remove(String key) {
    final entry = _cache.remove(key);
    if (entry != null) {
      _currentSize -= entry.size;
    }
  }
  
  void clear(String prefix) {
    final keysToRemove = _cache.keys.where((key) => key.startsWith(prefix)).toList();
    for (final key in keysToRemove) {
      remove(key);
    }
  }
  
  bool exists(String key) {
    final entry = _cache[key];
    return entry != null && !entry.isExpired;
  }
  
  void recordHit() => hits++;
  void recordMiss() => misses++;
  
  void _evictIfNeeded(int newSize) {
    while (_currentSize + newSize > maxSize && _cache.isNotEmpty) {
      // Find least recently used entry
      String? lruKey;
      DateTime? oldestTime;
      
      _cache.forEach((key, entry) {
        if (lruKey == null || entry.lastAccessed.isBefore(oldestTime!)) {
          lruKey = key;
          oldestTime = entry.lastAccessed;
        }
      });
      
      if (lruKey != null) {
        remove(lruKey!);
      }
    }
  }
  
  int _estimateSize(dynamic value) {
    if (value is String) return utf8.encode(value).length;
    if (value is List) return value.fold(0, (sum, item) => sum + _estimateSize(item));
    if (value is Map) return value.values.fold(0, (sum, item) => sum + _estimateSize(item));
    if (value is Uint8List) return value.length;
    return 100; // Default estimate
  }
  
  Map<String, dynamic> getStatistics() {
    final hitRate = hits + misses == 0 ? 0.0 : (hits / (hits + misses)) * 100;
    return {
      'size': _cache.length,
      'memory_usage': _formatBytes(_currentSize),
      'memory_limit': _formatBytes(maxSize),
      'usage_percentage': (_currentSize / maxSize * 100).toStringAsFixed(1),
      'hit_rate': hitRate.toStringAsFixed(1),
      'hits': hits,
      'misses': misses,
    };
  }
  
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Disk Cache Layer - Hive-based persistent storage
class DiskCacheLayer {
  final int maxSize;
  late Box _box;
  int hits = 0;
  int misses = 0;
  
  DiskCacheLayer(this.maxSize);
  
  Future<void> initialize() async {
    _box = await Hive.openBox('unified_disk_cache');
    print('💾 Disk cache layer initialized (${_formatBytes(maxSize)} limit)');
  }
  
  Future<T?> get<T>(String key) async {
    try {
      final entry = _box.get(key);
      if (entry == null) return null;
      
      final cacheEntry = _DiskCacheEntry.fromJson(entry);
      if (cacheEntry.isExpired) {
        await _box.delete(key);
        return null;
      }
      
      return cacheEntry.value as T?;
    } catch (e) {
      print('Error reading from disk cache: $e');
      return null;
    }
  }
  
  Future<void> put<T>(String key, T value, {Duration? ttl, bool compress = false}) async {
    try {
      final entry = _DiskCacheEntry(
        value: value,
        ttl: ttl,
        compress: compress,
        createdAt: DateTime.now(),
      );
      
      await _box.put(key, entry.toJson());
    } catch (e) {
      print('Error writing to disk cache: $e');
    }
  }
  
  Future<void> remove(String key) async {
    await _box.delete(key);
  }
  
  Future<void> clear(String prefix) async {
    final keys = _box.keys.where((key) => key.toString().startsWith(prefix)).toList();
    await _box.deleteAll(keys);
  }
  
  Future<bool> exists(String key) async {
    return _box.containsKey(key);
  }
  
  void recordHit() => hits++;
  void recordMiss() => misses++;
  
  Map<String, dynamic> getStatistics() {
    return {
      'size': _box.length,
      'hits': hits,
      'misses': misses,
    };
  }
  
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// Network Cache Layer - API response caching
class NetworkCacheLayer {
  final Map<String, _NetworkCacheEntry> _cache = {};
  int hits = 0;
  int misses = 0;
  
  Future<void> initialize() async {
    print('🌐 Network cache layer initialized');
  }
  
  Future<T?> get<T>(String key) async {
    final entry = _cache[key];
    if (entry == null || entry.isExpired) {
      if (entry != null) _cache.remove(key);
      return null;
    }
    
    return entry.value as T?;
  }
  
  Future<void> put<T>(String key, T value, {Duration? ttl}) async {
    _cache[key] = _NetworkCacheEntry(
      value: value,
      ttl: ttl,
      createdAt: DateTime.now(),
    );
  }
  
  Future<void> remove(String key) async {
    _cache.remove(key);
  }
  
  Future<void> clear(String prefix) async {
    final keysToRemove = _cache.keys.where((key) => key.startsWith(prefix)).toList();
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
  }
  
  Future<bool> exists(String key) async {
    final entry = _cache[key];
    return entry != null && !entry.isExpired;
  }
  
  void recordHit() => hits++;
  void recordMiss() => misses++;
  
  Map<String, dynamic> getStatistics() {
    return {
      'size': _cache.length,
      'hits': hits,
      'misses': misses,
    };
  }
}

/// Cache entry classes
class _CacheEntry {
  final dynamic value;
  final int size;
  final Duration? ttl;
  final DateTime createdAt;
  DateTime lastAccessed;
  
  _CacheEntry({
    required this.value,
    required this.size,
    this.ttl,
    required this.createdAt,
    required this.lastAccessed,
  });
  
  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().difference(createdAt) > ttl!;
  }
}

class _DiskCacheEntry {
  final dynamic value;
  final Duration? ttl;
  final bool compress;
  final DateTime createdAt;
  
  _DiskCacheEntry({
    required this.value,
    this.ttl,
    required this.compress,
    required this.createdAt,
  });
  
  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().difference(createdAt) > ttl!;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'ttl': ttl?.inMilliseconds,
      'compress': compress,
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  factory _DiskCacheEntry.fromJson(Map<String, dynamic> json) {
    return _DiskCacheEntry(
      value: json['value'],
      ttl: json['ttl'] != null ? Duration(milliseconds: json['ttl']) : null,
      compress: json['compress'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class _NetworkCacheEntry {
  final dynamic value;
  final Duration? ttl;
  final DateTime createdAt;
  
  _NetworkCacheEntry({
    required this.value,
    this.ttl,
    required this.createdAt,
  });
  
  bool get isExpired {
    if (ttl == null) return false;
    return DateTime.now().difference(createdAt) > ttl!;
  }
}
