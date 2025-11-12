import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'enhanced_geojson_parser.dart';

/// Debug test for polygon parsing
class PolygonDebugTest {
  static void testPolygonParsing() {
    print('=== POLYGON DEBUG TEST ===');
    
    // Test with a simple MultiPolygon GeoJSON
    final testGeoJson = '''
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
    
    print('Testing with sample GeoJSON:');
    print(testGeoJson);
    
    final result = EnhancedGeoJsonParser.parsePolygonCoordinates(testGeoJson);
    print('Parsed ${result.length} polygons');
    
    if (result.isNotEmpty) {
      print('First polygon has ${result.first.length} points');
      for (int i = 0; i < result.first.length; i++) {
        print('Point $i: ${result.first[i]}');
      }
    } else {
      print('❌ No polygons parsed!');
    }
    
    print('=== END DEBUG TEST ===');
  }
  
  static void testRealPlotData(String geoJsonString) {
    print('=== TESTING REAL PLOT DATA ===');
    print('GeoJSON: $geoJsonString');
    
    final result = EnhancedGeoJsonParser.parsePolygonCoordinates(geoJsonString);
    print('Parsed ${result.length} polygons');
    
    if (result.isNotEmpty) {
      print('First polygon has ${result.first.length} points');
      print('First point: ${result.first.first}');
      print('Last point: ${result.first.last}');
    } else {
      print('❌ No polygons parsed from real data!');
    }
    
    print('=== END REAL PLOT TEST ===');
  }
}
