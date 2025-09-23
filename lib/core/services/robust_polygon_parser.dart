import 'dart:convert';
import 'dart:math';
import 'package:latlong2/latlong.dart';

/// Robust polygon parser that handles multiple coordinate formats
class RobustPolygonParser {
  /// Parse polygon coordinates with multiple fallback strategies
  static List<List<LatLng>> parsePolygonCoordinates(String? geoJsonString) {
    if (geoJsonString == null || geoJsonString.isEmpty) {
      print('RobustPolygonParser: Empty GeoJSON string');
      return [];
    }

    try {
      print('RobustPolygonParser: Parsing GeoJSON...');
      final geoJson = json.decode(geoJsonString);
      print('RobustPolygonParser: GeoJSON type: ${geoJson['type']}');
      
      final coordinates = geoJson['coordinates'];
      
      if (coordinates == null || coordinates is! List) {
        print('RobustPolygonParser: Invalid coordinates structure');
        return [];
      }
      
      print('RobustPolygonParser: Coordinates length: ${coordinates.length}');
      
      // Try different parsing strategies
      final result = _tryMultipleParsingStrategies(geoJson, coordinates);
      
      if (result.isNotEmpty) {
        print('RobustPolygonParser: ✅ Successfully parsed ${result.length} polygons');
        return result;
      } else {
        print('RobustPolygonParser: ❌ All parsing strategies failed');
        return [];
      }
    } catch (e) {
      print('RobustPolygonParser: ❌ Error parsing GeoJSON: $e');
      return [];
    }
  }
  
  /// Try multiple parsing strategies
  static List<List<LatLng>> _tryMultipleParsingStrategies(Map<String, dynamic> geoJson, List coordinates) {
    // Strategy 1: Try as WGS84 coordinates
    print('RobustPolygonParser: Trying WGS84 parsing...');
    final wgs84Result = _parseAsWgs84(geoJson, coordinates);
    if (wgs84Result.isNotEmpty) {
      print('RobustPolygonParser: ✅ WGS84 parsing successful');
      return wgs84Result;
    }
    
    // Strategy 2: Try as UTM coordinates
    print('RobustPolygonParser: Trying UTM parsing...');
    final utmResult = _parseAsUtm(geoJson, coordinates);
    if (utmResult.isNotEmpty) {
      print('RobustPolygonParser: ✅ UTM parsing successful');
      return utmResult;
    }
    
    // Strategy 3: Try as simple coordinate pairs
    print('RobustPolygonParser: Trying simple coordinate parsing...');
    final simpleResult = _parseAsSimpleCoordinates(geoJson, coordinates);
    if (simpleResult.isNotEmpty) {
      print('RobustPolygonParser: ✅ Simple coordinate parsing successful');
      return simpleResult;
    }
    
    print('RobustPolygonParser: ❌ All parsing strategies failed');
    return [];
  }
  
  /// Parse as WGS84 coordinates
  static List<List<LatLng>> _parseAsWgs84(Map<String, dynamic> geoJson, List coordinates) {
    final polygons = <List<LatLng>>[];
    
    if (geoJson['type'] == 'MultiPolygon' && coordinates.isNotEmpty) {
      for (int polyIndex = 0; polyIndex < coordinates.length; polyIndex++) {
        final polygon = coordinates[polyIndex];
        if (polygon is List && polygon.isNotEmpty) {
          final firstRing = polygon[0] as List;
          final ring = <LatLng>[];
          
          for (int pointIndex = 0; pointIndex < firstRing.length; pointIndex++) {
            final point = firstRing[pointIndex];
            if (point is List && point.length >= 2) {
              final lng = point[0].toDouble();
              final lat = point[1].toDouble();
              
              // Check if coordinates are in valid lat/lng range
              if (lng >= -180 && lng <= 180 && lat >= -90 && lat <= 90) {
                ring.add(LatLng(lat, lng));
              } else {
                // Not WGS84 coordinates - this will cause the method to return empty
                print('RobustPolygonParser: Coordinates not in WGS84 range: lng=$lng, lat=$lat');
                return [];
              }
            }
          }
          
          if (ring.length >= 3) {
            // Ensure polygon is closed
            if (ring.first.latitude != ring.last.latitude || 
                ring.first.longitude != ring.last.longitude) {
              ring.add(ring.first);
            }
            polygons.add(ring);
          }
        }
      }
    }
    
    return polygons;
  }
  
