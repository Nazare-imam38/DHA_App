import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'unified_memory_cache.dart';

/// Optimized Boundary Service with Level 1 Memory Cache
/// Provides instant access to boundary data while preserving all functionality
class OptimizedBoundaryService {
  static const String _cacheVersion = '2.0.0';
  static bool _isInitialized = false;
  static bool _isPreloading = false;
  
  // Pre-compiled boundary metadata for instant access
  static const Map<String, Map<String, dynamic>> _boundaryMetadata = {
    'Phase1': {
      'file': 'assets/Boundaries/geojsons/Phase1.geojson',
      'color': 0xFF4CAF50,
      'icon': Icons.home_work,
      'priority': 1,
    },
    'Phase2': {
      'file': 'assets/Boundaries/geojsons/Phase2.geojson',
      'color': 0xFF2196F3,
      'icon': Icons.home_work,
      'priority': 2,
    },
    'Phase3': {
      'file': 'assets/Boundaries/geojsons/Phase3.geojson',
      'color': 0xFFFF9800,
      'icon': Icons.home_work,
      'priority': 3,
    },
    'Phase4': {
      'file': 'assets/Boundaries/geojsons/Phase4.geojson',
      'color': 0xFF9C27B0,
      'icon': Icons.home_work,
      'priority': 4,
    },
    'Phase4_GV': {
      'file': 'assets/Boundaries/geojsons/Phase4_GV.geojson',
      'color': 0xFF9C27B0,
      'icon': Icons.home_work,
      'priority': 4,
    },
    'Phase4_RVN': {
      'file': 'assets/Boundaries/geojsons/Phase4_RVN.geojson',
      'color': 0xFF9C27B0,
      'icon': Icons.home_work,
      'priority': 4,
    },
    'Phase4_RVS': {
      'file': 'assets/Boundaries/geojsons/Phase4_RVS.geojson',
      'color': 0xFF9C27B0,
      'icon': Icons.home_work,
      'priority': 4,
    },
    'Phase5': {
      'file': 'assets/Boundaries/geojsons/Phase5.geojson',
      'color': 0xFFF44336,
      'icon': Icons.home_work,
      'priority': 5,
    },
    'Phase6': {
      'file': 'assets/Boundaries/geojsons/Phase6.geojson',
      'color': 0xFF00BCD4,
      'icon': Icons.home_work,
      'priority': 6,
    },
    'Phase7': {
      'file': 'assets/Boundaries/geojsons/Phase7.geojson',
      'color': 0xFF795548,
      'icon': Icons.home_work,
      'priority': 7,
    },
  };

  /// Initialize the optimized boundary service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isInitialized = true;
    print('🗺️ OptimizedBoundaryService: Initializing with memory cache...');
    
    // Initialize memory cache
    await UnifiedMemoryCache.instance.initialize();
    
    // Check if boundaries are already cached
    final cachedBoundaries = UnifiedMemoryCache.instance.getBoundaries();
    if (cachedBoundaries != null && cachedBoundaries.isNotEmpty) {
      print('🗺️ OptimizedBoundaryService: Found ${cachedBoundaries.length} cached boundaries');
      return;
    }
    
