import 'dart:convert';
import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../services/robust_polygon_parser.dart';
import 'enhanced_geojson_parser.dart';

/// Enhanced debug test for polygon parsing with comprehensive testing
class PolygonDebugTestEnhanced {
  /// Test polygon parsing with sample UTM coordinates
  static void testPolygonParsingWithUTM() {
    print('=== ENHANCED POLYGON DEBUG TEST ===');
    
    // Test with UTM coordinates that match DHA plot structure
    final testGeoJson = '''
    {
      "type": "MultiPolygon",
      "crs": {
        "type": "name",
        "properties": {
          "name": "EPSG:32643"
        }
      },
      "coordinates": [
        [
          [
            [330081.911, 3712732.7881, 0],
            [330100.911, 3712732.7881, 0],
            [330100.911, 3712750.7881, 0],
            [330081.911, 3712750.7881, 0],
            [330081.911, 3712732.7881, 0]
          ]
        ]
      ]
    }
    ''';
    
    print('Testing with UTM GeoJSON (EPSG:32643):');
    print(testGeoJson);
    
    // Test with RobustPolygonParser
    print('\n--- Testing RobustPolygonParser ---');
    final robustResult = RobustPolygonParser.parsePolygonCoordinates(testGeoJson);
    print('RobustPolygonParser result: ${robustResult.length} polygons');
    
    if (robustResult.isNotEmpty) {
      print('First polygon has ${robustResult.first.length} points');
      for (int i = 0; i < min(3, robustResult.first.length); i++) {
        print('Point $i: ${robustResult.first[i]}');
      }
    } else {
      print('❌ RobustPolygonParser failed to parse polygons!');
    }
    
    // Test with EnhancedGeoJsonParser
    print('\n--- Testing EnhancedGeoJsonParser ---');
    final enhancedResult = EnhancedGeoJsonParser.parsePolygonCoordinates(testGeoJson);
    print('EnhancedGeoJsonParser result: ${enhancedResult.length} polygons');
    
    if (enhancedResult.isNotEmpty) {
      print('First polygon has ${enhancedResult.first.length} points');
      for (int i = 0; i < min(3, enhancedResult.first.length); i++) {
        print('Point $i: ${enhancedResult.first[i]}');
      }
    } else {
      print('❌ EnhancedGeoJsonParser failed to parse polygons!');
    }
    
    print('=== END ENHANCED DEBUG TEST ===');
  }
  
  /// Test coordinate conversion with known values
  static void testCoordinateConversion() {
    print('=== COORDINATE CONVERSION TEST ===');
    
    // Test with known UTM coordinates for Islamabad area
    final testCoordinates = [
      [330081.911, 3712732.7881], // Sample from your API
      [330100.911, 3712732.7881],
      [330100.911, 3712750.7881],
      [330081.911, 3712750.7881],
    ];
    
    print('Testing UTM to LatLng conversion:');
    for (int i = 0; i < testCoordinates.length; i++) {
      final x = testCoordinates[i][0];
      final y = testCoordinates[i][1];
      
      // Test with RobustPolygonParser conversion
      final latLng = _testUtmToLatLng(x, y);
      print('Point $i: UTM($x, $y) -> LatLng(${latLng.latitude}, ${latLng.longitude})');
      
      // Verify the coordinates are in reasonable range for Islamabad
      if (latLng.latitude > 33.0 && latLng.latitude < 34.0 && 
          latLng.longitude > 72.0 && latLng.longitude < 74.0) {
        print('✅ Point $i: Coordinates are in reasonable range for Islamabad');
      } else {
        print('❌ Point $i: Coordinates are outside expected range for Islamabad');
      }
    }
    
    print('=== END COORDINATE CONVERSION TEST ===');
  }
  
