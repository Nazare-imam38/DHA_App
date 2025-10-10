import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'unified_memory_cache.dart';

/// Enhanced MapTiler Boundary Service with Level 1 Memory Cache
/// Integrates MapTiler API with existing boundary system for optimal performance
class EnhancedMapTilerBoundaryService {
  static const String _cacheVersion = '3.0.0';
  static bool _isInitialized = false;
  static bool _isPreloading = false;
  
  // MapTiler API configuration
  static const String _apiKey = 'sLbV8i7mevpHxpBO0R4c';
  static const String _baseUrl = 'https://api.maptiler.com/data';
  

  // Pre-compiled boundary metadata for instant access
  static const Map<String, Map<String, dynamic>> _boundaryMetadata = {
    'Phase1': {
      'dataset_id': '0199c78c-7608-7c9c-9f37-829f6e855976',
      'color': 0xFF4CAF50,
      'icon': Icons.home_work,
      'priority': 1,
    },
    'Phase2': {
      'dataset_id': '0199c78d-17c1-72cc-938e-91055a6ac1c9',
      'color': 0xFF2196F3,
      'icon': Icons.home_work,
      'priority': 2,
    },
    'Phase3': {
      'dataset_id': '0199c790-7caa-797d-843c-38cfe260604b',
      'color': 0xFFFF9800,
      'icon': Icons.home_work,
      'priority': 3,
    },
    'Phase4': {
      'dataset_id': '0199c794-25e7-7ca4-8e88-1f5852f96b51',
      'color': 0xFF9C27B0,
      'icon': Icons.home_work,
      'priority': 4,
    },
    'Phase4_GV': {
      'dataset_id': '0199c794-9c99-7831-8b0e-4927de2c9b8a',
      'color': 0xFF9C27B0,
      'icon': Icons.home_work,
      'priority': 4,
    },
    'Phase4_RVN': {
      'dataset_id': '0199c794-ff1e-7c52-bd07-45305f747039',
      'color': 0xFF9C27B0,
      'icon': Icons.home_work,
      'priority': 4,
    },
    'Phase4_RVS': {
      'dataset_id': '0199c796-b04a-7204-9990-54d9bb65c30e',
      'color': 0xFF9C27B0,
      'icon': Icons.home_work,
      'priority': 4,
    },
    'Phase5': {
      'dataset_id': '0199c797-495f-7d85-9965-79977c5334c4',
      'color': 0xFFF44336,
      'icon': Icons.home_work,
      'priority': 5,
    },
    'Phase6': {
      'dataset_id': '0199c797-eafc-7dfc-b64e-cdfd0104b6cf',
      'color': 0xFF00BCD4,
      'icon': Icons.home_work,
      'priority': 6,
    },
    'Phase7': {
      'dataset_id': '0199c799-7326-79bf-aea5-4365b5559c18',
      'color': 0xFF795548,
      'icon': Icons.home_work,
      'priority': 7,
    },
  };

  /// Initialize the enhanced MapTiler boundary service
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isInitialized = true;
    print('🗺️ EnhancedMapTilerBoundaryService: Initializing with MapTiler API...');
    
    // Initialize memory cache
    await UnifiedMemoryCache.instance.initialize();
    
    // Check if boundaries are already cached
    final cachedBoundaries = UnifiedMemoryCache.instance.getBoundaries();
    if (cachedBoundaries != null && cachedBoundaries.isNotEmpty) {
      print('🗺️ EnhancedMapTilerBoundaryService: Found ${cachedBoundaries.length} cached boundaries');
      return;
    }
    