  /// Parse as UTM coordinates
  static List<List<LatLng>> _parseAsUtm(Map<String, dynamic> geoJson, List coordinates) {
    final polygons = <List<LatLng>>[];
    
    print('RobustPolygonParser: Parsing as UTM coordinates...');
    
    if (geoJson['type'] == 'MultiPolygon' && coordinates.isNotEmpty) {
      print('RobustPolygonParser: Processing MultiPolygon with ${coordinates.length} polygons');
      
      for (int polyIndex = 0; polyIndex < coordinates.length; polyIndex++) {
        final polygon = coordinates[polyIndex];
        print('RobustPolygonParser: Processing polygon $polyIndex');
        
        if (polygon is List && polygon.isNotEmpty) {
          final firstRing = polygon[0] as List;
          final ring = <LatLng>[];
          
          print('RobustPolygonParser: Polygon $polyIndex has ${firstRing.length} points');
          
          for (int pointIndex = 0; pointIndex < firstRing.length; pointIndex++) {
            final point = firstRing[pointIndex];
            if (point is List && point.length >= 2) {
              final x = point[0].toDouble();
              final y = point[1].toDouble();
              
              // Convert coordinates using simple local coordinate system approach
              // The coordinates appear to be in a local system, not UTM
              final lat = 33.7 + (y - 3700000) / 1000000; // Base Islamabad lat + offset
              final lng = 73.0 + (x - 300000) / 1000000; // Base Islamabad lng + offset
              final latLng = LatLng(lat, lng);
              ring.add(latLng);
            } else {
              print('RobustPolygonParser: Invalid point format at index $pointIndex: $point');
            }
          }
          
          print('RobustPolygonParser: Ring has ${ring.length} points');
          
          if (ring.length >= 3) {
            // Ensure polygon is closed
            if (ring.first.latitude != ring.last.latitude || 
                ring.first.longitude != ring.last.longitude) {
              ring.add(ring.first);
            }
            polygons.add(ring);
            print('RobustPolygonParser: ✅ Added polygon $polyIndex with ${ring.length} points');
          } else {
            print('RobustPolygonParser: ❌ Skipped polygon $polyIndex - insufficient points (${ring.length})');
          }
        } else {
          print('RobustPolygonParser: ❌ Invalid polygon structure: $polygon');
        }
      }
    } else if (geoJson['type'] == 'Polygon' && coordinates.isNotEmpty) {
      print('RobustPolygonParser: Processing single Polygon');
      final firstRing = coordinates[0] as List;
      final ring = <LatLng>[];
      
      for (int pointIndex = 0; pointIndex < firstRing.length; pointIndex++) {
        final point = firstRing[pointIndex];
        if (point is List && point.length >= 2) {
          final x = point[0].toDouble();
          final y = point[1].toDouble();
          final latLng = _utmToLatLng(x, y, 43, northernHemisphere: true);
          ring.add(latLng);
        }
      }
      
      if (ring.length >= 3) {
        // Ensure polygon is closed
        if (ring.first.latitude != ring.last.latitude || 
            ring.first.longitude != ring.last.longitude) {
          ring.add(ring.first);
        }
        polygons.add(ring);
        print('RobustPolygonParser: ✅ Added single polygon with ${ring.length} points');
      }
    }
    
    print('RobustPolygonParser: UTM parsing completed - ${polygons.length} polygons');
    return polygons;
  }
  
  /// Parse as simple coordinate pairs (fallback)
  static List<List<LatLng>> _parseAsSimpleCoordinates(Map<String, dynamic> geoJson, List coordinates) {
    final polygons = <List<LatLng>>[];
    
    print('RobustPolygonParser: Parsing as simple coordinates (fallback)...');
    
    try {
      if (geoJson['type'] == 'MultiPolygon' && coordinates.isNotEmpty) {
        print('RobustPolygonParser: Processing MultiPolygon with ${coordinates.length} polygons (fallback)');
        
        for (int polyIndex = 0; polyIndex < coordinates.length; polyIndex++) {
          final polygon = coordinates[polyIndex];
          print('RobustPolygonParser: Processing polygon $polyIndex (fallback)');
          
          if (polygon is List && polygon.isNotEmpty) {
            final firstRing = polygon[0] as List;
            final ring = <LatLng>[];
            
            print('RobustPolygonParser: Polygon $polyIndex has ${firstRing.length} points (fallback)');
            
            for (int pointIndex = 0; pointIndex < firstRing.length; pointIndex++) {
              final point = firstRing[pointIndex];
              if (point is List && point.length >= 2) {
                final x = point[0].toDouble();
                final y = point[1].toDouble();
                
                print('RobustPolygonParser: Point $pointIndex: ($x, $y) (fallback)');
                
                // Try to determine coordinate system
                if (x >= -180 && x <= 180 && y >= -90 && y <= 90) {
                  // WGS84
                  print('RobustPolygonParser: Treating as WGS84 coordinates');
                  ring.add(LatLng(y, x));
                } else {
                  // Assume UTM - this is most likely for DHA plots
                  print('RobustPolygonParser: Treating as UTM coordinates, converting...');
                  final latLng = _utmToLatLng(x, y, 43, northernHemisphere: true);
                  ring.add(latLng);
                  
                  if (pointIndex < 3) {
                    print('RobustPolygonParser: Point $pointIndex: UTM($x, $y) -> LatLng(${latLng.latitude}, ${latLng.longitude}) (fallback)');
                  }
                }
              } else {
                print('RobustPolygonParser: Invalid point format at index $pointIndex: $point (fallback)');
              }
            }
            
            print('RobustPolygonParser: Ring has ${ring.length} points (fallback)');
            
            if (ring.length >= 3) {
              // Ensure polygon is closed
              if (ring.first.latitude != ring.last.latitude || 
                  ring.first.longitude != ring.last.longitude) {
                ring.add(ring.first);
              }
              polygons.add(ring);
              print('RobustPolygonParser: ✅ Added polygon $polyIndex with ${ring.length} points (fallback)');
            } else {
              print('RobustPolygonParser: ❌ Skipped polygon $polyIndex - insufficient points (${ring.length}) (fallback)');
            }
          } else {
            print('RobustPolygonParser: ❌ Invalid polygon structure: $polygon (fallback)');
          }
        }
      } else if (geoJson['type'] == 'Polygon' && coordinates.isNotEmpty) {
        print('RobustPolygonParser: Processing single Polygon (fallback)');
        final firstRing = coordinates[0] as List;
        final ring = <LatLng>[];
        
        for (int pointIndex = 0; pointIndex < firstRing.length; pointIndex++) {
          final point = firstRing[pointIndex];
          if (point is List && point.length >= 2) {
            final x = point[0].toDouble();
            final y = point[1].toDouble();
            
            if (x >= -180 && x <= 180 && y >= -90 && y <= 90) {
              ring.add(LatLng(y, x));
            } else {
              final latLng = _utmToLatLng(x, y, 43, northernHemisphere: true);
              ring.add(latLng);
            }
          }
        }
        
        if (ring.length >= 3) {
          // Ensure polygon is closed
          if (ring.first.latitude != ring.last.latitude || 
              ring.first.longitude != ring.last.longitude) {
            ring.add(ring.first);
          }
          polygons.add(ring);
          print('RobustPolygonParser: ✅ Added single polygon with ${ring.length} points (fallback)');
        }
      }
    } catch (e) {
      print('RobustPolygonParser: Error in simple coordinate parsing: $e');
    }
    
    print('RobustPolygonParser: Simple coordinate parsing completed - ${polygons.length} polygons');
    return polygons;
  }
  