  /// Test with real plot data structure
  static void testRealPlotDataStructure() {
    print('=== REAL PLOT DATA STRUCTURE TEST ===');
    
    // Simulate the exact structure from your API
    final realPlotData = {
      "id": 1,
      "plot_no": "A-1",
      "st_asgeojson": '''{
        "type": "MultiPolygon",
        "crs": {
          "type": "name",
          "properties": {
            "name": "EPSG:32643"
          }
        },
        "coordinates": [
          [
            [
              [330081.911, 3712732.7881, 0],
              [330100.911, 3712732.7881, 0],
              [330100.911, 3712750.7881, 0],
              [330081.911, 3712750.7881, 0],
              [330081.911, 3712732.7881, 0]
            ]
          ]
        ]
      }'''
    };
    
    print('Testing with real plot data structure:');
    print('Plot No: ${realPlotData["plot_no"]}');
    print('GeoJSON: ${realPlotData["st_asgeojson"]}');
    
    // Parse the GeoJSON
    final geoJsonString = realPlotData["st_asgeojson"] as String;
    
    // Test with RobustPolygonParser
    print('\n--- Testing RobustPolygonParser with real data ---');
    final robustResult = RobustPolygonParser.parsePolygonCoordinates(geoJsonString);
    print('RobustPolygonParser result: ${robustResult.length} polygons');
    
    if (robustResult.isNotEmpty) {
      print('✅ RobustPolygonParser successfully parsed ${robustResult.length} polygons');
      print('First polygon has ${robustResult.first.length} points');
      print('First point: ${robustResult.first.first}');
      print('Last point: ${robustResult.first.last}');
    } else {
      print('❌ RobustPolygonParser failed to parse real plot data!');
    }
    
    // Test with EnhancedGeoJsonParser
    print('\n--- Testing EnhancedGeoJsonParser with real data ---');
    final enhancedResult = EnhancedGeoJsonParser.parsePolygonCoordinates(geoJsonString);
    print('EnhancedGeoJsonParser result: ${enhancedResult.length} polygons');
    
    if (enhancedResult.isNotEmpty) {
      print('✅ EnhancedGeoJsonParser successfully parsed ${enhancedResult.length} polygons');
      print('First polygon has ${enhancedResult.first.length} points');
      print('First point: ${enhancedResult.first.first}');
      print('Last point: ${enhancedResult.first.last}');
    } else {
      print('❌ EnhancedGeoJsonParser failed to parse real plot data!');
    }
    
    print('=== END REAL PLOT DATA STRUCTURE TEST ===');
  }
  
  /// Test the complete parsing pipeline
  static void testCompleteParsingPipeline() {
    print('=== COMPLETE PARSING PIPELINE TEST ===');
    
    // Test the complete flow from GeoJSON to map-ready polygons
    final testGeoJson = '''
    {
      "type": "MultiPolygon",
      "crs": {
        "type": "name",
        "properties": {
          "name": "EPSG:32643"
        }
      },
      "coordinates": [
        [
          [
            [330081.911, 3712732.7881, 0],
            [330100.911, 3712732.7881, 0],
            [330100.911, 3712750.7881, 0],
            [330081.911, 3712750.7881, 0],
            [330081.911, 3712732.7881, 0]
          ]
        ]
      ]
    }
    ''';
    
    print('Testing complete parsing pipeline...');
    
    // Step 1: Parse GeoJSON
    final geoJson = json.decode(testGeoJson);
    print('Step 1: GeoJSON parsed successfully');
    print('Type: ${geoJson['type']}');
    print('CRS: ${geoJson['crs']}');
    
    // Step 2: Extract coordinates
    final coordinates = geoJson['coordinates'] as List;
    print('Step 2: Coordinates extracted - ${coordinates.length} polygons');
    
    // Step 3: Parse with RobustPolygonParser
    final polygons = RobustPolygonParser.parsePolygonCoordinates(testGeoJson);
    print('Step 3: RobustPolygonParser result - ${polygons.length} polygons');
    
    if (polygons.isNotEmpty) {
      print('✅ Complete parsing pipeline successful!');
      print('First polygon: ${polygons.first.length} points');
      print('First point: ${polygons.first.first}');
      print('Last point: ${polygons.first.last}');
      
      // Verify polygon is closed
      final firstPoint = polygons.first.first;
      final lastPoint = polygons.first.last;
      if (firstPoint.latitude == lastPoint.latitude && 
          firstPoint.longitude == lastPoint.longitude) {
        print('✅ Polygon is properly closed');
      } else {
        print('⚠️ Polygon is not closed - first: $firstPoint, last: $lastPoint');
      }
    } else {
      print('❌ Complete parsing pipeline failed!');
    }
    
    print('=== END COMPLETE PARSING PIPELINE TEST ===');
  }
  
  /// Run all tests
  static void runAllTests() {
    print('🚀 Starting comprehensive polygon parsing tests...\n');
    
    testPolygonParsingWithUTM();
    print('\n');
    
    testCoordinateConversion();
    print('\n');
    
    testRealPlotDataStructure();
    print('\n');
    
    testCompleteParsingPipeline();
    print('\n');
    
    print('🏁 All polygon parsing tests completed!');
  }
  
  /// Test UTM to LatLng conversion (copied from RobustPolygonParser)
  static LatLng _testUtmToLatLng(double easting, double northing, {int zoneNumber = 43, bool northernHemisphere = true}) {
    const double a = 6378137.0; // WGS84 major axis
    const double e = 0.081819191; // WGS84 eccentricity
    const double k0 = 0.9996;

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

    return LatLng(lat, lng);
  }
}
