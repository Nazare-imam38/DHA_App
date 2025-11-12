import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Simple test to check API responses and identify type casting issues
void main() async {
  print('🔍 Testing API responses to identify type casting issues\n');
  
  const String baseUrl = 'https://marketplace-testingbackend.dhamarketplace.com/api';
  
  // Test 1: Basic plots endpoint
  await testEndpoint('$baseUrl/plots', 'Basic Plots');
  
  // Test 2: Filtered plots endpoint
  await testEndpoint('$baseUrl/filtered-plots?price_from=5000000&price_to=10000000', 'Filtered Plots');
  
  // Test 3: Filter plots range endpoint
  await testEndpoint('$baseUrl/filter-plots-range?price_from=5000000&price_to=10000000', 'Filter Plots Range');
  
  print('\n🏁 API response testing completed!');
}

Future<void> testEndpoint(String url, String name) async {
  print('📡 Testing $name endpoint...');
  print('URL: $url');
  
  try {
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
        print('⚠️ Empty response from $name endpoint');
        return;
      }
      
      try {
        final dynamic responseData = json.decode(responseBody);
        print('📊 Response type: ${responseData.runtimeType}');
        
        if (responseData is List) {
          print('✅ $name endpoint returns List with ${responseData.length} items');
          
          // Test parsing first item
          if (responseData.isNotEmpty) {
            try {
              final firstItem = responseData[0];
              print('✅ First item type: ${firstItem.runtimeType}');
              
              if (firstItem is Map<String, dynamic>) {
                print('✅ First item is Map<String, dynamic> - This is correct!');
              } else {
                print('❌ First item is not Map<String, dynamic>: ${firstItem.runtimeType}');
                print('❌ This could cause type casting errors!');
              }
            } catch (e) {
              print('❌ Error accessing first item: $e');
            }
          }
        } else if (responseData is Map<String, dynamic>) {
          print('✅ $name endpoint returns Map with keys: ${responseData.keys}');
          
          // Check if it has plots key
          if (responseData.containsKey('plots')) {
            final plots = responseData['plots'];
            print('✅ Map contains plots key, type: ${plots.runtimeType}');
            
            if (plots is List) {
              print('✅ Plots is List with ${plots.length} items');
            } else {
              print('❌ Plots is not List: ${plots.runtimeType}');
            }
          } else if (responseData.containsKey('data')) {
            final data = responseData['data'];
            print('✅ Map contains data key, type: ${data.runtimeType}');
            
            if (data is Map && data.containsKey('plots')) {
              final plots = data['plots'];
              print('✅ Data contains plots, type: ${plots.runtimeType}');
              
              if (plots is List) {
                print('✅ Data.plots is List with ${plots.length} items');
              } else {
                print('❌ Data.plots is not List: ${plots.runtimeType}');
              }
            }
          } else {
            print('❌ Map does not contain expected keys (plots or data)');
            print('❌ Available keys: ${responseData.keys}');
          }
        } else {
          print('❌ Unexpected response format: ${responseData.runtimeType}');
        }
        
      } catch (parseError) {
        print('❌ JSON parsing error in $name endpoint: $parseError');
        print('❌ This might be the source of your type casting error!');
        print('❌ Raw response (first 500 chars): ${responseBody.substring(0, responseBody.length > 500 ? 500 : responseBody.length)}');
      }
    } else {
      print('❌ $name endpoint error: ${response.statusCode}');
      print('❌ Error body: ${response.body}');
    }
  } catch (e) {
    print('❌ $name endpoint test failed: $e');
  }
  
  print(''); // Empty line for readability
}
