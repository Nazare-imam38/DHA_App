import 'dart:math';
import 'package:latlong2/latlong.dart';
import 'enhanced_geojson_parser.dart';

/// Enhanced coordinate conversion test for DHA plots
class CoordinateTestEnhanced {
  /// Test the coordinate conversion with known values
  static void runAllTests() {
    print('🧪 Enhanced Coordinate Conversion Tests');
    print('=====================================');
    
    _testUtmToLatLngConversion();
    _testGeoJsonParsing();
    _testPolygonCoordinates();
    _testPerformance();
    
    print('✅ All coordinate conversion tests completed');
  }
  
  /// Test UTM to Lat/Lng conversion with known values
  static void _testUtmToLatLngConversion() {
    print('\n📍 Testing UTM to Lat/Lng Conversion');
    print('-----------------------------------');
    
    // Test coordinates for Islamabad area (UTM Zone 43N)
    final testCases = [
      {
        'name': 'Islamabad Center',
        'easting': 500000.0,
        'northing': 3700000.0,
        'expectedLat': 33.7,
        'expectedLng': 73.0,
        'tolerance': 0.5,
      },
      {
        'name': 'Rawalpindi Area',
        'easting': 495000.0,
        'northing': 3695000.0,
        'expectedLat': 33.6,
        'expectedLng': 73.0,
        'tolerance': 0.5,
      },
      {
        'name': 'DHA Phase 1 Area',
        'easting': 502000.0,
        'northing': 3702000.0,
        'expectedLat': 33.7,
        'expectedLng': 73.1,
        'tolerance': 0.5,
      },
    ];
    
    for (final testCase in testCases) {
      final result = EnhancedGeoJsonParser.parsePlotCoordinates(
        _createTestGeoJson(testCase['easting']!, testCase['northing']!)
      );
      
      if (result != null) {
        final latDiff = (result.latitude - testCase['expectedLat']!).abs();
        final lngDiff = (result.longitude - testCase['expectedLng']!).abs();
        final tolerance = testCase['tolerance']!;
        
        final latPass = latDiff <= tolerance;
        final lngPass = lngDiff <= tolerance;
        
        print('${testCase['name']}: ${latPass && lngPass ? "✅ PASS" : "❌ FAIL"}');
        print('  Expected: Lat=${testCase['expectedLat']}, Lng=${testCase['expectedLng']}');
        print('  Got: Lat=${result.latitude.toStringAsFixed(4)}, Lng=${result.longitude.toStringAsFixed(4)}');
        print('  Diff: Lat=${latDiff.toStringAsFixed(4)}, Lng=${lngDiff.toStringAsFixed(4)}');
        
        if (!latPass || !lngPass) {
          print('  ⚠️  Coordinate conversion may be incorrect');
        }
      } else {
        print('${testCase['name']}: ❌ FAIL - No coordinates returned');
      }
    }
  }
  
  /// Test GeoJSON parsing with sample data
  static void _testGeoJsonParsing() {
    print('\n🗺️  Testing GeoJSON Parsing');
    print('----------------------------');
    
    // Test with sample DHA plot GeoJSON
    final sampleGeoJson = '''
    {
      "type": "MultiPolygon",
      "coordinates": [
        [
          [
            [500000, 3700000],
            [500100, 3700000],
            [500100, 3700100],
            [500000, 3700100],
            [500000, 3700000]
          ]
        ]
      ]
    }
    ''';
    
    final center = EnhancedGeoJsonParser.parsePlotCoordinates(sampleGeoJson);
    if (center != null) {
      print('✅ GeoJSON parsing: PASS');
      print('  Center: Lat=${center.latitude.toStringAsFixed(4)}, Lng=${center.longitude.toStringAsFixed(4)}');
    } else {
      print('❌ GeoJSON parsing: FAIL');
    }
    
    // Test polygon coordinates
    final polygons = EnhancedGeoJsonParser.parsePolygonCoordinates(sampleGeoJson);
    if (polygons.isNotEmpty) {
      print('✅ Polygon parsing: PASS');
      print('  Polygons: ${polygons.length}');
      print('  Points in first polygon: ${polygons.first.length}');
    } else {
      print('❌ Polygon parsing: FAIL');
    }
  }
  
