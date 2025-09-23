import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'amenities_marker_service.dart';

class AmenitiesApiService {
  /// Load amenities from local GeoJSON file
  static Future<List<AmenityMarker>> fetchAmenities() async {
    try {
      // Load the amenities GeoJSON from assets
      final String jsonString = await rootBundle.loadString('assets/Boundaries/geojsons/Amenities.geojson');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      final List<AmenityMarker> amenities = [];
      
      if (jsonData['features'] != null) {
        for (final feature in jsonData['features']) {
          try {
            final properties = feature['properties'] ?? {};
            final geometry = feature['geometry'] ?? {};
            
            final String phase = properties['Phase']?.toString() ?? 'Unknown';
            final String type = properties['Type']?.toString() ?? 'Unknown';
            
            // Calculate center point for the amenity
            final LatLng centerPoint = _calculateCenterPoint(geometry);
            
            if (centerPoint != null) {
              final marker = AmenitiesMarkerService.createCustomAmenityMarker(
                point: centerPoint,
                amenityType: type,
              );
              
              final amenity = AmenityMarker(
                marker: marker,
                amenityType: type,
                phase: phase,
                point: centerPoint,
              );
              
              amenities.add(amenity);
            }
          } catch (e) {
            print('Error processing amenity feature: $e');
            continue;
          }
        }
      }
      
      print('Loaded ${amenities.length} amenities from GeoJSON');
      return amenities;
    } catch (e) {
      print('Error loading amenities from GeoJSON: $e');
      throw Exception('Failed to load amenities: $e');
    }
  }
  
  /// Calculate center point of a geometry
  static LatLng _calculateCenterPoint(Map<String, dynamic> geometry) {
    try {
      final String geometryType = geometry['type'] ?? '';
      final List<dynamic> coordinates = geometry['coordinates'] ?? [];
      
      if (coordinates.isEmpty) return const LatLng(0, 0);
      
      double totalLat = 0;
      double totalLng = 0;
      int pointCount = 0;
      
      if (geometryType == 'MultiPolygon') {
        // Handle MultiPolygon
        for (final polygon in coordinates) {
          if (polygon is List && polygon.isNotEmpty) {
            for (final ring in polygon) {
              if (ring is List && ring.isNotEmpty) {
                for (final point in ring) {
                  if (point is List && point.length >= 2) {
                    totalLng += point[0].toDouble();
                    totalLat += point[1].toDouble();
                    pointCount++;
                  }
                }
              }
            }
          }
        }
      } else if (geometryType == 'Polygon') {
        // Handle Polygon
        for (final ring in coordinates) {
          if (ring is List && ring.isNotEmpty) {
            for (final point in ring) {
              if (point is List && point.length >= 2) {
                totalLng += point[0].toDouble();
                totalLat += point[1].toDouble();
                pointCount++;
              }
            }
          }
        }
      }
      
      if (pointCount > 0) {
        return LatLng(totalLat / pointCount, totalLng / pointCount);
      }
      
      return const LatLng(0, 0);
    } catch (e) {
      print('Error calculating center point: $e');
      return const LatLng(0, 0);
    }
  }
  
  /// Get amenities by phase
  static Future<List<AmenityMarker>> fetchAmenitiesByPhase(String phase) async {
    try {
      final allAmenities = await fetchAmenities();
      return allAmenities.where((amenity) => amenity.phase == phase).toList();
    } catch (e) {
      print('Error loading amenities by phase: $e');
      return [];
    }
  }
  
  /// Get amenities by type
  static Future<List<AmenityMarker>> fetchAmenitiesByType(String type) async {
    try {
      final allAmenities = await fetchAmenities();
      return allAmenities.where((amenity) => amenity.amenityType == type).toList();
    } catch (e) {
      print('Error loading amenities by type: $e');
      return [];
    }
  }
}
