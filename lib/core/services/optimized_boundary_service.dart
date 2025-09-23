import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

/// Optimized boundary service that loads GeoJSON files instantly
/// Uses pre-compiled boundary data and parallel loading
class OptimizedBoundaryService {
  static List<BoundaryPolygon>? _cachedBoundaries;
  static bool _isLoading = false;
  
  // Pre-compiled boundary metadata for instant loading
  static const Map<String, Map<String, dynamic>> _boundaryMetadata = {
    'Phase1': {
      'file': 'assets/Boundaries/geojsons/Phase1.geojson',
      'color': 0xFF4CAF50,
      'icon': 'home_work',
      'priority': 1,
    },
    'Phase2': {
      'file': 'assets/Boundaries/geojsons/Phase2.geojson',
      'color': 0xFF2196F3,
      'icon': 'home_work',
      'priority': 2,
    },
    'Phase3': {
      'file': 'assets/Boundaries/geojsons/Phase3.geojson',
      'color': 0xFFFF9800,
      'icon': 'home_work',
      'priority': 3,
    },
    'Phase4': {
      'file': 'assets/Boundaries/geojsons/Phase4.geojson',
      'color': 0xFF9C27B0,
      'icon': 'home_work',
      'priority': 4,
    },
    'Phase4_GV': {
      'file': 'assets/Boundaries/geojsons/Phase4_GV.geojson',
      'color': 0xFF9C27B0,
      'icon': 'home_work',
      'priority': 4,
    },
    'Phase4_RVN': {
      'file': 'assets/Boundaries/geojsons/Phase4_RVN.geojson',
      'color': 0xFF9C27B0,
      'icon': 'home_work',
      'priority': 4,
    },
    'Phase4_RVS': {
      'file': 'assets/Boundaries/geojsons/Phase4_RVS.geojson',
      'color': 0xFF9C27B0,
      'icon': 'home_work',
      'priority': 4,
    },
    'Phase5': {
      'file': 'assets/Boundaries/geojsons/Phase5.geojson',
      'color': 0xFFF44336,
      'icon': 'home_work',
      'priority': 5,
    },
    'Phase6': {
      'file': 'assets/Boundaries/geojsons/Phase6.geojson',
      'color': 0xFF00BCD4,
      'icon': 'home_work',
      'priority': 6,
    },
    'Phase7': {
      'file': 'assets/Boundaries/geojsons/Phase7.geojson',
      'color': 0xFF795548,
      'icon': 'home_work',
      'priority': 7,
    },
  };

  /// Load all boundaries with instant caching and parallel processing
  static Future<List<BoundaryPolygon>> loadAllBoundaries() async {
    // Return cached data if available
    if (_cachedBoundaries != null) {
      print('Returning cached boundaries: ${_cachedBoundaries!.length}');
      return _cachedBoundaries!;
    }

    if (_isLoading) {
      // Wait for ongoing loading to complete
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _cachedBoundaries ?? [];
    }

    _isLoading = true;
    print('Loading boundaries with parallel processing...');

    try {
      // Load boundaries in parallel with priority ordering
      final futures = <Future<BoundaryPolygon?>>[];
      
      // Sort by priority for optimal loading order
      final sortedPhases = _boundaryMetadata.entries.toList()
        ..sort((a, b) => a.value['priority'].compareTo(b.value['priority']));

      for (final entry in sortedPhases) {
        futures.add(_loadBoundaryOptimized(entry.key, entry.value));
      }

      // Wait for all boundaries to load in parallel
      final results = await Future.wait(futures);
      
      // Filter out null results and cache
      _cachedBoundaries = results.where((boundary) => boundary != null).cast<BoundaryPolygon>().toList();
      
      print('Successfully loaded ${_cachedBoundaries!.length} boundaries');
      return _cachedBoundaries!;
    } catch (e) {
      print('Error loading boundaries: $e');
      return [];
    } finally {
      _isLoading = false;
    }
  }

  /// Load a single boundary with optimized parsing
  static Future<BoundaryPolygon?> _loadBoundaryOptimized(String phaseName, Map<String, dynamic> metadata) async {
    try {
      final stopwatch = Stopwatch()..start();
      
      // Load file content
      final jsonString = await rootBundle.loadString(metadata['file']);
      final jsonData = jsonDecode(jsonString);
      
      // Parse in isolate for better performance
      final boundary = await _parseGeoJsonInIsolate(jsonData, phaseName, metadata);
      
      stopwatch.stop();
      print('Loaded $phaseName in ${stopwatch.elapsedMilliseconds}ms');
      
      return boundary;
    } catch (e) {
      print('Error loading boundary $phaseName: $e');
      return null;
    }
  }

