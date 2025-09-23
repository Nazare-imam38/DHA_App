import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AmenitiesMarkerService {
  static const String _amenitiesFile = 'assets/Boundaries/geojsons/Amenities.geojson';
  
  // Icon mapping for different amenity types
  static const Map<String, IconData> _amenityIcons = {
    'Park': Icons.park,
    'Masjid': Icons.mosque,
    'School': Icons.school,
    'Play Ground': Icons.sports_soccer,
    'Graveyard': Icons.place,
    'Petrol Pump': Icons.local_gas_station,
    'Health Facility': Icons.local_hospital,
  };

  // Color mapping for different amenity types
  static const Map<String, Color> _amenityColors = {
    'Park': Colors.green,
    'Masjid': Colors.blue,
    'School': Colors.orange,
    'Play Ground': Colors.lightGreen,
    'Graveyard': Colors.brown,
    'Petrol Pump': Colors.amber,
    'Health Facility': Colors.red,
  };

  /// Load amenities and convert them to markers
  static Future<List<AmenityMarker>> loadAmenitiesMarkers() async {
    try {
      final jsonString = await rootBundle.loadString(_amenitiesFile);
      final jsonData = jsonDecode(jsonString);
      
      return _parseAmenitiesToMarkers(jsonData);
    } catch (e) {
      print('Error loading amenities: $e');
      return [];
    }
  }

  /// Get filtered markers based on zoom level
  static List<Marker> getFilteredMarkers(List<AmenityMarker> amenityMarkers, double zoomLevel) {
    if (zoomLevel < 10.0) {
      return []; // Don't show amenities below zoom level 10
    }
    
    return amenityMarkers.map((amenityMarker) => amenityMarker.marker).toList();
  }

  /// Parse GeoJSON amenities data and convert to markers
  static List<AmenityMarker> _parseAmenitiesToMarkers(Map<String, dynamic> geoJson) {
    final amenityMarkers = <AmenityMarker>[];
    
    try {
      if (geoJson['type'] != 'FeatureCollection') {
        print('Invalid GeoJSON type: ${geoJson['type']}');
        return amenityMarkers;
      }

      final features = geoJson['features'] as List<dynamic>;
      
      for (final feature in features) {
        final properties = feature['properties'] as Map<String, dynamic>;
        final geometry = feature['geometry'] as Map<String, dynamic>;
        
        final amenityType = properties['Type'] as String?;
        final phase = properties['Phase'] as String?;
        if (amenityType == null) continue;
        
        final coordinates = geometry['coordinates'] as List<dynamic>;
        
        if (geometry['type'] == 'MultiPolygon') {
          for (final polygon in coordinates) {
            final polygonCoords = _parsePolygonCoordinates(polygon as List<dynamic>);
            if (polygonCoords.isNotEmpty) {
              final center = _calculatePolygonCenter(polygonCoords);
              final amenityMarker = _createAmenityMarkerWithInfo(center, amenityType, phase);
              if (amenityMarker != null) {
                amenityMarkers.add(amenityMarker);
              }
            }
          }
        } else if (geometry['type'] == 'Polygon') {
          final polygonCoords = _parsePolygonCoordinates(coordinates);
          if (polygonCoords.isNotEmpty) {
            final center = _calculatePolygonCenter(polygonCoords);
            final amenityMarker = _createAmenityMarkerWithInfo(center, amenityType, phase);
            if (amenityMarker != null) {
              amenityMarkers.add(amenityMarker);
            }
          }
        }
      }
    } catch (e) {
      print('Error parsing amenities: $e');
    }
    
    return amenityMarkers;
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

  /// Calculate the center point of a polygon
  static LatLng _calculatePolygonCenter(List<LatLng> points) {
    if (points.isEmpty) return const LatLng(0, 0);
    
    double totalLat = 0;
    double totalLng = 0;
    
    for (final point in points) {
      totalLat += point.latitude;
      totalLng += point.longitude;
    }
    
    return LatLng(totalLat / points.length, totalLng / points.length);
  }

  /// Create a marker for an amenity
  static Marker? _createAmenityMarker(LatLng point, String amenityType) {
    final icon = _amenityIcons[amenityType];
    final color = _amenityColors[amenityType];
    
    if (icon == null || color == null) {
      print('Unknown amenity type: $amenityType');
      return null;
    }

    return Marker(
      point: point,
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
    );
  }

  /// Create an amenity marker with information
  static AmenityMarker? _createAmenityMarkerWithInfo(LatLng point, String amenityType, String? phase) {
    final icon = _amenityIcons[amenityType];
    final color = _amenityColors[amenityType];
    
    if (icon == null || color == null) {
      print('Unknown amenity type: $amenityType');
      return null;
    }

      final marker = Marker(
        point: point,
        width: 28,
        height: 28,
        child: GestureDetector(
          onTap: () {
            // This will be handled by the parent widget
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
        ),
      );

    return AmenityMarker(
      marker: marker,
      amenityType: amenityType,
      phase: phase ?? 'Unknown',
      point: point,
    );
  }

  /// Get icon for amenity type
  static IconData? getAmenityIcon(String amenityType) {
    return _amenityIcons[amenityType];
  }

  /// Get color for amenity type
  static Color? getAmenityColor(String amenityType) {
    return _amenityColors[amenityType];
  }

  /// Get all available amenity types
  static List<String> getAvailableAmenityTypes() {
    return _amenityIcons.keys.toList();
  }

  /// Create a custom marker with specific styling
  static Marker createCustomAmenityMarker({
    required LatLng point,
    required String amenityType,
    double size = 40,
    Color? backgroundColor,
    Color? iconColor,
    double iconSize = 24,
  }) {
    final icon = _amenityIcons[amenityType] ?? Icons.location_on;
    final color = iconColor ?? _amenityColors[amenityType] ?? Colors.grey;
    final bgColor = backgroundColor ?? Colors.white;

    return Marker(
      point: point,
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(size / 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: color,
          size: iconSize,
        ),
      ),
    );
  }
}

class AmenityMarker {
  final Marker marker;
  final String amenityType;
  final String phase;
  final LatLng point;

  AmenityMarker({
    required this.marker,
    required this.amenityType,
    required this.phase,
    required this.point,
  });
}
