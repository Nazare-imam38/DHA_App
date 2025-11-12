import 'dart:convert';
import 'package:http/http.dart' as http;

/// Simple test to detect where type casting errors are occurring
class ErrorDetectionTest {
  static const String baseUrl = 'https://marketplace-testingbackend.dhamarketplace.com/api';
  
  /// Test that will help identify the exact source of type casting errors
  static Future<void> detectTypeCastingErrors() async {
    print('🔍 Error Detection Test - Finding type casting error sources\n');
    
    // Test 1: Check if the error is in basic API calls
    await _testBasicApiCall();
    
    // Test 2: Check if the error is in filtered API calls
    await _testFilteredApiCall();
    
    // Test 3: Check if the error is in response parsing
    await _testResponseParsing();
    
    print('\n🏁 Error detection test completed!');
  }
  
  /// Test basic API call
  static Future<void> _testBasicApiCall() async {
    print('📡 Testing basic API call...');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/plots'),
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
        
        // This is where the type casting error might occur
        try {
          final dynamic responseData = json.decode(responseBody);
          print('📊 Response type: ${responseData.runtimeType}');
          
          // Test if it's a List
          if (responseData is List) {
            print('✅ API returns List with ${responseData.length} items');
            
            // Test parsing first item
            if (responseData.isNotEmpty) {
              try {
                final firstItem = responseData[0];
                print('✅ First item type: ${firstItem.runtimeType}');
                
                if (firstItem is Map<String, dynamic>) {
                  print('✅ First item is Map<String, dynamic>');
                } else {
                  print('❌ First item is not Map<String, dynamic>: ${firstItem.runtimeType}');
                }
              } catch (e) {
                print('❌ Error accessing first item: $e');
              }
            }
          } else if (responseData is Map<String, dynamic>) {
            print('✅ API returns Map with keys: ${responseData.keys}');
          } else {
            print('❌ Unexpected response format: ${responseData.runtimeType}');
          }
          
        } catch (parseError) {
          print('❌ JSON parsing error: $parseError');
          print('❌ This might be the source of your type casting error!');
        }
      } else {
        print('❌ API error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Basic API call failed: $e');
    }
  }
  
  /// Test filtered API call
  static Future<void> _testFilteredApiCall() async {
    print('\n📡 Testing filtered API call...');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/filtered-plots?price_from=5000000&price_to=10000000'),
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
          print('⚠️ Empty response from filtered API');
          return;
        }
        
        // This is where the type casting error might occur
        try {
          final dynamic responseData = json.decode(responseBody);
          print('📊 Response type: ${responseData.runtimeType}');
          
          // Test if it's a List
          if (responseData is List) {
            print('✅ Filtered API returns List with ${responseData.length} items');
            
            // Test parsing first item
            if (responseData.isNotEmpty) {
              try {
                final firstItem = responseData[0];
                print('✅ First item type: ${firstItem.runtimeType}');
                
                if (firstItem is Map<String, dynamic>) {
                  print('✅ First item is Map<String, dynamic>');
                } else {
                  print('❌ First item is not Map<String, dynamic>: ${firstItem.runtimeType}');
                }
              } catch (e) {
                print('❌ Error accessing first item: $e');
              }
            }
          } else if (responseData is Map<String, dynamic>) {
            print('✅ Filtered API returns Map with keys: ${responseData.keys}');
          } else {
            print('❌ Unexpected response format: ${responseData.runtimeType}');
          }
          
        } catch (parseError) {
          print('❌ JSON parsing error in filtered API: $parseError');
          print('❌ This might be the source of your type casting error!');
        }
      } else {
        print('❌ Filtered API error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Filtered API call failed: $e');
    }
  }
  
  /// Test response parsing scenarios
  static Future<void> _testResponseParsing() async {
    print('\n📡 Testing response parsing scenarios...');
    
    // Test with a mock List response
    try {
      final mockListResponse = '[{"id": 1, "name": "test"}]';
      final dynamic parsedData = json.decode(mockListResponse);
      
      print('📊 Mock List response type: ${parsedData.runtimeType}');
      
      if (parsedData is List) {
        print('✅ Mock List response correctly identified as List');
        
        // Test the problematic scenario
        try {
          final firstItem = parsedData[0];
          if (firstItem is Map<String, dynamic>) {
            print('✅ First item correctly identified as Map<String, dynamic>');
          } else {
            print('❌ First item is not Map<String, dynamic>: ${firstItem.runtimeType}');
          }
        } catch (e) {
          print('❌ Error accessing first item: $e');
        }
      }
    } catch (e) {
      print('❌ Mock List response test failed: $e');
    }
    
    // Test with a mock Map response
    try {
      final mockMapResponse = '{"plots": [{"id": 1, "name": "test"}]}';
      final dynamic parsedData = json.decode(mockMapResponse);
      
      print('📊 Mock Map response type: ${parsedData.runtimeType}');
      
      if (parsedData is Map<String, dynamic>) {
        print('✅ Mock Map response correctly identified as Map<String, dynamic>');
        
        // Test accessing plots
        try {
          final plots = parsedData['plots'];
          if (plots is List) {
            print('✅ Plots correctly identified as List');
          } else {
            print('❌ Plots is not List: ${plots.runtimeType}');
          }
        } catch (e) {
          print('❌ Error accessing plots: $e');
        }
      }
    } catch (e) {
      print('❌ Mock Map response test failed: $e');
    }
  }
}
