import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Detailed test to examine the exact structure of API responses
void main() async {
  print('🔍 Detailed API Response Analysis\n');
  
  const String baseUrl = 'https://testingbackend.dhamarketplace.com/api';
  
  // Test the filtered-plots endpoint that's causing issues
  await analyzeResponse('$baseUrl/filtered-plots?price_from=5000000&price_to=10000000', 'Filtered Plots');
  
  print('\n🏁 Detailed analysis completed!');
}

Future<void> analyzeResponse(String url, String name) async {
  print('📡 Analyzing $name endpoint...');
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
        
        if (responseData is Map<String, dynamic>) {
          print('✅ Response is Map with keys: ${responseData.keys}');
          
          // Analyze the structure
          for (String key in responseData.keys) {
            final value = responseData[key];
            print('  - $key: ${value.runtimeType}');
            
            if (key == 'data' && value is Map<String, dynamic>) {
              print('    Data keys: ${value.keys}');
              
              for (String dataKey in value.keys) {
                final dataValue = value[dataKey];
                print('      - $dataKey: ${dataValue.runtimeType}');
                
                if (dataKey == 'plots' && dataValue is List) {
                  print('        Plots count: ${dataValue.length}');
                  
                  if (dataValue.isNotEmpty) {
                    final firstPlot = dataValue[0];
                    print('        First plot type: ${firstPlot.runtimeType}');
                    
                    if (firstPlot is Map<String, dynamic>) {
                      print('        First plot keys: ${firstPlot.keys}');
                    }
                  }
                }
              }
            }
          }
          
          // Test the exact parsing that ProgressiveFilterService does
          print('\n🧪 Testing ProgressiveFilterService parsing...');
          
          try {
            final success = responseData['success'] ?? false;
            print('✅ Success: $success');
            
            final data = responseData['data'];
            print('✅ Data: ${data.runtimeType}');
            
            if (data is Map<String, dynamic>) {
              final plots = data['plots'];
              print('✅ Data.plots: ${plots.runtimeType}');
              
              if (plots is List) {
                print('✅ Data.plots is List with ${plots.length} items');
                
                // Test parsing first plot
                if (plots.isNotEmpty) {
                  try {
                    final firstPlot = plots[0];
                    print('✅ First plot type: ${firstPlot.runtimeType}');
                    
                    if (firstPlot is Map<String, dynamic>) {
                      print('✅ First plot is Map<String, dynamic> - This should work!');
                    } else {
                      print('❌ First plot is not Map<String, dynamic>: ${firstPlot.runtimeType}');
                    }
                  } catch (e) {
                    print('❌ Error accessing first plot: $e');
                  }
                }
              } else {
                print('❌ Data.plots is not List: ${plots.runtimeType}');
              }
              
              final counts = data['counts'];
              print('✅ Data.counts: ${counts.runtimeType}');
              
              if (counts is Map<String, dynamic>) {
                print('✅ Data.counts is Map with keys: ${counts.keys}');
              } else {
                print('❌ Data.counts is not Map: ${counts.runtimeType}');
              }
            } else {
              print('❌ Data is not Map: ${data.runtimeType}');
            }
            
          } catch (e) {
            print('❌ Error in ProgressiveFilterService parsing: $e');
            print('❌ This is likely the source of your type casting error!');
          }
          
        } else {
          print('❌ Response is not Map: ${responseData.runtimeType}');
        }
        
      } catch (parseError) {
        print('❌ JSON parsing error: $parseError');
        print('❌ Raw response (first 1000 chars): ${responseBody.substring(0, responseBody.length > 1000 ? 1000 : responseBody.length)}');
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
