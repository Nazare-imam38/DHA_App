import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/plot_model.dart';

/// Test utility to verify JSON parsing fixes work correctly
class JsonParsingTest {
  static const String baseUrl = 'https://testingbackend.dhamarketplace.com/api';
  
  /// Test the filtered-plots endpoint to ensure it handles both List and Map responses
  static Future<void> testFilteredPlotsEndpoint() async {
    print('🧪 Testing filtered-plots endpoint JSON parsing...');
    
    try {
      final url = '$baseUrl/filtered-plots?price_from=5000000&price_to=10000000';
      print('📡 Testing URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      print('📊 Response status: ${response.statusCode}');
      print('📊 Response body length: ${response.body.length}');
      
      if (response.statusCode == 200) {
        final responseBody = response.body;
        
        if (responseBody.isEmpty || responseBody == '[]') {
          print('⚠️ Empty response from API');
          return;
        }
        
        try {
          final dynamic responseData = json.decode(responseBody);
          print('📊 Response type: ${responseData.runtimeType}');
          
          List<dynamic> jsonData;
          
          // Handle both response formats: List directly or Map with data wrapper
          if (responseData is List) {
            // API returns List directly
            jsonData = responseData;
            print('✅ Parsed ${jsonData.length} items from API (List format)');
          } else if (responseData is Map<String, dynamic>) {
            // API returns Map with data wrapper
            if (responseData.containsKey('data') && responseData['data'] is List) {
              jsonData = responseData['data'] as List<dynamic>;
              print('✅ Parsed ${jsonData.length} items from API (Map format with data key)');
            } else if (responseData.containsKey('plots') && responseData['plots'] is List) {
              jsonData = responseData['plots'] as List<dynamic>;
              print('✅ Parsed ${jsonData.length} items from API (Map format with plots key)');
            } else {
              print('❌ Unexpected Map format: ${responseData.keys}');
              return;
            }
          } else {
            print('❌ Unexpected response format: ${responseData.runtimeType}');
            return;
          }
          
          if (jsonData.isEmpty) {
            print('⚠️ No plots in API response');
            return;
          }
          
          // Test parsing first plot
          try {
            final firstPlot = PlotModel.fromJson(jsonData[0] as Map<String, dynamic>);
            print('✅ Successfully parsed first plot: ${firstPlot.plotNo}');
            print('✅ Plot price: ${firstPlot.basePrice}');
            print('✅ Plot phase: ${firstPlot.phase}');
          } catch (e) {
            print('❌ Error parsing first plot: $e');
          }
          
          print('🎉 JSON parsing test completed successfully!');
          
        } catch (parseError) {
          print('❌ JSON parsing error: $parseError');
          print('Raw response: $responseBody');
        }
      } else {
        print('❌ API Error: ${response.statusCode}');
        print('Error body: ${response.body}');
      }
    } catch (e) {
      print('❌ Test failed: $e');
    }
  }
  
  /// Test the regular plots endpoint
  static Future<void> testPlotsEndpoint() async {
    print('🧪 Testing plots endpoint JSON parsing...');
    
    try {
      final url = '$baseUrl/plots';
      print('📡 Testing URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      print('📊 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseBody = response.body;
        
        if (responseBody.isEmpty || responseBody == '[]') {
          print('⚠️ Empty response from API');
          return;
        }
        
        try {
          final dynamic responseData = json.decode(responseBody);
          print('📊 Response type: ${responseData.runtimeType}');
          
          if (responseData is List) {
            print('✅ API returns List with ${responseData.length} items');
          } else if (responseData is Map) {
            print('✅ API returns Map with keys: ${responseData.keys}');
          } else {
            print('❌ Unexpected response format: ${responseData.runtimeType}');
          }
          
        } catch (parseError) {
          print('❌ JSON parsing error: $parseError');
        }
      } else {
        print('❌ API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Test failed: $e');
    }
  }
  
  /// Run all tests
  static Future<void> runAllTests() async {
    print('🚀 Starting JSON parsing tests...\n');
    
    await testPlotsEndpoint();
    print('');
    await testFilteredPlotsEndpoint();
    
    print('\n🏁 All tests completed!');
  }
}
