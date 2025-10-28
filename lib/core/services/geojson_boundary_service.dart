import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

class GeoJsonBoundaryService {
  static const Map<String, String> _boundaryFiles = {
    'Phase1': 'assets/Boundaries/geojsons/Phase1.geojson',
    'Phase2': 'assets/Boundaries/geojsons/Phase2.geojson',
    'Phase3': 'assets/Boundaries/geojsons/Phase3.geojson',
    'Phase4': 'assets/Boundaries/geojsons/Phase4.geojson',
    'Phase4_GV': 'assets/Boundaries/geojsons/Phase4_GV.geojson',
    'Phase4_RVN': 'assets/Boundaries/geojsons/Phase4_RVN.geojson',
    'Phase4_RVS': 'assets/Boundaries/geojsons/Phase4_RVS.geojson',
    'Phase5': 'assets/Boundaries/geojsons/Phase5.geojson',
    'Phase6': 'assets/Boundaries/geojsons/Phase6.geojson',
    'Phase7': 'assets/Boundaries/geojsons/Phase7.geojson',
    // 'Amenities': 'assets/Boundaries/geojsons/Amenities.geojson', // REMOVED: Amenities should be markers, not boundaries
  };

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
    // 'Amenities': const Color(0xFF607D8B), // REMOVED: Amenities should be markers, not boundaries
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
    // 'Amenities': Icons.location_city, // REMOVED: Amenities should be markers, not boundaries
  };

  /// Load all boundary files and return them as polygons
  static Future<List<BoundaryPolygon>> loadAllBoundaries() async {
    final boundaries = <BoundaryPolygon>[];
    
    for (final entry in _boundaryFiles.entries) {
      try {
        final boundary = await loadBoundary(entry.key);
        if (boundary != null) {
          boundaries.add(boundary);
        }
      } catch (e) {
        print('Error loading boundary ${entry.key}: $e');
      }
    }
    
    return boundaries;
  }

  /// Load a specific boundary file
  static Future<BoundaryPolygon?> loadBoundary(String phaseName) async {
    try {
      final filePath = _boundaryFiles[phaseName];
      if (filePath == null) {
        print('Boundary file not found for phase: $phaseName');
        return null;
      }

      final jsonString = await rootBundle.loadString(filePath);
      final jsonData = jsonDecode(jsonString);
      
      return _parseGeoJson(jsonData, phaseName);
    } catch (e) {
      print('Error loading boundary $phaseName: $e');
      return null;
    }
  }

  /// Parse GeoJSON data into BoundaryPolygon
  static BoundaryPolygon? _parseGeoJson(Map<String, dynamic> geoJson, String phaseName) {
    try {
      if (geoJson['type'] != 'FeatureCollection') {
        print('Invalid GeoJSON type: ${geoJson['type']}');
        return null;
      }

      final features = geoJson['features'] as List<dynamic>;
      if (features.isEmpty) {
        print('No features found in GeoJSON');
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
        print('No valid polygons found in GeoJSON');
        return null;
      }

      return BoundaryPolygon(
        phaseName: phaseName,
        polygons: polygons,
        color: _phaseColors[phaseName] ?? const Color(0xFF9E9E9E),
        icon: _phaseIcons[phaseName] ?? Icons.place,
      );
    } catch (e) {
      print('Error parsing GeoJSON for $phaseName: $e');
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
    return _boundaryFiles.keys.toList();
  }
}

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
