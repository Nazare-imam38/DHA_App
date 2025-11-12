import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../data/models/plot_model.dart';
import '../services/robust_polygon_parser.dart';
import 'enhanced_geojson_parser.dart';

/// Comprehensive debug analyzer for plots API and polygon parsing
class PlotsDebugAnalyzer {
  static const String baseUrl = 'https://marketplace-testingbackend.dhamarketplace.com/api';
  
  /// Step 1: Test API response structure
  static Future<void> analyzeApiResponse() async {
    print('=== STEP 1: API RESPONSE ANALYSIS ===');
    
    try {
      print('🔍 Testing API endpoint: $baseUrl/plots');
      final response = await http.get(
        Uri.parse('$baseUrl/plots'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      print('📊 Response Status: ${response.statusCode}');
      print('📊 Response Body Length: ${response.body.length}');
      print('📊 Response Headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        print('✅ API call successful');
        
        if (response.body.isEmpty) {
          print('❌ Empty response body');
          return;
        }
        
        try {
          final data = json.decode(response.body);
          print('✅ JSON parsed successfully');
          print('📊 Data type: ${data.runtimeType}');
          
          if (data is List) {
            print('📊 Data is a List with ${data.length} items');
            
            if (data.isNotEmpty) {
              print('📊 First item type: ${data.first.runtimeType}');
              if (data.first is Map) {
                final firstPlot = data.first as Map<String, dynamic>;
                print('📊 First plot keys: ${firstPlot.keys.toList()}');
                
                // Check for st_asgeojson field
                if (firstPlot.containsKey('st_asgeojson')) {
                  final geoJson = firstPlot['st_asgeojson'];
                  print('📊 st_asgeojson type: ${geoJson.runtimeType}');
                  print('📊 st_asgeojson length: ${geoJson.toString().length}');
                  print('📊 st_asgeojson preview: ${geoJson.toString().substring(0, min(200, geoJson.toString().length))}...');
                  
                  // Test if it's a string that needs parsing
                  if (geoJson is String) {
                    try {
                      final parsedGeoJson = json.decode(geoJson);
                      print('📊 Parsed GeoJSON type: ${parsedGeoJson['type']}');
                      print('📊 Parsed GeoJSON coordinates length: ${(parsedGeoJson['coordinates'] as List).length}');
                    } catch (e) {
                      print('❌ Error parsing st_asgeojson string: $e');
                    }
                  }
                } else {
                  print('❌ No st_asgeojson field found in first plot');
                }
                
                // Check for other possible field names
                if (firstPlot.containsKey('stAsgeojson')) {
                  print('📊 Found stAsgeojson field (camelCase)');
                }
                if (firstPlot.containsKey('geometry')) {
                  print('📊 Found geometry field');
                }
                if (firstPlot.containsKey('polygon')) {
                  print('📊 Found polygon field');
                }
              }
            } else {
              print('❌ Empty data list');
            }
          } else if (data is Map) {
            print('📊 Data is a Map with keys: ${data.keys.toList()}');
            if (data.containsKey('plots')) {
              final plots = data['plots'] as List;
              print('📊 Plots array length: ${plots.length}');
            }
          }
        } catch (e) {
          print('❌ JSON parsing error: $e');
          print('📊 Raw response (first 500 chars): ${response.body.substring(0, min(500, response.body.length))}');
        }
      } else {
        print('❌ API Error: ${response.statusCode}');
        print('📊 Error body: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception: $e');
    }
    
    print('=== END STEP 1 ===\n');
  }
  
  /// Step 2: Test PlotModel creation
  static Future<void> analyzePlotModelCreation() async {
    print('=== STEP 2: PLOT MODEL CREATION ANALYSIS ===');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/plots'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        
        if (jsonData.isNotEmpty) {
          print('📊 Testing PlotModel.fromJson with first plot...');
          final firstPlotJson = jsonData.first as Map<String, dynamic>;
          
          try {
            final plot = PlotModel.fromJson(firstPlotJson);
            print('✅ PlotModel created successfully');
            print('📊 Plot No: ${plot.plotNo}');
            print('📊 Plot ID: ${plot.id}');
            print('📊 GeoJSON length: ${plot.stAsgeojson.length}');
            print('📊 GeoJSON preview: ${plot.stAsgeojson.substring(0, min(200, plot.stAsgeojson.length))}...');
            
            // Test polygon coordinates parsing
            print('📊 Testing polygon coordinates parsing...');
            final polygonCoordinates = plot.polygonCoordinates;
            print('📊 Polygon coordinates count: ${polygonCoordinates.length}');
            
            if (polygonCoordinates.isNotEmpty) {
              print('✅ Polygon coordinates parsed successfully');
              print('📊 First polygon has ${polygonCoordinates.first.length} points');
              print('📊 First point: ${polygonCoordinates.first.first}');
              print('📊 Last point: ${polygonCoordinates.first.last}');
            } else {
              print('❌ No polygon coordinates parsed');
            }
            
          } catch (e) {
            print('❌ Error creating PlotModel: $e');
            print('📊 First plot JSON: ${json.encode(firstPlotJson)}');
          }
        } else {
          print('❌ No plots in API response');
        }
      }
    } catch (e) {
      print('❌ Exception in PlotModel creation: $e');
    }
    
    print('=== END STEP 2 ===\n');
  }
  
  /// Step 3: Test polygon parsing with raw GeoJSON
  static Future<void> analyzePolygonParsing() async {
    print('=== STEP 3: POLYGON PARSING ANALYSIS ===');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/plots'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        
        if (jsonData.isNotEmpty) {
          final firstPlotJson = jsonData.first as Map<String, dynamic>;
          final geoJsonString = firstPlotJson['st_asgeojson'] as String;
          
          print('📊 Testing polygon parsing with raw GeoJSON...');
          print('📊 GeoJSON string length: ${geoJsonString.length}');
          print('📊 GeoJSON preview: ${geoJsonString.substring(0, min(300, geoJsonString.length))}...');
          
          // Test with RobustPolygonParser
          print('\n🔍 Testing RobustPolygonParser...');
          final robustResult = RobustPolygonParser.parsePolygonCoordinates(geoJsonString);
          print('📊 RobustPolygonParser result: ${robustResult.length} polygons');
          
          if (robustResult.isNotEmpty) {
            print('✅ RobustPolygonParser successful');
            print('📊 First polygon points: ${robustResult.first.length}');
            print('📊 First point: ${robustResult.first.first}');
            print('📊 Last point: ${robustResult.first.last}');
          } else {
            print('❌ RobustPolygonParser failed');
          }
          
          // Test with EnhancedGeoJsonParser
          print('\n🔍 Testing EnhancedGeoJsonParser...');
          final enhancedResult = EnhancedGeoJsonParser.parsePolygonCoordinates(geoJsonString);
          print('📊 EnhancedGeoJsonParser result: ${enhancedResult.length} polygons');
          
          if (enhancedResult.isNotEmpty) {
            print('✅ EnhancedGeoJsonParser successful');
            print('📊 First polygon points: ${enhancedResult.first.length}');
            print('📊 First point: ${enhancedResult.first.first}');
            print('📊 Last point: ${enhancedResult.first.last}');
          } else {
            print('❌ EnhancedGeoJsonParser failed');
          }
          
          // Test manual parsing
          print('\n🔍 Testing manual GeoJSON parsing...');
          try {
            final geoJson = json.decode(geoJsonString);
            print('📊 GeoJSON type: ${geoJson['type']}');
            print('📊 GeoJSON coordinates: ${geoJson['coordinates']}');
            
            if (geoJson['coordinates'] is List) {
              final coordinates = geoJson['coordinates'] as List;
              print('📊 Coordinates length: ${coordinates.length}');
              
              if (coordinates.isNotEmpty && coordinates[0] is List) {
                final firstPolygon = coordinates[0] as List;
                print('📊 First polygon length: ${firstPolygon.length}');
                
                if (firstPolygon.isNotEmpty && firstPolygon[0] is List) {
                  final firstRing = firstPolygon[0] as List;
                  print('📊 First ring length: ${firstRing.length}');
                  
                  if (firstRing.isNotEmpty) {
                    final firstPoint = firstRing[0] as List;
                    print('📊 First point: $firstPoint');
                    print('📊 First point X: ${firstPoint[0]}');
                    print('📊 First point Y: ${firstPoint[1]}');
                    
                    // Check if coordinates are UTM or WGS84
                    final x = firstPoint[0].toDouble();
                    final y = firstPoint[1].toDouble();
                    
                    if (x >= -180 && x <= 180 && y >= -90 && y <= 90) {
                      print('📊 Coordinates appear to be WGS84 (lat/lng)');
                    } else {
                      print('📊 Coordinates appear to be UTM (meters)');
                      print('📊 X range: ${x >= 0 ? 'positive' : 'negative'}');
                      print('📊 Y range: ${y >= 0 ? 'positive' : 'negative'}');
                    }
                  }
                }
              }
            }
          } catch (e) {
            print('❌ Error in manual parsing: $e');
          }
        }
      }
    } catch (e) {
      print('❌ Exception in polygon parsing: $e');
    }
    
