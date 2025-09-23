import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Service to load and manage amenities from GeoJSON files
class AmenitiesGeoJsonService {
  static const String _amenitiesAssetPath = 'assets/Boundaries/geojsons/Amenities.geojson';
  
  static List<AmenityFeature> _amenities = [];
  static bool _isLoaded = false;
  
  /// Load amenities from GeoJSON file
  static Future<List<AmenityFeature>> loadAmenities() async {
    if (_isLoaded) return _amenities;
    
    try {
      // This method requires context, use loadAmenitiesWithContext instead
      print('Use loadAmenitiesWithContext method instead');
      return [];
    } catch (e) {
      print('Error loading amenities: $e');
      return [];
    }
  }
  
  /// Load amenities with context (alternative method)
  static Future<List<AmenityFeature>> loadAmenitiesWithContext(BuildContext context) async {
    print('=== GEOJSON SERVICE DEBUG ===');
    print('_isLoaded: $_isLoaded');
    print('_amenitiesAssetPath: $_amenitiesAssetPath');
    
    if (_isLoaded) {
      print('Amenities already loaded, returning ${_amenities.length} amenities');
      return _amenities;
    }
    
    try {
      print('Loading amenities from GeoJSON file...');
      final String jsonString = await DefaultAssetBundle.of(context).loadString(_amenitiesAssetPath);
      print('GeoJSON string length: ${jsonString.length}');
      
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      print('JSON data keys: ${jsonData.keys.toList()}');
      
      final List<dynamic> features = jsonData['features'] ?? [];
      print('Found ${features.length} features in GeoJSON');
      
      _amenities = [];
      for (int i = 0; i < features.length; i++) {
        try {
          final amenity = AmenityFeature.fromJson(features[i]);
          _amenities.add(amenity);
        } catch (e) {
          print('Error parsing feature $i: $e');
          // Continue with next feature
        }
      }
      _isLoaded = true;
      
      print('Successfully loaded ${_amenities.length} amenities from GeoJSON');
      print('=== GEOJSON SERVICE COMPLETE ===');
      return _amenities;
    } catch (e) {
      print('ERROR loading amenities: $e');
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }
  
  /// Get amenities filtered by type
  static List<AmenityFeature> getAmenitiesByType(String type) {
    return _amenities.where((amenity) => amenity.type.toLowerCase() == type.toLowerCase()).toList();
  }
  
  /// Get amenities filtered by phase
  static List<AmenityFeature> getAmenitiesByPhase(String phase) {
    return _amenities.where((amenity) => amenity.phase == phase).toList();
  }
  
  /// Get all amenities
  static List<AmenityFeature> getAllAmenities() {
    return List.from(_amenities);
  }
  
  /// Get amenities within a bounding box
  static List<AmenityFeature> getAmenitiesInBounds(LatLngBounds bounds) {
    return _amenities.where((amenity) {
      final center = amenity.center;
      return bounds.contains(center);
    }).toList();
  }
  
  /// Get amenities visible at a specific zoom level
  static List<AmenityFeature> getAmenitiesForZoomLevel(double zoomLevel) {
    // Show amenities at zoom level 10 and above
    if (zoomLevel < 10) return [];
    
    return _amenities;
  }
  
  /// Get amenity icon based on type
  static IconData getAmenityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'masjid':
        return Icons.mosque;
      case 'park':
        return Icons.park;
      case 'school':
        return Icons.school;
      case 'play ground':
        return Icons.sports_soccer;
      case 'graveyard':
        return Icons.place;
      case 'health facility':
        return Icons.local_hospital;
      default:
        return Icons.place;
    }
  }
  
  /// Get amenity color based on type
  static Color getAmenityColor(String type) {
    switch (type.toLowerCase()) {
      case 'masjid':
        return Colors.green;
      case 'park':
        return Colors.lightGreen;
      case 'school':
        return Colors.blue;
      case 'play ground':
        return Colors.orange;
      case 'graveyard':
        return Colors.grey;
      case 'health facility':
        return Colors.red;
      default:
        return Colors.purple;
    }
  }
}

/// Model class for amenity features
class AmenityFeature {
  final String type;
  final String phase;
  final LatLng center;
  
  AmenityFeature({
    required this.type,
    required this.phase,
    required this.center,
  });
  
  factory AmenityFeature.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'] ?? {};
    final geometry = json['geometry'] ?? {};
    final coords = geometry['coordinates'] ?? [];
    
    // Calculate center point from coordinates
    LatLng center = const LatLng(0, 0);
    
    try {
      if (coords.isNotEmpty && coords[0] is List && coords[0].isNotEmpty && coords[0][0] is List) {
        final firstRing = coords[0][0] as List;
        if (firstRing.isNotEmpty) {
          double totalLat = 0;
          double totalLng = 0;
          int count = 0;
          
          for (final coord in firstRing) {
            if (coord is List && coord.length >= 2) {
              // Ensure we have numeric values
              final lng = (coord[0] is num) ? coord[0].toDouble() : 0.0;
              final lat = (coord[1] is num) ? coord[1].toDouble() : 0.0;
              totalLng += lng;
              totalLat += lat;
              count++;
            }
          }
          
          if (count > 0) {
            center = LatLng(totalLat / count, totalLng / count);
          }
        }
      }
    } catch (e) {
      print('Error parsing coordinates: $e');
      center = const LatLng(0, 0);
    }
    
    return AmenityFeature(
      type: properties['Type'] ?? 'Unknown',
      phase: properties['Phase'] ?? 'Unknown',
      center: center,
    );
  }
  
  /// Get marker coordinates (center point)
  LatLng getMarkerCoordinates() {
    return center;
  }
}

/// Widget for rendering amenity markers
class AmenityMarkerWidget extends StatelessWidget {
  final AmenityFeature amenity;
  final double zoomLevel;
  
  const AmenityMarkerWidget({
    super.key,
    required this.amenity,
    required this.zoomLevel,
  });
  
  @override
  Widget build(BuildContext context) {
    // Only show markers at zoom level 10 and above
    if (zoomLevel < 10) return const SizedBox.shrink();
    
    final icon = AmenitiesGeoJsonService.getAmenityIcon(amenity.type);
    final color = AmenitiesGeoJsonService.getAmenityColor(amenity.type);
    
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}

/// Widget for rendering amenity polygons
/// NOTE: This widget is DISABLED to prevent polygon rendering
/// We only want marker icons, not polygon shapes for amenities
class AmenityPolygonWidget extends StatelessWidget {
  final AmenityFeature amenity;
  final double zoomLevel;
  
  const AmenityPolygonWidget({
    super.key,
    required this.amenity,
    required this.zoomLevel,
  });
  
  @override
  Widget build(BuildContext context) {
    // DISABLED: We don't want polygon shapes for amenities
    // Only show individual marker icons, not polygon overlays
    return const SizedBox.shrink();
  }
}