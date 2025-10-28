import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

/// MapTiler API Boundary Service
/// Fetches boundary data from MapTiler API endpoints instead of local GeoJSON files
/// This improves performance by reducing app bundle size and enabling dynamic updates
class MapTilerBoundaryService {
  static const String _apiKey = 'sLbV8i7mevpHxpBO0R4c';
  static const String _baseUrl = 'https://api.maptiler.com/data';
  
  // MapTiler dataset IDs for different phases
  static const Map<String, String> _phaseDatasets = {
    'Phase1': '0199c78c-7608-7c9c-9f37-829f6e855976',
    'Phase2': '0199c78d-17c1-72cc-938e-91055a6ac1c9',
    'Phase3': '0199c790-7caa-797d-843c-38cfe260604b',
    'Phase4': '0199c794-25e7-7ca4-8e88-1f5852f96b51',
    'Phase4_GV': '0199c794-9c99-7831-8b0e-4927de2c9b8a',
    'Phase4_RVN': '0199c794-ff1e-7c52-bd07-45305f747039',
    'Phase4_RVS': '0199c796-b04a-7204-9990-54d9bb65c30e',
    'Phase5': '0199c797-495f-7d85-9965-79977c5334c4',
    'Phase6': '0199c797-eafc-7dfc-b64e-cdfd0104b6cf',
    'Phase7': '0199c799-7326-79bf-aea5-4365b5559c18',
  };

  // Phase colors and icons (same as existing system)
  static final Map<String, Color> _phaseColors = {
    'Phase1': const Color(0xFF4CAF50), // Green
    'Phase2': const Color(0xFF2196F3), // Blue
    'Phase3': const Color(0xFFFF9800), // Orange
    'Phase4': const Color(0xFF9C27B0), // Purple
    'Phase4_GV': const Color(0xFF9C27B0), // Purple variant
    'Phase4_RVN': const Color(0xFF9C27B0), // Purple variant
    'Phase4_RVS': const Color(0xFF9C27B0), // Purple variant
    'Phase5': const Color(0xFFF44336), // Red
    'Phase6': const Color(0xFF00BCD4), // Cyan
    'Phase7': const Color(0xFF795548), // Brown
  };

  static final Map<String, IconData> _phaseIcons = {
    'Phase1': Icons.work,
    'Phase2': Icons.work,
    'Phase3': Icons.work,
    'Phase4': Icons.work,
    'Phase4_GV': Icons.work,
    'Phase4_RVN': Icons.work,
    'Phase4_RVS': Icons.work,
    'Phase5': Icons.work,
    'Phase6': Icons.work,
    'Phase7': Icons.work,
  };

  // Cache for API responses
  static final Map<String, Map<String, dynamic>> _apiCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(hours: 24); // Cache for 24 hours

  /// Load all boundaries from MapTiler API
  static Future<List<BoundaryPolygon>> loadAllBoundaries() async {
    print('🗺️ MapTilerBoundaryService: Loading boundaries from MapTiler API...');
    
    final boundaries = <BoundaryPolygon>[];
    
    try {
      // Load all boundaries in parallel for maximum speed
      final futures = <Future<BoundaryPolygon?>>[];
      
      for (final entry in _phaseDatasets.entries) {
        futures.add(_loadBoundaryFromApi(entry.key, entry.value));
      }

      // Wait for all boundaries to load in parallel
      final results = await Future.wait(futures);
      
      // Filter out null results
      boundaries.addAll(results.where((boundary) => boundary != null).cast<BoundaryPolygon>());
      
      print('🗺️ MapTilerBoundaryService: Successfully loaded ${boundaries.length} boundaries from API');
      return boundaries;
    } catch (e) {
      print('❌ MapTilerBoundaryService: Error loading boundaries: $e');
      return [];
    }
  }

  /// Load a specific boundary from MapTiler API
  static Future<BoundaryPolygon?> _loadBoundaryFromApi(String phaseName, String datasetId) async {
    try {
      // Check cache first
      if (_isCached(phaseName)) {
        print('🗺️ MapTilerBoundaryService: Using cached data for $phaseName');
        return _parseCachedBoundary(phaseName);
      }

      print('🗺️ MapTilerBoundaryService: Fetching $phaseName from API...');
      
      final url = '$_baseUrl/$datasetId/features.json?key=$_apiKey';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        // Cache the response
        _apiCache[phaseName] = jsonData;
        _cacheTimestamps[phaseName] = DateTime.now();
        
        return _parseApiResponse(jsonData, phaseName);
      } else {
        print('❌ MapTilerBoundaryService: API error for $phaseName: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ MapTilerBoundaryService: Error loading $phaseName: $e');
      return null;
    }
  }