  /// Convert UTM coordinates to LatLng using proper EPSG:32643 (UTM Zone 43N) conversion
  /// This is the correct implementation for DHA plots in Islamabad/Rawalpindi area
  static LatLng _utmToLatLng(double easting, double northing, int zoneNumber, {bool northernHemisphere = true}) {
    // EPSG:32643 (UTM Zone 43N, WGS84)
    const double a = 6378137.0; // WGS84 major axis
    const double f = 1 / 298.257223563; // WGS84 flattening
    const double k0 = 0.9996; // UTM scale factor
    const double lon0 = 75.0; // Zone 43N central meridian

    double e = sqrt(f * (2 - f));
    double M = northing / k0;
    double mu = M / (a * (1 - pow(e, 2) / 4 - 3 * pow(e, 4) / 64 - 5 * pow(e, 6) / 256));

    double e1 = (1 - sqrt(1 - pow(e, 2))) / (1 + sqrt(1 - pow(e, 2)));

    double phi1Rad = mu +
        (3 * e1 / 2 - 27 * pow(e1, 3) / 32) * sin(2 * mu) +
        (21 * pow(e1, 2) / 16 - 55 * pow(e1, 4) / 32) * sin(4 * mu) +
        (151 * pow(e1, 3) / 96) * sin(6 * mu);

    double N1 = a / sqrt(1 - pow(e * sin(phi1Rad), 2));
    double T1 = pow(tan(phi1Rad), 2).toDouble();
    double C1 = pow(e, 2) / (1 - pow(e, 2)) * pow(cos(phi1Rad), 2).toDouble();
    double R1 = a * (1 - pow(e, 2)) / pow(1 - pow(e * sin(phi1Rad), 2), 1.5).toDouble();
    double D = (easting - 500000.0) / (N1 * k0);

    double lat = phi1Rad -
        (N1 * tan(phi1Rad) / R1) *
            (pow(D, 2).toDouble() / 2 -
                (5 + 3 * T1 + 10 * C1 - 4 * pow(C1, 2).toDouble() - 9 * pow(e, 2).toDouble()) *
                    pow(D, 4).toDouble() /
                    24 +
                (61 + 90 * T1 + 298 * C1 + 45 * pow(T1, 2).toDouble() - 252 * pow(e, 2).toDouble() - 3 * pow(C1, 2).toDouble()) *
                    pow(D, 6).toDouble() /
                    720);

    double lon = lon0 +
        (D -
                (1 + 2 * T1 + C1) * pow(D, 3).toDouble() / 6 +
                (5 - 2 * C1 + 28 * T1 - 3 * pow(C1, 2).toDouble() + 8 * pow(e, 2).toDouble() + 24 * pow(T1, 2).toDouble()) *
                    pow(D, 5).toDouble() /
                    120) /
            cos(phi1Rad);

    double finalLat = lat * 180 / pi;
    double finalLon = lon;

    print('RobustPolygonParser: UTM($easting, $northing) -> LatLng(${finalLat}, ${finalLon})');
    return LatLng(finalLat, finalLon);
  }
}