    // Start background preloading
    _preloadBoundariesInBackground();
  }
  
  /// Get boundaries with instant access from memory cache
  static List<BoundaryPolygon> getBoundariesInstantly() {
    final cachedBoundaries = UnifiedMemoryCache.instance.getBoundaries();
    if (cachedBoundaries != null && cachedBoundaries.isNotEmpty) {
      print('🗺️ EnhancedMapTilerBoundaryService: Returning ${cachedBoundaries.length} cached boundaries instantly');
      return cachedBoundaries;
    }
    
    print('🗺️ EnhancedMapTilerBoundaryService: No cached boundaries found, returning empty list');
    return <BoundaryPolygon>[];
  }
  
  /// Load all boundaries from MapTiler API with parallel processing and memory caching
  static Future<List<BoundaryPolygon>> loadAllBoundaries() async {
    // Check memory cache first
    final cachedBoundaries = UnifiedMemoryCache.instance.getBoundaries();
    if (cachedBoundaries != null && cachedBoundaries.isNotEmpty) {
      print('🗺️ EnhancedMapTilerBoundaryService: Returning ${cachedBoundaries.length} cached boundaries');
      return cachedBoundaries;
    }
    
    if (_isPreloading) {
      // Wait for background preloading to complete
      while (_isPreloading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      
      final finalCachedBoundaries = UnifiedMemoryCache.instance.getBoundaries();
      return finalCachedBoundaries ?? <BoundaryPolygon>[];
    }
    
    print('🗺️ EnhancedMapTilerBoundaryService: Loading boundaries from MapTiler API with parallel processing...');
    
    try {
      // Load all boundaries in parallel for maximum speed
      final futures = <Future<BoundaryPolygon?>>[];
      
      for (final entry in _boundaryMetadata.entries) {
        futures.add(_loadBoundaryFromApi(entry.key, entry.value));
      }

      // Wait for all boundaries to load in parallel
      final results = await Future.wait(futures);
      
      // Filter out null results
      final boundaries = results.where((boundary) => boundary != null).cast<BoundaryPolygon>().toList();
      
      // Store in memory cache for instant access
      await UnifiedMemoryCache.instance.storeBoundaries(boundaries);
      
      print('🗺️ EnhancedMapTilerBoundaryService: Successfully loaded and cached ${boundaries.length} boundaries from MapTiler API');
      return boundaries;
    } catch (e) {
      print('🗺️ EnhancedMapTilerBoundaryService: Error loading boundaries: $e');
      return <BoundaryPolygon>[];
    }
  }
  
  /// Load a single boundary from MapTiler API with optimized parsing and caching
  static Future<BoundaryPolygon?> _loadBoundaryFromApi(
    String phaseName, 
    Map<String, dynamic> metadata
  ) async {
    try {
      final datasetId = metadata['dataset_id'] as String;
      final colorValue = metadata['color'] as int;
      final icon = metadata['icon'] as IconData;
      
      // Check if already cached
      final cachedBoundary = UnifiedMemoryCache.instance.getBoundary(phaseName);
      if (cachedBoundary != null) {
        print('🗺️ EnhancedMapTilerBoundaryService: Using cached boundary for $phaseName');
        return cachedBoundary;
      }
      
      print('🗺️ EnhancedMapTilerBoundaryService: Fetching $phaseName from MapTiler API...');
      
      final url = '$_baseUrl/$datasetId/features.json?key=$_apiKey';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final boundary = _parseApiResponseOptimized(jsonData, phaseName, Color(colorValue), icon);
        
        // Cache the boundary for future access
        if (boundary != null) {
          await UnifiedMemoryCache.instance.store(
            'boundary_$phaseName',
            boundary,
            priority: CachePriority.critical,
          );
        }
        
        return boundary;
      } else {
        print('❌ EnhancedMapTilerBoundaryService: API error for $phaseName: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ EnhancedMapTilerBoundaryService: Error loading boundary $phaseName: $e');
      return null;
    }
  }

  /// Parse MapTiler API response with optimized performance
  static BoundaryPolygon? _parseApiResponseOptimized(
    Map<String, dynamic> geoJson, 
    String phaseName, 
    Color color, 
    IconData icon
  ) {
    try {
      if (geoJson['type'] != 'FeatureCollection') {
        print('❌ Invalid GeoJSON type: ${geoJson['type']}');
        return null;
      }

      final features = geoJson['features'] as List<dynamic>;
      if (features.isEmpty) {
        print('❌ No features found in API response for $phaseName');
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
        print('❌ No valid polygons found in API response for $phaseName');
        return null;
      }

      return BoundaryPolygon(
        phaseName: phaseName,
        polygons: polygons,
        color: color,
        icon: icon,
      );
    } catch (e) {
      print('❌ Error parsing API response for $phaseName: $e');
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
    print('🗺️ EnhancedMapTilerBoundaryService: Starting background preloading from MapTiler API...');
    
    Future.microtask(() async {
      try {
        await loadAllBoundaries();
        print('🗺️ EnhancedMapTilerBoundaryService: Background preloading completed');
      } catch (e) {
        print('🗺️ EnhancedMapTilerBoundaryService: Error in background preloading: $e');
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
    if (allBoundaries == null) return <BoundaryPolygon>[];
    
    return allBoundaries.where((boundary) {
      final metadata = _boundaryMetadata[boundary.phaseName];
      return metadata != null && metadata['priority'] == priority;
    }).toList();
  }
  
  /// Get boundaries within viewport bounds
  static List<BoundaryPolygon> getBoundariesInViewport(LatLngBounds viewportBounds) {
    final allBoundaries = UnifiedMemoryCache.instance.getBoundaries();
    if (allBoundaries == null) return <BoundaryPolygon>[];
    
    return allBoundaries.where((boundary) {
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
      'data_source': 'MapTiler API',
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
    
    print('🗺️ EnhancedMapTilerBoundaryService: Boundary cache cleared');
  }
  
  /// Preload boundaries for instant access
  static Future<void> preloadBoundaries() async {
    if (!isPreloaded && !_isPreloading) {
      print('🗺️ EnhancedMapTilerBoundaryService: Preloading boundaries from MapTiler API...');
      await loadAllBoundaries();
    }
  }

  /// Get color for a specific phase
  static Color getPhaseColor(String phaseName) {
    final metadata = _boundaryMetadata[phaseName];
    if (metadata != null) {
      return Color(metadata['color'] as int);
    }
    return const Color(0xFF9E9E9E);
  }

  /// Get icon for a specific phase
  static IconData getPhaseIcon(String phaseName) {
    final metadata = _boundaryMetadata[phaseName];
    if (metadata != null) {
      return metadata['icon'] as IconData;
    }
    return Icons.location_on;
  }

  /// Get all available phase names
  static List<String> getAvailablePhases() {
    return _boundaryMetadata.keys.toList();
  }
}