  /// Parse API response into BoundaryPolygon
  static BoundaryPolygon? _parseApiResponse(Map<String, dynamic> jsonData, String phaseName) {
    try {
      if (jsonData['type'] != 'FeatureCollection') {
        print('❌ Invalid GeoJSON type: ${jsonData['type']}');
        return null;
      }

      final features = jsonData['features'] as List<dynamic>;
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
            final polygonCoords = _parsePolygonCoordinates(polygon as List<dynamic>);
            if (polygonCoords.isNotEmpty) {
              polygons.add(polygonCoords);
            }
          }
        } else if (geometry['type'] == 'Polygon') {
          final polygonCoords = _parsePolygonCoordinates(coordinates);
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
        color: _phaseColors[phaseName] ?? const Color(0xFF9E9E9E),
        icon: _phaseIcons[phaseName] ?? Icons.place,
      );
    } catch (e) {
      print('❌ Error parsing API response for $phaseName: $e');
      return null;
    }
  }

  /// Parse cached boundary
  static BoundaryPolygon? _parseCachedBoundary(String phaseName) {
    final cachedData = _apiCache[phaseName];
    if (cachedData != null) {
      return _parseApiResponse(cachedData, phaseName);
    }
    return null;
  }

  /// Parse polygon coordinates from GeoJSON format
  static List<LatLng> _parsePolygonCoordinates(List<dynamic> coordinates) {
    final points = <LatLng>[];
    
    // Handle MultiPolygon structure - take the first ring (exterior ring)
    if (coordinates.isNotEmpty) {
      final firstRing = coordinates[0] as List<dynamic>;
      
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

  /// Check if data is cached and not expired
  static bool _isCached(String phaseName) {
    if (!_apiCache.containsKey(phaseName)) return false;
    
    final timestamp = _cacheTimestamps[phaseName];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }

  /// Get color for a specific phase
  static Color getPhaseColor(String phaseName) {
    return _phaseColors[phaseName] ?? const Color(0xFF9E9E9E);
  }

  /// Get icon for a specific phase
  static IconData getPhaseIcon(String phaseName) {
    return _phaseIcons[phaseName] ?? Icons.place;
  }

  /// Get all available phase names
  static List<String> getAvailablePhases() {
    return _phaseDatasets.keys.toList();
  }

  /// Clear API cache
  static void clearCache() {
    _apiCache.clear();
    _cacheTimestamps.clear();
    print('🗺️ MapTilerBoundaryService: API cache cleared');
  }

  /// Get cache statistics
  static Map<String, dynamic> getCacheStatistics() {
    return {
      'cached_phases': _apiCache.keys.toList(),
      'cache_size': _apiCache.length,
      'cache_timestamps': _cacheTimestamps.map((key, value) => MapEntry(key, value.toIso8601String())),
    };
  }

  /// Preload all boundaries for instant access
  static Future<void> preloadBoundaries() async {
    print('🗺️ MapTilerBoundaryService: Preloading boundaries...');
    await loadAllBoundaries();
  }
}

/// BoundaryPolygon class for MapTiler boundaries
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

  /// Get the center point of the boundary
  LatLng get center {
    if (polygons.isEmpty) return const LatLng(0, 0);
    
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
    
    if (pointCount == 0) return const LatLng(0, 0);
    
    return LatLng(totalLat / pointCount, totalLng / pointCount);
  }

  /// Get bounds of the boundary
  Map<String, LatLng> get bounds {
    if (polygons.isEmpty) {
      return {
        'north': const LatLng(0, 0),
        'south': const LatLng(0, 0),
        'east': const LatLng(0, 0),
        'west': const LatLng(0, 0),
      };
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
    
    return {
      'north': LatLng(maxLat, 0),
      'south': LatLng(minLat, 0),
      'east': LatLng(0, maxLng),
      'west': LatLng(0, minLng),
    };
  }
}
