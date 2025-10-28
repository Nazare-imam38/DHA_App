import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'unified_memory_cache.dart';

/// Persistent Boundary Service - Boundaries never disappear
/// Simple service that keeps boundaries in memory permanently
class PersistentBoundaryService {
  static const String _apiKey = 'sLbV8i7mevpHxpBO0R4c';
  static const String _baseUrl = 'https://api.maptiler.com/data';
  
  // Static storage for boundaries - never cleared
  static List<BoundaryPolygon>? _persistentBoundaries;
  static bool _isLoading = false;
  static bool _hasLoadedOnce = false;
  
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

  // Phase colors and icons
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

  /// Get boundaries instantly - they persist in memory
  static List<BoundaryPolygon> getBoundariesInstantly() {
    if (_persistentBoundaries != null && _persistentBoundaries!.isNotEmpty) {
      print('🗺️ PersistentBoundaryService: Returning ${_persistentBoundaries!.length} persistent boundaries');
      return _persistentBoundaries!;
    }
    
    print('🗺️ PersistentBoundaryService: No persistent boundaries found');
    return [];
  }

  /// Load all boundaries from MapTiler API and store permanently
  static Future<List<BoundaryPolygon>> loadAllBoundaries() async {
    // Return cached boundaries if available
    if (_persistentBoundaries != null && _persistentBoundaries!.isNotEmpty) {
      print('🗺️ PersistentBoundaryService: Returning ${_persistentBoundaries!.length} cached boundaries (NO API CALL)');
      return _persistentBoundaries!;
    }

    // If we've already loaded once and failed, don't try again
    if (_hasLoadedOnce && (_persistentBoundaries == null || _persistentBoundaries!.isEmpty)) {
      print('🗺️ PersistentBoundaryService: Already attempted loading once, returning empty list');
      return [];
    }

    if (_isLoading) {
      print('🗺️ PersistentBoundaryService: Already loading, waiting for completion...');
      // Wait for loading to complete
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _persistentBoundaries ?? [];
    }

    _isLoading = true;
    _hasLoadedOnce = true;
    print('🗺️ PersistentBoundaryService: Loading boundaries from MapTiler API (FIRST TIME ONLY)...');

    try {
      final boundaries = <BoundaryPolygon>[];
      
      // Load all boundaries in parallel
      final futures = <Future<BoundaryPolygon?>>[];
      
      for (final entry in _phaseDatasets.entries) {
        futures.add(_loadBoundaryFromApi(entry.key, entry.value));
      }

      // Wait for all boundaries to load
      final results = await Future.wait(futures);
      
      // Filter out null results
      boundaries.addAll(results.where((boundary) => boundary != null).cast<BoundaryPolygon>());
      
      // Store permanently in static memory - never cleared
      _persistentBoundaries = boundaries;
      
      print('🗺️ PersistentBoundaryService: Successfully loaded and stored ${boundaries.length} boundaries permanently (NEVER LOAD AGAIN)');
      return boundaries;
    } catch (e) {
      print('❌ PersistentBoundaryService: Error loading boundaries: $e');
      return [];
    } finally {
      _isLoading = false;
    }
  }

  /// Load a single boundary from MapTiler API
  static Future<BoundaryPolygon?> _loadBoundaryFromApi(String phaseName, String datasetId) async {
    try {
      print('🗺️ PersistentBoundaryService: Fetching $phaseName from API...');
      
      final url = '$_baseUrl/$datasetId/features.json?key=$_apiKey';
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return _parseApiResponse(jsonData, phaseName);
      } else {
        print('❌ PersistentBoundaryService: API error for $phaseName: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ PersistentBoundaryService: Error loading $phaseName: $e');
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

  /// Check if boundaries are loaded
  static bool get isLoaded => _persistentBoundaries != null && _persistentBoundaries!.isNotEmpty;
  
  /// Check if boundaries have been attempted to load at least once
  static bool get hasAttemptedLoad => _hasLoadedOnce;
  
  /// Check if boundaries are currently loading
  static bool get isLoading => _isLoading;
  
  /// Get loading status
  static Map<String, dynamic> getLoadingStatus() {
    return {
      'is_loaded': isLoaded,
      'is_loading': _isLoading,
      'boundary_count': _persistentBoundaries?.length ?? 0,
      'data_source': 'MapTiler API (Persistent)',
    };
  }

  /// Force reload boundaries (useful for debugging)
  static Future<void> forceReload() async {
    _persistentBoundaries = null;
    await loadAllBoundaries();
  }

  /// Clear boundaries (only for debugging - not recommended)
  static void clearBoundaries() {
    _persistentBoundaries = null;
    print('🗺️ PersistentBoundaryService: Boundaries cleared (not recommended)');
  }
}
