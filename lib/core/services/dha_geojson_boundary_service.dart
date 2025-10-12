import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';

/// DHA GeoJSON Boundary Service - High Performance
/// Uses the DHA_topo.geojson file for optimized boundary loading
class DhaGeoJSONBoundaryService {
  static List<BoundaryPolygon>? _cachedBoundaries;

  /// Load all DHA boundaries from DHA_topo.geojson
  static Future<List<BoundaryPolygon>> loadDhaBoundaries() async {
    // Return cached boundaries if available
    if (_cachedBoundaries != null) {
      print('✅ Using cached DHA boundaries: ${_cachedBoundaries!.length} phases');
      return _cachedBoundaries!;
    }

    try {
      print('🔄 Loading DHA boundaries from DHA_topo.geojson...');
      final boundaries = await _loadDhaGeoJSONFile();
      
      // Cache the results
      _cachedBoundaries = boundaries;
      
      print('✅ DHA GeoJSON loading: ${boundaries.length} boundary polygons loaded');
      return boundaries;
      
    } catch (e) {
      print('❌ Error loading DHA boundaries: $e');
      return [];
    }
  }

  /// Load and parse DHA_topo.geojson file
  static Future<List<BoundaryPolygon>> _loadDhaGeoJSONFile() async {
    try {
      final jsonString = await rootBundle.loadString('assets/Boundaries/geojsons/DHA_topo.geojson');
      print('✅ GeoJSON file loaded, length: ${jsonString.length}');
      final jsonData = json.decode(jsonString);
      
      // Debug: Print JSON structure
      print('🔍 JSON keys: ${jsonData.keys.toList()}');
      if (jsonData.containsKey('features')) {
        print('✅ Found features array with ${(jsonData['features'] as List).length} features');
      } else {
        print('❌ No features array found in JSON');
      }
      
      return _parseDhaGeoJSON(jsonData);
    } catch (e) {
      print('❌ Error loading DHA GeoJSON file: $e');
      rethrow;
    }
  }

  /// Parse DHA GeoJSON data
  static List<BoundaryPolygon> _parseDhaGeoJSON(Map<String, dynamic> jsonData) {
    final boundaries = <BoundaryPolygon>[];
    
    try {
      final features = jsonData['features'] as List<dynamic>?;
      if (features == null) return boundaries;
      
      print('🔄 Processing ${features.length} DHA features...');
      
      for (final feature in features) {
        final featureData = feature as Map<String, dynamic>;
        final properties = featureData['properties'] as Map<String, dynamic>?;
        final geometry = featureData['geometry'] as Map<String, dynamic>?;
        
        if (properties == null || geometry == null) continue;
        
        final phase = properties['Phase'] as String?;
        if (phase == null) continue;
        
        print('🔄 Processing DHA phase: $phase');
        print('🔍 Geometry type: ${geometry['type']}');
        
        // Convert geometry to polygons
        final polygons = _convertDhaGeometry(geometry);
        print('📍 Generated ${polygons.length} polygons for $phase');
        
        if (polygons.isNotEmpty) {
          boundaries.add(BoundaryPolygon(
            phaseName: phase,
            polygons: polygons,
            color: _getPhaseColor(phase),
            icon: _getPhaseIcon(phase),
          ));
          print('✅ Added DHA boundary for $phase with ${polygons.length} polygons');
          // Debug: Print first polygon coordinates
          if (polygons.isNotEmpty && polygons.first.isNotEmpty) {
            final firstPoint = polygons.first.first;
            print('📍 First point for $phase: Lat=${firstPoint.latitude}, Lng=${firstPoint.longitude}');
          }
        } else {
          print('⚠️ No polygons generated for $phase');
        }
      }
      
    } catch (e) {
      print('❌ Error parsing DHA GeoJSON: $e');
    }
    
    // Debug: Print summary of loaded phases
    print('📊 DHA GeoJSON Parsing Summary:');
    print('   Total boundaries loaded: ${boundaries.length}');
    for (final boundary in boundaries) {
      print('   ✅ $boundary.phaseName: ${boundary.polygons.length} polygons');
    }
    
    return boundaries;
  }