    print('=== END STEP 3 ===\n');
  }
  
  /// Step 4: Test coordinate conversion
  static Future<void> analyzeCoordinateConversion() async {
    print('=== STEP 4: COORDINATE CONVERSION ANALYSIS ===');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/plots'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        
        if (jsonData.isNotEmpty) {
          final firstPlotJson = jsonData.first as Map<String, dynamic>;
          final geoJsonString = firstPlotJson['st_asgeojson'] as String;
          final geoJson = json.decode(geoJsonString);
          final coordinates = geoJson['coordinates'] as List;
          
          if (coordinates.isNotEmpty && coordinates[0] is List && coordinates[0][0] is List) {
            final firstRing = coordinates[0][0] as List;
            
            print('📊 Testing coordinate conversion with first few points...');
            
            for (int i = 0; i < min(3, firstRing.length); i++) {
              final point = firstRing[i] as List;
              final x = point[0].toDouble();
              final y = point[1].toDouble();
              
              print('📊 Point $i: UTM($x, $y)');
              
              // Test UTM to LatLng conversion
              final latLng = _testUtmToLatLng(x, y);
              print('📊 Converted to: LatLng(${latLng.latitude}, ${latLng.longitude})');
              
              // Verify coordinates are in reasonable range for Islamabad
              if (latLng.latitude > 33.0 && latLng.latitude < 34.0 && 
                  latLng.longitude > 72.0 && latLng.longitude < 74.0) {
                print('✅ Point $i: Coordinates are in reasonable range for Islamabad');
              } else {
                print('❌ Point $i: Coordinates are outside expected range for Islamabad');
              }
            }
          }
        }
      }
    } catch (e) {
      print('❌ Exception in coordinate conversion: $e');
    }
    
    print('=== END STEP 4 ===\n');
  }
  
  /// Run complete analysis
  static Future<void> runCompleteAnalysis() async {
    print('🚀 Starting comprehensive plots API and polygon parsing analysis...\n');
    
    await analyzeApiResponse();
    await analyzePlotModelCreation();
    await analyzePolygonParsing();
    await analyzeCoordinateConversion();
    
    print('🏁 Complete analysis finished!');
  }
  
  /// Test UTM to LatLng conversion
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
