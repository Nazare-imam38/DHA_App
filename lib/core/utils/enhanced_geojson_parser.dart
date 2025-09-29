import 'dart:convert';
import 'dart:math';
import 'package:latlong2/latlong.dart';

/// Enhanced GeoJSON parser with proper UTM to Lat/Lng conversion
/// Fixes the coordinate conversion issue for DHA plots
class EnhancedGeoJsonParser {
  /// Parse GeoJSON coordinates and return the center point as LatLng
  /// The st_asgeojson field contains coordinates in EPSG:32643 projection
  /// which needs to be converted to WGS84 (standard lat/lng)
  static LatLng? parsePlotCoordinates(String? geoJsonString) {
    if (geoJsonString == null || geoJsonString.isEmpty) {
      print('EnhancedGeoJsonParser: GeoJSON string is null or empty');
      return null;
    }

    try {
      final geoJson = json.decode(geoJsonString);
      final coordinates = geoJson['coordinates'];
      
      if (coordinates == null || coordinates is! List) {
        print('EnhancedGeoJsonParser: Invalid coordinates structure');
        return null;
      }

      // For MultiPolygon, get the first polygon's first ring
      List<List<dynamic>> firstRing;
      if (coordinates is List && coordinates.isNotEmpty) {
        if (coordinates[0] is List && coordinates[0][0] is List) {
          // MultiPolygon structure
          firstRing = List<List<dynamic>>.from(coordinates[0][0]);
        } else if (coordinates[0] is List) {
          // Polygon structure
          firstRing = List<List<dynamic>>.from(coordinates[0]);
        } else {
          print('EnhancedGeoJsonParser: Invalid polygon structure');
          return null;
        }
      } else {
        print('EnhancedGeoJsonParser: Empty coordinates');
        return null;
      }

      if (firstRing.isEmpty) {
        print('EnhancedGeoJsonParser: Empty first ring');
        return null;
      }

      // Calculate center point from all coordinates
      double sumX = 0;
      double sumY = 0;
      int count = 0;

      for (final coord in firstRing) {
        if (coord is List && coord.length >= 2) {
          sumX += coord[0].toDouble();
          sumY += coord[1].toDouble();
          count++;
        }
      }

      if (count == 0) {
        print('EnhancedGeoJsonParser: No valid coordinates found');
        return null;
      }

      final centerX = sumX / count;
      final centerY = sumY / count;

      print('EnhancedGeoJsonParser: Raw coordinates: X=$centerX, Y=$centerY');

      // Convert UTM coordinates to proper LatLng using UTM Zone 43N
      final latLng = _utmToLatLng(centerX, centerY, 43, northernHemisphere: true);
      
      print('EnhancedGeoJsonParser: Converted coordinates: Lat=${latLng.latitude}, Lng=${latLng.longitude}');
      return latLng;
    } catch (e) {
      print('EnhancedGeoJsonParser: Error parsing GeoJSON: $e');
      return null;
    }
  }

