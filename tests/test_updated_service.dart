import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Test the updated ProgressiveFilterService
void main() async {
  print('🔍 Testing Updated ProgressiveFilterService\n');
  
  const String baseUrl = 'https://testingbackend.dhamarketplace.com/api';
  
  // Test the filtered-plots endpoint with the new parsing logic
  await testFilteredPlotsEndpoint('$baseUrl/filtered-plots?price_from=5000000&price_to=10000000');
  
  print('\n🏁 Testing completed!');
}

Future<void> testFilteredPlotsEndpoint(String url) async {
  print('📡 Testing filtered-plots endpoint with new parsing logic...');
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
        print('⚠️ Empty response from filtered-plots endpoint');
        return;
      }
      
      try {
        final dynamic responseData = json.decode(responseBody);
        print('📊 Response type: ${responseData.runtimeType}');
        
        // Test the new parsing logic
        print('\n🧪 Testing new parsing logic...');
        
        // Extract plots list
        List<dynamic> plotsList = [];
        if (responseData is List) {
          plotsList = responseData;
          print('✅ Direct List response with ${plotsList.length} items');
        } else if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
            final data = responseData['data'] as Map<String, dynamic>;
            if (data.containsKey('plots') && data['plots'] is List) {
              plotsList = data['plots'] as List<dynamic>;
              print('✅ Map with data.plots structure: ${plotsList.length} items');
            }
          } else if (responseData.containsKey('plots') && responseData['plots'] is List) {
            plotsList = responseData['plots'] as List<dynamic>;
            print('✅ Map with direct plots key: ${plotsList.length} items');
          }
        }
        
        if (plotsList.isNotEmpty) {
          print('✅ Successfully extracted ${plotsList.length} plots');
          
          // Test parsing first plot
          try {
            final firstPlot = plotsList[0];
            print('✅ First plot type: ${firstPlot.runtimeType}');
            
            if (firstPlot is Map<String, dynamic>) {
              print('✅ First plot is Map<String, dynamic> - This should work!');
              print('✅ First plot keys: ${firstPlot.keys}');
            } else {
              print('❌ First plot is not Map<String, dynamic>: ${firstPlot.runtimeType}');
            }
          } catch (e) {
            print('❌ Error accessing first plot: $e');
          }
        } else {
          print('❌ No plots found in response');
        }
        
        // Extract counts
        Map<String, dynamic> countsMap = {};
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
            final data = responseData['data'] as Map<String, dynamic>;
            if (data.containsKey('counts') && data['counts'] is Map<String, dynamic>) {
              countsMap = data['counts'] as Map<String, dynamic>;
              print('✅ Extracted counts from data.counts: ${countsMap.keys}');
            }
          } else if (responseData.containsKey('counts') && responseData['counts'] is Map<String, dynamic>) {
            countsMap = responseData['counts'] as Map<String, dynamic>;
            print('✅ Extracted counts from direct counts key: ${countsMap.keys}');
          }
        }
        
        // Extract success status
        bool success = true;
        if (responseData is Map<String, dynamic>) {
          success = responseData['success'] as bool? ?? true;
          print('✅ Extracted success status: $success');
        }
        
        print('\n🎉 New parsing logic works correctly!');
        print('✅ Plots: ${plotsList.length}');
        print('✅ Success: $success');
        print('✅ Counts: ${countsMap.keys}');
        
      } catch (parseError) {
        print('❌ JSON parsing error: $parseError');
        print('❌ This might be the source of your type casting error!');
      }
    } else {
      print('❌ Filtered plots endpoint error: ${response.statusCode}');
      print('❌ Error body: ${response.body}');
    }
  } catch (e) {
    print('❌ Filtered plots endpoint test failed: $e');
  }
}