  /// Convert DHA geometry to polygon coordinates
  static List<List<LatLng>> _convertDhaGeometry(Map<String, dynamic> geometry) {
    final polygons = <List<LatLng>>[];
    
    try {
      final geometryType = geometry['type'] as String?;
      final coordinates = geometry['coordinates'] as dynamic;
      
      print('🔍 Processing geometry type: $geometryType');
      
      if (geometryType == 'Polygon') {
        // Single polygon - coordinates is List<List<List<double>>> (polygon with rings)
        print('📍 Processing single Polygon');
        final polygonCoords = coordinates as List<dynamic>;
        print('🔍 Polygon has ${polygonCoords.length} rings');
        
        // For Polygon, we want the first ring (exterior ring)
        if (polygonCoords.isNotEmpty) {
          final exteriorRing = polygonCoords[0] as List<dynamic>;
          final ringCoords = _convertPolygonCoordinates(exteriorRing);
          if (ringCoords.isNotEmpty) {
            polygons.add(ringCoords);
            print('✅ Added Polygon with ${ringCoords.length} points');
          }
        }
      } else if (geometryType == 'MultiPolygon') {
        // Multiple polygons - coordinates is List<List<List<List<double>>>>
        print('📍 Processing MultiPolygon');
        final multiPolygonCoords = coordinates as List<dynamic>;
        print('🔍 MultiPolygon has ${multiPolygonCoords.length} polygon groups');
        
        // Robust parser with double loop for all nesting cases
        for (final polygonGroup in multiPolygonCoords) {
          for (final ring in polygonGroup) {
            final polygonCoords = _convertPolygonCoordinates(ring);
            if (polygonCoords.isNotEmpty) {
              polygons.add(polygonCoords);
              print('✅ Added MultiPolygon ring with ${polygonCoords.length} points');
            }
          }
        }
      }
      
    } catch (e) {
      print('❌ Error converting DHA geometry: $e');
    }
    
    return polygons;
  }

  /// Convert polygon coordinates to LatLng list (already WGS84 format)
  static List<LatLng> _convertPolygonCoordinates(dynamic coordinates) {
    final points = <LatLng>[];
    
    try {
      final coordList = coordinates as List<dynamic>;
      print('🔍 Converting ${coordList.length} WGS84 coordinates to LatLng');
      
      for (int i = 0; i < coordList.length; i++) {
        final coord = coordList[i];
        final coordPair = coord as List<dynamic>;
        final longitude = coordPair[0] as double; // First value is longitude
        final latitude = coordPair[1] as double;  // Second value is latitude
        
        // Coordinates are already in WGS84 format (longitude, latitude)
        final latLng = LatLng(latitude, longitude);
        points.add(latLng);
        
        if (i < 5) { // Log first 5 points for debugging
          print('🧭 WGS84 Input: Lon=$longitude, Lat=$latitude → LatLng: ${latLng.latitude}, ${latLng.longitude}');
          
          // Validate coordinates are in Islamabad region
          if (latLng.latitude > 33.0 && latLng.latitude < 34.0 && 
              latLng.longitude > 72.0 && latLng.longitude < 74.0) {
            print('✅ Coordinates are in Islamabad region');
          } else {
            print('⚠️ Coordinates may be outside Islamabad region');
          }
        }
      }
      
      print('✅ Converted ${points.length} WGS84 coordinates to LatLng');
      
      // Debug: Check if coordinates are in the right area
      if (points.isNotEmpty) {
        final firstPoint = points.first;
        print('🎯 First converted point: Lat=${firstPoint.latitude}, Lng=${firstPoint.longitude}');
      }
      
    } catch (e) {
      print('❌ Error converting polygon coordinates: $e');
    }
    
    return points;
  }

  /// Get phase color
  static Color _getPhaseColor(String phase) {
    switch (phase.toLowerCase()) {
      case 'phase 1':
        return const Color(0xFF4CAF50); // Green
      case 'phase 2':
        return const Color(0xFF2196F3); // Blue
      case 'phase 3':
        return const Color(0xFFFF9800); // Orange
      case 'phase 4':
        return const Color(0xFF9C27B0); // Purple
      case 'phase 4_gv':
        return const Color(0xFFE91E63); // Pink
      case 'phase 4_rvn':
        return const Color(0xFF795548); // Brown
      case 'phase 4_rvs':
        return const Color(0xFF607D8B); // Blue Grey
      case 'phase 5':
        return const Color(0xFF00BCD4); // Cyan
      case 'phase 6':
        return const Color(0xFFFF5722); // Deep Orange
      case 'phase 7':
        return const Color(0xFF3F51B5); // Indigo
      default:
        return const Color(0xFF757575); // Grey
    }
  }

  /// Get phase icon
  static IconData _getPhaseIcon(String phase) {
    switch (phase.toLowerCase()) {
      case 'phase 1':
        return Icons.home;
      case 'phase 2':
        return Icons.location_city;
      case 'phase 3':
        return Icons.apartment;
      case 'phase 4':
        return Icons.business;
      case 'phase 4_gv':
        return Icons.villa;
      case 'phase 4_rvn':
        return Icons.house;
      case 'phase 4_rvs':
        return Icons.home_work;
      case 'phase 5':
        return Icons.domain;
      case 'phase 6':
        return Icons.business_center;
      case 'phase 7':
        return Icons.corporate_fare;
      default:
        return Icons.location_on;
    }
  }
}

/// Boundary polygon model for DHA phases
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
}