  /// Parse all polygon coordinates for rendering
  static List<List<LatLng>> parsePolygonCoordinates(String? geoJsonString) {
    if (geoJsonString == null || geoJsonString.isEmpty) {
      print('EnhancedGeoJsonParser: Empty GeoJSON string');
      return [];
    }

    try {
      print('EnhancedGeoJsonParser: Raw GeoJSON: $geoJsonString');
      final geoJson = json.decode(geoJsonString);
      print('EnhancedGeoJsonParser: GeoJSON type: ${geoJson['type']}');
      
      final coordinates = geoJson['coordinates'];
      
      if (coordinates == null || coordinates is! List) {
        print('EnhancedGeoJsonParser: Invalid coordinates structure');
        print('EnhancedGeoJsonParser: Coordinates: $coordinates');
        return [];
      }
      
      print('EnhancedGeoJsonParser: Coordinates length: ${coordinates.length}');
      
      // Check if coordinates are already in lat/lng format (WGS84)
      if (coordinates.isNotEmpty && coordinates[0] is List && coordinates[0][0] is List) {
        final firstPoint = coordinates[0][0][0] as List;
        if (firstPoint.length >= 2) {
          final x = firstPoint[0].toDouble();
          final y = firstPoint[1].toDouble();
          print('EnhancedGeoJsonParser: First coordinate: X=$x, Y=$y');
          
          // Check if coordinates are in UTM range (typical for Pakistan/Islamabad area)
          // UTM Zone 43N for Islamabad: Easting ~300000-700000, Northing ~3600000-3800000
          if (x >= 200000 && x <= 800000 && y >= 3500000 && y <= 3900000) {
            print('EnhancedGeoJsonParser: Coordinates appear to be UTM Zone 43N, converting...');
          } else if (x >= -180 && x <= 180 && y >= -90 && y <= 90) {
            print('EnhancedGeoJsonParser: Coordinates appear to be in WGS84 format, using directly');
            return _parseWgs84Coordinates(geoJson);
          } else {
            print('EnhancedGeoJsonParser: Unknown coordinate format, attempting UTM conversion...');
          }
        }
      }

      final polygons = <List<LatLng>>[];
      
      if (geoJson['type'] == 'MultiPolygon' && coordinates.isNotEmpty) {
        print('EnhancedGeoJsonParser: Processing MultiPolygon with ${coordinates.length} polygons');
        
        for (int polyIndex = 0; polyIndex < coordinates.length; polyIndex++) {
          final polygon = coordinates[polyIndex];
          print('EnhancedGeoJsonParser: Polygon $polyIndex: $polygon');
          
          if (polygon is List && polygon.isNotEmpty) {
            // Get the first ring of the polygon
            final firstRing = polygon[0] as List;
            final ring = <LatLng>[];
            
            print('EnhancedGeoJsonParser: Processing polygon $polyIndex with ${firstRing.length} points');
            print('EnhancedGeoJsonParser: First ring: $firstRing');
            
            for (int pointIndex = 0; pointIndex < firstRing.length; pointIndex++) {
              final point = firstRing[pointIndex];
              print('EnhancedGeoJsonParser: Point $pointIndex: $point');
              
              if (point is List && point.length >= 2) {
                final x = point[0].toDouble();
                final y = point[1].toDouble();
                
                print('EnhancedGeoJsonParser: Raw coordinates: X=$x, Y=$y');
                
                // Convert UTM coordinates to Lat/Lng
                final latLng = _utmToLatLng(x, y, 43, northernHemisphere: true);
                ring.add(latLng);
                
                if (pointIndex < 3) { // Log first few points for debugging
                  print('EnhancedGeoJsonParser: Point $pointIndex: UTM($x, $y) -> LatLng(${latLng.latitude}, ${latLng.longitude})');
                }
              } else {
                print('EnhancedGeoJsonParser: Invalid point format: $point');
              }
            }
            
            print('EnhancedGeoJsonParser: Ring has ${ring.length} points');
            
            if (ring.length >= 3) {
              // Ensure polygon is closed
              if (ring.first.latitude != ring.last.latitude || 
                  ring.first.longitude != ring.last.longitude) {
                ring.add(ring.first);
              }
              polygons.add(ring);
              print('EnhancedGeoJsonParser: ✅ Added polygon with ${ring.length} points');
            } else {
              print('EnhancedGeoJsonParser: ❌ Skipped polygon $polyIndex - insufficient points (${ring.length})');
            }
          } else {
            print('EnhancedGeoJsonParser: ❌ Invalid polygon structure: $polygon');
          }
        }
      } else if (geoJson['type'] == 'Polygon' && coordinates.isNotEmpty) {
        print('EnhancedGeoJsonParser: Processing single Polygon');
        final firstRing = coordinates[0] as List;
        final ring = <LatLng>[];
        
        for (final point in firstRing) {
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
        }
      }
      
      print('EnhancedGeoJsonParser: Successfully parsed ${polygons.length} polygons');
      if (polygons.isNotEmpty) {
        print('EnhancedGeoJsonParser: First polygon has ${polygons.first.length} points');
        print('EnhancedGeoJsonParser: First point: ${polygons.first.first}');
      } else {
        print('EnhancedGeoJsonParser: ⚠️ No polygons were parsed!');
      }
      return polygons;
    } catch (e) {
      print('EnhancedGeoJsonParser: ❌ Error parsing polygon coordinates: $e');
      print('EnhancedGeoJsonParser: Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  /// Convert UTM coordinates to LatLng using proper UTM Zone 43N conversion
  /// This is the correct implementation for EPSG:32643 (UTM Zone 43N)
  static LatLng _utmToLatLng(double easting, double northing, int zoneNumber,
      {bool northernHemisphere = true}) {
    const double a = 6378137.0; // WGS84 major axis
    const double e = 0.081819191; // WGS84 eccentricity
    const double k0 = 0.9996;

    // Validate input coordinates for Islamabad area
    if (easting < 200000 || easting > 800000 || northing < 3500000 || northing > 3900000) {
      print('EnhancedGeoJsonParser: Warning - Coordinates outside expected UTM Zone 43N range for Islamabad');
      print('EnhancedGeoJsonParser: Easting: $easting, Northing: $northing');
    }

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

    lat = lat * (180 / pi);
    lng = lonOrigin + lng * (180 / pi);

    // Validate output coordinates for Islamabad area
    if (lat < 33.0 || lat > 34.5 || lng < 72.0 || lng > 74.5) {
      print('EnhancedGeoJsonParser: Warning - Converted coordinates outside expected Islamabad area');
      print('EnhancedGeoJsonParser: Converted: Lat=$lat, Lng=$lng');
    }

    return LatLng(lat, lng);
  }

  /// Get bounding box from GeoJSON for map fitting
  static Map<String, double>? getBoundingBox(String? geoJsonString) {
    if (geoJsonString == null || geoJsonString.isEmpty) {
      return null;
    }

    try {
      final geoJson = json.decode(geoJsonString);
      final coordinates = geoJson['coordinates'];
      
      if (coordinates == null || coordinates is! List) {
        return null;
      }

      List<List<dynamic>> firstRing;
      if (coordinates is List && coordinates.isNotEmpty) {
        if (coordinates[0] is List && coordinates[0][0] is List) {
          firstRing = List<List<dynamic>>.from(coordinates[0][0]);
        } else if (coordinates[0] is List) {
          firstRing = List<List<dynamic>>.from(coordinates[0]);
        } else {
          return null;
        }
      } else {
        return null;
      }

      if (firstRing.isEmpty) {
        return null;
      }

      double minX = double.infinity;
      double maxX = double.negativeInfinity;
      double minY = double.infinity;
      double maxY = double.negativeInfinity;

      for (final coord in firstRing) {
        if (coord is List && coord.length >= 2) {
          final x = coord[0].toDouble();
          final y = coord[1].toDouble();
          
          minX = minX < x ? minX : x;
          maxX = maxX > x ? maxX : x;
          minY = minY < y ? minY : y;
          maxY = maxY > y ? maxY : y;
        }
      }

      return {
        'minX': minX,
        'maxX': maxX,
        'minY': minY,
        'maxY': maxY,
      };
    } catch (e) {
      print('EnhancedGeoJsonParser: Error parsing GeoJSON bounding box: $e');
      return null;
    }
  }

  /// Test coordinate conversion with known values
  static void testCoordinateConversion() {
    print('EnhancedGeoJsonParser: Testing coordinate conversion...');
    
    // Test with known UTM coordinates for Islamabad area
    final testX = 500000.0; // UTM Zone 43N central meridian
    final testY = 3700000.0; // Approximate northing for Islamabad
    
    final result = _utmToLatLng(testX, testY, 43, northernHemisphere: true);
    print('EnhancedGeoJsonParser: Test conversion result: Lat=${result.latitude}, Lng=${result.longitude}');
    
    // Expected: Should be around Islamabad (33.7°N, 73.0°E)
    if (result.latitude > 33.0 && result.latitude < 34.0 && 
        result.longitude > 72.0 && result.longitude < 74.0) {
      print('EnhancedGeoJsonParser: ✅ Coordinate conversion test PASSED');
    } else {
      print('EnhancedGeoJsonParser: ❌ Coordinate conversion test FAILED');
    }
  }
  
  /// Parse coordinates that are already in WGS84 format
  static List<List<LatLng>> _parseWgs84Coordinates(Map<String, dynamic> geoJson) {
    final polygons = <List<LatLng>>[];
    final coordinates = geoJson['coordinates'] as List;
    
    print('EnhancedGeoJsonParser: Parsing WGS84 coordinates directly');
    
    if (geoJson['type'] == 'MultiPolygon' && coordinates.isNotEmpty) {
      print('EnhancedGeoJsonParser: Processing WGS84 MultiPolygon with ${coordinates.length} polygons');
      
      for (int polyIndex = 0; polyIndex < coordinates.length; polyIndex++) {
        final polygon = coordinates[polyIndex];
        
        if (polygon is List && polygon.isNotEmpty) {
          final firstRing = polygon[0] as List;
          final ring = <LatLng>[];
          
          print('EnhancedGeoJsonParser: Processing WGS84 polygon $polyIndex with ${firstRing.length} points');
          
          for (int pointIndex = 0; pointIndex < firstRing.length; pointIndex++) {
            final point = firstRing[pointIndex];
            
            if (point is List && point.length >= 2) {
              final lng = point[0].toDouble();
              final lat = point[1].toDouble();
              ring.add(LatLng(lat, lng));
              
              if (pointIndex < 3) {
                print('EnhancedGeoJsonParser: WGS84 Point $pointIndex: LatLng($lat, $lng)');
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
            print('EnhancedGeoJsonParser: ✅ Added WGS84 polygon with ${ring.length} points');
          } else {
            print('EnhancedGeoJsonParser: ❌ Skipped WGS84 polygon $polyIndex - insufficient points (${ring.length})');
          }
        }
      }
    } else if (geoJson['type'] == 'Polygon' && coordinates.isNotEmpty) {
      print('EnhancedGeoJsonParser: Processing WGS84 single Polygon');
      final firstRing = coordinates[0] as List;
      final ring = <LatLng>[];
      
      for (final point in firstRing) {
        if (point is List && point.length >= 2) {
          final lng = point[0].toDouble();
          final lat = point[1].toDouble();
          ring.add(LatLng(lat, lng));
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
    
    print('EnhancedGeoJsonParser: Successfully parsed ${polygons.length} WGS84 polygons');
    return polygons;
  }

  /// Test with real plot GeoJSON data
  static void testRealPlotData(String geoJsonString) {
    print('=== Testing Real Plot Data ===');
    print('GeoJSON length: ${geoJsonString.length}');
    
    try {
      final geoJson = json.decode(geoJsonString);
      print('GeoJSON type: ${geoJson['type']}');
      
      if (geoJson['type'] == 'MultiPolygon') {
        final coordinates = geoJson['coordinates'] as List;
        print('MultiPolygon has ${coordinates.length} polygons');
        
        if (coordinates.isNotEmpty) {
          final firstPolygon = coordinates[0] as List;
          if (firstPolygon.isNotEmpty) {
            final firstRing = firstPolygon[0] as List;
            print('First ring has ${firstRing.length} points');
            
            // Test first few points
            for (int i = 0; i < min(3, firstRing.length); i++) {
              final point = firstRing[i] as List;
              if (point.length >= 2) {
                final x = point[0].toDouble();
                final y = point[1].toDouble();
                final latLng = _utmToLatLng(x, y, 43, northernHemisphere: true);
                print('Point $i: UTM($x, $y) -> LatLng(${latLng.latitude}, ${latLng.longitude})');
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error testing real plot data: $e');
    }
    
    print('=== Real Plot Data Test Complete ===');
  }
}
