import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

/// Instant boundary service that pre-loads and caches GeoJSON boundaries
/// for immediate display without loading delays
class InstantBoundaryService {
  static List<BoundaryPolygon>? _cachedBoundaries;
  static bool _isPreloaded = false;
  static bool _isLoading = false;
  
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

  /// Get boundaries instantly (returns cached data immediately)
  static List<BoundaryPolygon> getBoundariesInstantly() {
    if (_cachedBoundaries != null) {
      return _cachedBoundaries!;
    }
    
    // Return empty list if not loaded yet
    return [];
  }

  /// Load all boundaries with instant caching and parallel processing
  static Future<List<BoundaryPolygon>> loadAllBoundaries() async {
    // Return cached data instantly if available
    if (_cachedBoundaries != null) {
      print('InstantBoundaryService: Returning cached boundaries instantly');
      return _cachedBoundaries!;
    }

    if (_isLoading) {
      // Wait for ongoing loading to complete
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return _cachedBoundaries ?? [];
    }

    _isLoading = true;
    print('InstantBoundaryService: Loading boundaries with parallel processing...');

    try {
      // Load all boundaries in parallel for maximum speed
      final futures = <Future<BoundaryPolygon?>>[];
      
      for (final entry in _boundaryMetadata.entries) {
        futures.add(_loadBoundaryInstant(entry.key, entry.value));
      }

      // Wait for all boundaries to load in parallel
      final results = await Future.wait(futures);
      
      // Filter out null results and cache
      _cachedBoundaries = results.where((boundary) => boundary != null).cast<BoundaryPolygon>().toList();
      _isPreloaded = true;
      
      print('InstantBoundaryService: Successfully loaded ${_cachedBoundaries!.length} boundaries');
      return _cachedBoundaries!;
    } catch (e) {
      print('InstantBoundaryService: Error loading boundaries: $e');
      return [];
    } finally {
      _isLoading = false;
    }
  }

  /// Load a single boundary with optimized parsing
  static Future<BoundaryPolygon?> _loadBoundaryInstant(String phaseName, Map<String, dynamic> metadata) async {
    try {
      final filePath = metadata['file'] as String;
      final colorValue = metadata['color'] as int;
      final icon = metadata['icon'] as IconData;
      
      print('InstantBoundaryService: Loading $phaseName from $filePath');
      
      final jsonString = await rootBundle.loadString(filePath);
      final jsonData = jsonDecode(jsonString);
      
      return _parseGeoJsonInstant(jsonData, phaseName, Color(colorValue), icon);
    } catch (e) {
      print('InstantBoundaryService: Error loading boundary $phaseName: $e');
      return null;
    }
  }

  /// Parse GeoJSON data with optimized performance
  static BoundaryPolygon? _parseGeoJsonInstant(
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
            final polygonCoords = _parsePolygonCoordinatesInstant(polygon as List<dynamic>);
            if (polygonCoords.isNotEmpty) {
              polygons.add(polygonCoords);
            }
          }
        } else if (geometry['type'] == 'Polygon') {
          final polygonCoords = _parsePolygonCoordinatesInstant(coordinates);
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
  static List<LatLng> _parsePolygonCoordinatesInstant(List<dynamic> coordinates) {
    if (coordinates.isEmpty) return [];
    
    final firstRing = coordinates[0] as List<dynamic>;
    final points = <LatLng>[];
    
    // Pre-allocate list size for better performance
    // Note: Dart doesn't have reserve() method, but we can optimize by setting initial capacity
    
    for (final point in firstRing) {
      if (point is List && point.length >= 2) {
        final lng = point[0] as double;
        final lat = point[1] as double;
        points.add(LatLng(lat, lng));
      }
    }
    
    return points;
  }

  /// Preload boundaries in background for instant access
  static Future<void> preloadBoundaries() async {
    if (!_isPreloaded && !_isLoading) {
      print('InstantBoundaryService: Preloading boundaries in background...');
      await loadAllBoundaries();
    }
  }

  /// Get cached boundaries instantly (no loading)
  static List<BoundaryPolygon>? getCachedBoundaries() {
    return _cachedBoundaries;
  }

  /// Check if boundaries are preloaded
  static bool get isPreloaded => _isPreloaded;
  
  /// Check if boundaries are currently loading
  static bool get isLoading => _isLoading;

  /// Clear cache (useful for memory management)
  static void clearCache() {
    _cachedBoundaries = null;
    _isPreloaded = false;
    print('InstantBoundaryService: Cache cleared');
  }

  /// Get loading status
  static Map<String, dynamic> getLoadingStatus() {
    return {
      'is_preloaded': _isPreloaded,
      'is_loading': _isLoading,
      'cached_count': _cachedBoundaries?.length ?? 0,
    };
  }
}

/// Optimized BoundaryPolygon class with performance improvements
class BoundaryPolygon {
  final String phaseName;
  final List<List<LatLng>> polygons;
  final Color color;
  final IconData icon;

  BoundaryPolygon({
    required this.phaseName,
    required this.polygons,
    required this.color,
    required this.icon,
  });

  /// Get the center point of the boundary (cached for performance)
  LatLng? _cachedCenter;
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

  /// Get bounds of the boundary (cached for performance)
  Map<String, LatLng>? _cachedBounds;
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
}