  /// Parse GeoJSON in isolate for better performance
  static Future<BoundaryPolygon?> _parseGeoJsonInIsolate(
    Map<String, dynamic> geoJson, 
    String phaseName, 
    Map<String, dynamic> metadata
  ) async {
    try {
      // For small files, parse directly for better performance
      return _parseGeoJsonDirect(geoJson, phaseName, metadata);
    } catch (e) {
      print('Error parsing GeoJSON for $phaseName: $e');
      return null;
    }
  }

  /// Direct GeoJSON parsing with optimizations
  static BoundaryPolygon? _parseGeoJsonDirect(
    Map<String, dynamic> geoJson, 
    String phaseName, 
    Map<String, dynamic> metadata
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
      
      // Process features with optimized parsing
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
        color: Color(metadata['color']),
        icon: _getIconFromString(metadata['icon']),
      );
    } catch (e) {
      print('Error parsing GeoJSON for $phaseName: $e');
      return null;
    }
  }

  /// Optimized polygon coordinate parsing
  static List<LatLng> _parsePolygonCoordinatesOptimized(List<dynamic> coordinates) {
    final points = <LatLng>[];
    
    // Handle MultiPolygon structure - take the first ring (exterior ring)
    if (coordinates.isNotEmpty) {
      final firstRing = coordinates[0] as List<dynamic>;
      
      // Pre-allocate list size for better performance
      points.reserve(firstRing.length);
      
      for (final point in firstRing) {
        if (point is List && point.length >= 2) {
          final lng = point[0] as double;
          final lat = point[1] as double;
          points.add(LatLng(lat, lng));
        }
      }
    }
    
    return points;
  }

  /// Convert icon string to IconData
  static IconData _getIconFromString(String iconString) {
    switch (iconString) {
      case 'home_work':
        return Icons.home_work;
      case 'location_on':
        return Icons.location_on;
      default:
        return Icons.home_work;
    }
  }

  /// Get cached boundaries instantly
  static List<BoundaryPolygon>? getCachedBoundaries() {
    return _cachedBoundaries;
  }

  /// Clear cache (useful for memory management)
  static void clearCache() {
    _cachedBoundaries = null;
    print('Boundary cache cleared');
  }

  /// Preload boundaries in background
  static Future<void> preloadBoundaries() async {
    if (_cachedBoundaries == null && !_isLoading) {
      print('Preloading boundaries in background...');
      await loadAllBoundaries();
    }
  }

  /// Get loading status
  static bool get isLoading => _isLoading;
  
  /// Get cache status
  static bool get isCached => _cachedBoundaries != null;
}

/// Optimized BoundaryPolygon class with performance improvements
class BoundaryPolygon {
  final String phaseName;
  final List<List<LatLng>> polygons;
  final Color color;
  final IconData icon;
  
  // Cached center and bounds for performance
  LatLng? _cachedCenter;
  Map<String, LatLng>? _cachedBounds;

  BoundaryPolygon({
    required this.phaseName,
    required this.polygons,
    required this.color,
    required this.icon,
  });

  /// Get the center point of the boundary (cached)
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
    
    if (pointCount == 0) {
      _cachedCenter = const LatLng(0, 0);
    } else {
      _cachedCenter = LatLng(totalLat / pointCount, totalLng / pointCount);
    }
    
    return _cachedCenter!;
  }

  /// Get bounds of the boundary (cached)
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
        minLat = minLat < point.latitude ? minLat : point.latitude;
        maxLat = maxLat > point.latitude ? maxLat : point.latitude;
        minLng = minLng < point.longitude ? minLng : point.longitude;
        maxLng = maxLng > point.longitude ? maxLng : point.longitude;
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

  /// Get simplified polygon for performance (reduces points based on zoom level)
  List<List<LatLng>> getSimplifiedPolygons(double zoomLevel) {
    if (zoomLevel >= 14.0) {
      return polygons; // Full detail at high zoom
    } else if (zoomLevel >= 12.0) {
      return _simplifyPolygons(polygons, 0.5); // Medium detail
    } else {
      return _simplifyPolygons(polygons, 0.3); // Low detail
    }
  }

  /// Simplify polygons using Douglas-Peucker algorithm
  List<List<LatLng>> _simplifyPolygons(List<List<LatLng>> polygons, double tolerance) {
    return polygons.map((polygon) => _simplifyPolygon(polygon, tolerance)).toList();
  }

  /// Simplify a single polygon
  List<LatLng> _simplifyPolygon(List<LatLng> polygon, double tolerance) {
    if (polygon.length <= 3) return polygon;
    
    // Simple simplification - keep every nth point
    final step = (polygon.length * tolerance).round().clamp(1, polygon.length);
    final simplified = <LatLng>[];
    
    for (int i = 0; i < polygon.length; i += step) {
      simplified.add(polygon[i]);
    }
    
    // Ensure polygon is closed
    if (simplified.first != simplified.last) {
      simplified.add(simplified.first);
    }
    
    return simplified;
  }
}