    // Start background preloading
    _preloadBoundariesInBackground();
  }
  
  /// Get boundaries with instant access from memory cache
  static List<BoundaryPolygon> getBoundariesInstantly() {
    final cachedBoundaries = UnifiedMemoryCache.instance.getBoundaries();
    if (cachedBoundaries != null && cachedBoundaries.isNotEmpty) {
      print('🗺️ OptimizedBoundaryService: Returning ${cachedBoundaries.length} cached boundaries instantly');
      return cachedBoundaries;
    }
    
    print('🗺️ OptimizedBoundaryService: No cached boundaries found, returning empty list');
    return [];
  }
  
  /// Load all boundaries with parallel processing and memory caching
  static Future<List<BoundaryPolygon>> loadAllBoundaries() async {
    // Check memory cache first
    final cachedBoundaries = UnifiedMemoryCache.instance.getBoundaries();
    if (cachedBoundaries != null && cachedBoundaries.isNotEmpty) {
      print('🗺️ OptimizedBoundaryService: Returning ${cachedBoundaries.length} cached boundaries');
      return cachedBoundaries;
    }
    
    if (_isPreloading) {
      // Wait for background preloading to complete
      while (_isPreloading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      
      final finalCachedBoundaries = UnifiedMemoryCache.instance.getBoundaries();
      return finalCachedBoundaries ?? [];
    }
    
    print('🗺️ OptimizedBoundaryService: Loading boundaries with parallel processing...');
    
    try {
      // Load all boundaries in parallel for maximum speed
      final futures = <Future<BoundaryPolygon?>>[];
      
      for (final entry in _boundaryMetadata.entries) {
        futures.add(_loadBoundaryOptimized(entry.key, entry.value));
      }

      // Wait for all boundaries to load in parallel
      final results = await Future.wait(futures);
      
      // Filter out null results
      final boundaries = results.where((boundary) => boundary != null).cast<BoundaryPolygon>().toList();
      
      // Store in memory cache for instant access
      await UnifiedMemoryCache.instance.storeBoundaries(boundaries);
      
      print('🗺️ OptimizedBoundaryService: Successfully loaded and cached ${boundaries.length} boundaries');
      return boundaries;
    } catch (e) {
      print('🗺️ OptimizedBoundaryService: Error loading boundaries: $e');
      return [];
    }
  }
  
  /// Load a single boundary with optimized parsing and caching
  static Future<BoundaryPolygon?> _loadBoundaryOptimized(
    String phaseName, 
    Map<String, dynamic> metadata
  ) async {
    try {
      final filePath = metadata['file'] as String;
      final colorValue = metadata['color'] as int;
      final icon = metadata['icon'] as IconData;
      
      // Check if already cached
      final cachedBoundary = UnifiedMemoryCache.instance.getBoundary(phaseName);
      if (cachedBoundary != null) {
        print('🗺️ OptimizedBoundaryService: Using cached boundary for $phaseName');
        return cachedBoundary;
      }
      
      print('🗺️ OptimizedBoundaryService: Loading $phaseName from $filePath');
      
      final jsonString = await rootBundle.loadString(filePath);
      final jsonData = jsonDecode(jsonString);
      
      final boundary = _parseGeoJsonOptimized(jsonData, phaseName, Color(colorValue), icon);
      
      // Cache the boundary for future access
      if (boundary != null) {
        await UnifiedMemoryCache.instance.store(
          'boundary_$phaseName',
          boundary,
          priority: CachePriority.critical,
        );
      }
      
      return boundary;
    } catch (e) {
      print('🗺️ OptimizedBoundaryService: Error loading boundary $phaseName: $e');
      return null;
    }
  }

  /// Parse GeoJSON data with optimized performance
  static BoundaryPolygon? _parseGeoJsonOptimized(
    Map<String, dynamic> geoJson, 
    String phaseName, 
    Color color, 
    IconData icon
  ) {
    try {
      if (geoJson['type'] != 'FeatureCollection') {
        print('Invalid GeoJSON type: ${geoJson['type']}');
        return null;
      }

      final features = geoJson['features'] as List<dynamic>;
      if (features.isEmpty) {
        print('No features found in GeoJSON for $phaseName');
        return null;
      }

      final polygons = <List<LatLng>>[];
      
      for (final feature in features) {
        final geometry = feature['geometry'] as Map<String, dynamic>;
        final coordinates = geometry['coordinates'] as List<dynamic>;
        
        if (geometry['type'] == 'MultiPolygon') {
          for (final polygon in coordinates) {
            final polygonCoords = _parsePolygonCoordinatesOptimized(polygon as List<dynamic>);
            if (polygonCoords.isNotEmpty) {
              polygons.add(polygonCoords);
            }
          }
        } else if (geometry['type'] == 'Polygon') {
          final polygonCoords = _parsePolygonCoordinatesOptimized(coordinates);
          if (polygonCoords.isNotEmpty) {
            polygons.add(polygonCoords);
          }
        }
      }

      if (polygons.isEmpty) {
        print('No valid polygons found in GeoJSON for $phaseName');
        return null;
      }

      return BoundaryPolygon(
        phaseName: phaseName,
        polygons: polygons,
        color: color,
        icon: icon,
      );
    } catch (e) {
      print('Error parsing GeoJSON for $phaseName: $e');
      return null;
    }
  }

  /// Optimized polygon coordinate parsing with pre-allocation
  static List<LatLng> _parsePolygonCoordinatesOptimized(List<dynamic> coordinates) {
    if (coordinates.isEmpty) return [];
    
    final firstRing = coordinates[0] as List<dynamic>;
    final points = <LatLng>[];
      
      // Pre-allocate list size for better performance
    points.length = firstRing.length;
      
    for (int i = 0; i < firstRing.length; i++) {
      final point = firstRing[i];
        if (point is List && point.length >= 2) {
          final lng = point[0] as double;
          final lat = point[1] as double;
        points[i] = LatLng(lat, lng);
      }
    }
    
    return points;
  }

  /// Preload boundaries in background for instant access
  static void _preloadBoundariesInBackground() {
    if (_isPreloading) return;
    
    _isPreloading = true;
    print('🗺️ OptimizedBoundaryService: Starting background preloading...');
    
    Future.microtask(() async {
      try {
      await loadAllBoundaries();
        print('🗺️ OptimizedBoundaryService: Background preloading completed');
      } catch (e) {
        print('🗺️ OptimizedBoundaryService: Error in background preloading: $e');
      } finally {
        _isPreloading = false;
      }
    });
  }
  
  /// Get specific boundary by phase name
  static BoundaryPolygon? getBoundaryByPhase(String phaseName) {
    return UnifiedMemoryCache.instance.getBoundary(phaseName);
  }
  
  /// Get boundaries by priority
  static List<BoundaryPolygon> getBoundariesByPriority(int priority) {
    final allBoundaries = UnifiedMemoryCache.instance.getBoundaries();
    if (allBoundaries == null) return [];
    
    return allBoundaries.where((boundary) {
      final metadata = _boundaryMetadata[boundary.phaseName];
      return metadata != null && metadata['priority'] == priority;
    }).toList();
  }
  
  /// Get boundaries within viewport bounds
  static List<BoundaryPolygon> getBoundariesInViewport(LatLngBounds viewportBounds) {
    final allBoundaries = UnifiedMemoryCache.instance.getBoundaries();
    if (allBoundaries == null) return [];
    
    return allBoundaries.where((boundary) {
      final bounds = boundary.bounds;
      // Simple bounds checking - check if boundary center is within viewport
      final center = boundary.center;
      return viewportBounds.contains(center);
    }).toList();
  }
  
  /// Check if boundaries are preloaded
  static bool get isPreloaded {
    final cachedBoundaries = UnifiedMemoryCache.instance.getBoundaries();
    return cachedBoundaries != null && cachedBoundaries.isNotEmpty;
  }
  
  /// Check if boundaries are currently loading
  static bool get isLoading => _isPreloading;
  
  /// Get loading status
  static Map<String, dynamic> getLoadingStatus() {
    final cachedBoundaries = UnifiedMemoryCache.instance.getBoundaries();
    return {
      'is_preloaded': isPreloaded,
      'is_loading': _isPreloading,
      'cached_count': cachedBoundaries?.length ?? 0,
      'cache_version': _cacheVersion,
    };
  }
  
  /// Get cache statistics
  static Map<String, dynamic> getCacheStatistics() {
    return UnifiedMemoryCache.instance.getStatistics();
  }
  
  /// Clear boundary cache (useful for memory management)
  static void clearCache() {
    UnifiedMemoryCache.instance.clear('boundaries_all');
    
    // Clear individual boundaries
    for (final phaseName in _boundaryMetadata.keys) {
      UnifiedMemoryCache.instance.clear('boundary_$phaseName');
    }
    
    print('🗺️ OptimizedBoundaryService: Boundary cache cleared');
  }
  
  /// Preload boundaries for instant access
  static Future<void> preloadBoundaries() async {
    if (!isPreloaded && !_isPreloading) {
      print('🗺️ OptimizedBoundaryService: Preloading boundaries...');
      await loadAllBoundaries();
    }
  }
}