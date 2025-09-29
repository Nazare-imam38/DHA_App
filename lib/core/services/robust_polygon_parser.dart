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
              
              // Convert UTM coordinates to LatLng using proper UTM Zone 43N conversion
              final latLng = _utmToLatLng(x, y, 43, northernHemisphere: true);
              ring.add(latLng);
              
              if (pointIndex < 3) {
                print('RobustPolygonParser: Point $pointIndex: UTM($x, $y) -> LatLng(${latLng.latitude}, ${latLng.longitude})');
              }
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
    const double a = 6378137.0; // WGS84 major axis
    const double e = 0.081819191; // WGS84 eccentricity
    const double k0 = 0.9996; // UTM scale factor

    double x = easting - 500000.0; // remove 500,000 meter offset
    double y = northing;

    if (!northernHemisphere) {
      y -= 10000000.0; // adjust for southern hemisphere
    }

    double m = y / k0;
    double mu = m / (a * (1 - pow(e, 2) / 4 - 3 * pow(e, 4) / 64 - 5 * pow(e, 6) / 256));

    double e1 = (1 - sqrt(1 - pow(e, 2))) / (1 + sqrt(1 - pow(e, 2)));

    double j1 = (3 * e1 / 2 - 27 * pow(e1, 3) / 32);
    double j2 = (21 * pow(e1, 2) / 16 - 55 * pow(e1, 4) / 32);
    double j3 = (151 * pow(e1, 3) / 96);
    double j4 = (1097 * pow(e1, 4) / 512);

    double fp = mu +
        j1 * sin(2 * mu) +
        j2 * sin(4 * mu) +
        j3 * sin(6 * mu) +
        j4 * sin(8 * mu);

    double e2 = pow((e * a / (a * (1 - pow(e, 2)))), 2).toDouble();
    double c1 = e2 * pow(cos(fp), 2).toDouble();
    double t1 = pow(tan(fp), 2).toDouble();
    double r1 = a * (1 - pow(e, 2)) /
        pow(1 - pow(e, 2) * pow(sin(fp), 2), 1.5).toDouble();
    double n1 = a / sqrt(1 - pow(e, 2) * pow(sin(fp), 2));

    double d = x / (n1 * k0);

    double q1 = n1 * tan(fp) / r1;
    double q2 = (pow(d, 2) / 2);
    double q3 = (5 + 3 * t1 + 10 * c1 - 4 * pow(c1, 2) - 9 * e2) * pow(d, 4) / 24;
    double q4 = (61 + 90 * t1 + 298 * c1 + 45 * pow(t1, 2) - 3 * pow(c1, 2) - 252 * e2) * pow(d, 6) / 720;
    double lat = fp - q1 * (q2 - q3 + q4);

    double q5 = d;
    double q6 = (1 + 2 * t1 + c1) * pow(d, 3) / 6;
    double q7 = (5 - 2 * c1 + 28 * t1 - 3 * pow(c1, 2) + 8 * e2 + 24 * pow(t1, 2)) * pow(d, 5) / 120;
    double lng = (d - q6 + q7) / cos(fp);

    double lonOrigin = (zoneNumber - 1) * 6 - 180 + 3;
    
    // For UTM Zone 43N (EPSG:32643), the central meridian should be 75°E
    // But we need to adjust for the actual zone
    if (zoneNumber == 43) {
      lonOrigin = 75.0; // Central meridian for UTM Zone 43N
    }

    lat = lat * (180 / pi);
    lng = lonOrigin + lng * (180 / pi);

    print('RobustPolygonParser: UTM($easting, $northing) -> LatLng(${lat}, ${lng})');
    return LatLng(lat, lng);
  }
}