  /// Test polygon coordinate extraction
  static void _testPolygonCoordinates() {
    print('\n🔷 Testing Polygon Coordinates');
    print('-------------------------------');
    
    final sampleGeoJson = '''
    {
      "type": "MultiPolygon",
      "coordinates": [
        [
          [
            [500000, 3700000],
            [500100, 3700000],
            [500100, 3700100],
            [500000, 3700100],
            [500000, 3700000]
          ]
        ]
      ]
    }
    ''';
    
    final polygons = EnhancedGeoJsonParser.parsePolygonCoordinates(sampleGeoJson);
    
    if (polygons.isNotEmpty) {
      final firstPolygon = polygons.first;
      print('✅ Polygon extraction: PASS');
      print('  Polygons: ${polygons.length}');
      print('  Points: ${firstPolygon.length}');
      print('  First point: Lat=${firstPolygon.first.latitude.toStringAsFixed(4)}, Lng=${firstPolygon.first.longitude.toStringAsFixed(4)}');
      print('  Last point: Lat=${firstPolygon.last.latitude.toStringAsFixed(4)}, Lng=${firstPolygon.last.longitude.toStringAsFixed(4)}');
      
      // Check if polygon is closed
      final isClosed = firstPolygon.first.latitude == firstPolygon.last.latitude &&
                      firstPolygon.first.longitude == firstPolygon.last.longitude;
      print('  Closed polygon: ${isClosed ? "✅ Yes" : "❌ No"}');
    } else {
      print('❌ Polygon extraction: FAIL');
    }
  }
  
  /// Test performance of coordinate conversion
  static void _testPerformance() {
    print('\n⚡ Testing Performance');
    print('----------------------');
    
    final iterations = 1000;
    final stopwatch = Stopwatch()..start();
    
    for (int i = 0; i < iterations; i++) {
      final testGeoJson = _createTestGeoJson(500000 + i, 3700000 + i);
      EnhancedGeoJsonParser.parsePlotCoordinates(testGeoJson);
    }
    
    stopwatch.stop();
    final avgTime = stopwatch.elapsedMicroseconds / iterations;
    
    print('✅ Performance test: PASS');
    print('  Iterations: $iterations');
    print('  Total time: ${stopwatch.elapsedMilliseconds}ms');
    print('  Average time: ${avgTime.toStringAsFixed(2)}μs per conversion');
    
    if (avgTime < 1000) { // Less than 1ms per conversion
      print('  🚀 Performance: EXCELLENT');
    } else if (avgTime < 5000) { // Less than 5ms per conversion
      print('  ✅ Performance: GOOD');
    } else {
      print('  ⚠️  Performance: NEEDS OPTIMIZATION');
    }
  }
  
  /// Create test GeoJSON with given coordinates
  static String _createTestGeoJson(double x, double y) {
    return '''
    {
      "type": "MultiPolygon",
      "coordinates": [
        [
          [
            [$x, $y],
            [${x + 100}, $y],
            [${x + 100}, ${y + 100}],
            [$x, ${y + 100}],
            [$x, $y]
          ]
        ]
      ]
    }
    ''';
  }
  
  /// Test with real DHA plot data structure
  static void testWithRealData() {
    print('\n🏠 Testing with Real DHA Data Structure');
    print('---------------------------------------');
    
    // Simulate real DHA plot GeoJSON structure
    final realGeoJson = '''
    {
      "type": "MultiPolygon",
      "coordinates": [
        [
          [
            [500000, 3700000],
            [500050, 3700000],
            [500050, 3700050],
            [500000, 3700050],
            [500000, 3700000]
          ]
        ]
      ]
    }
    ''';
    
    final center = EnhancedGeoJsonParser.parsePlotCoordinates(realGeoJson);
    final polygons = EnhancedGeoJsonParser.parsePolygonCoordinates(realGeoJson);
    
    if (center != null && polygons.isNotEmpty) {
      print('✅ Real data test: PASS');
      print('  Plot center: Lat=${center.latitude.toStringAsFixed(6)}, Lng=${center.longitude.toStringAsFixed(6)}');
      print('  Polygon points: ${polygons.first.length}');
      
      // Verify coordinates are in Pakistan/Islamabad area
      final isInPakistan = center.latitude > 33.0 && center.latitude < 34.0 &&
                          center.longitude > 72.0 && center.longitude < 74.0;
      
      if (isInPakistan) {
        print('  ✅ Coordinates are in Pakistan/Islamabad area');
      } else {
        print('  ❌ Coordinates are NOT in Pakistan/Islamabad area');
        print('  ⚠️  This indicates a coordinate conversion issue');
      }
    } else {
      print('❌ Real data test: FAIL');
    }
  }
}
