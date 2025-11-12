import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple API test to verify the plots endpoint
class SimpleApiTest {
  static const String baseUrl = 'https://marketplace-testingbackend.dhamarketplace.com/api';
  
  /// Test the plots API endpoint
  static Future<void> testPlotsApi() async {
    print('=== SIMPLE API TEST ===');
    
    try {
      print('🔍 Testing API endpoint: $baseUrl/plots');
      
      final response = await http.get(
        Uri.parse('$baseUrl/plots'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      print('📊 Status Code: ${response.statusCode}');
      print('📊 Response Length: ${response.body.length}');
      
      if (response.statusCode == 200) {
        print('✅ API call successful');
        
        if (response.body.isEmpty) {
          print('❌ Empty response body');
          return;
        }
        
        try {
          final data = json.decode(response.body);
          print('✅ JSON parsed successfully');
          
          if (data is List) {
            print('📊 Data is a List with ${data.length} items');
            
            if (data.isNotEmpty) {
              final firstItem = data.first;
              print('📊 First item type: ${firstItem.runtimeType}');
              
              if (firstItem is Map) {
                final firstPlot = firstItem as Map<String, dynamic>;
                print('📊 First plot keys: ${firstPlot.keys.toList()}');
                
                // Check for st_asgeojson
                if (firstPlot.containsKey('st_asgeojson')) {
                  final geoJson = firstPlot['st_asgeojson'];
                  print('📊 st_asgeojson found: ${geoJson.runtimeType}');
                  print('📊 st_asgeojson length: ${geoJson.toString().length}');
                  print('📊 st_asgeojson preview: ${geoJson.toString().substring(0, 200)}...');
                } else {
                  print('❌ No st_asgeojson field found');
                  print('📊 Available fields: ${firstPlot.keys.toList()}');
                }
              }
            } else {
              print('❌ Empty data list');
            }
          } else {
            print('📊 Data type: ${data.runtimeType}');
            if (data is Map) {
              print('📊 Map keys: ${data.keys.toList()}');
            }
          }
        } catch (e) {
          print('❌ JSON parsing error: $e');
          print('📊 Raw response (first 500 chars): ${response.body.substring(0, 500)}');
        }
      } else {
        print('❌ API Error: ${response.statusCode}');
        print('📊 Error body: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception: $e');
    }
    
    print('=== END SIMPLE API TEST ===');
  }
}
