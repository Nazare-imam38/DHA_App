import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/plot_model.dart';
import '../../services/progressive_filter_service.dart';
import '../../services/plots_service.dart';
import '../services/enhanced_plots_api_service.dart';

/// Comprehensive test to identify all potential sources of type casting errors
class ComprehensiveApiTest {
  static const String baseUrl = 'https://marketplace-testingbackend.dhamarketplace.com/api';
  
  /// Test all API endpoints that might cause type casting errors
  static Future<void> testAllEndpoints() async {
    print('🔍 Comprehensive API Test - Checking all potential sources of type casting errors\n');
    
    // Test 1: Basic plots endpoint
    await _testBasicPlotsEndpoint();
    
    // Test 2: Filtered plots endpoint
    await _testFilteredPlotsEndpoint();
    
    // Test 3: Progressive filter service
    await _testProgressiveFilterService();
    
    // Test 4: Enhanced plots API service
    await _testEnhancedPlotsApiService();
    
    // Test 5: Plots service
    await _testPlotsService();
    
    print('\n🏁 Comprehensive API test completed!');
  }
  
  /// Test basic plots endpoint
  static Future<void> _testBasicPlotsEndpoint() async {
    print('📡 Testing basic plots endpoint...');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/plots'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      print('📊 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('📊 Response body length: ${responseBody.length}');
        
        if (responseBody.isEmpty || responseBody == '[]') {
          print('⚠️ Empty response from basic plots endpoint');
          return;
        }
        
        try {
          final dynamic responseData = json.decode(responseBody);
          print('📊 Response type: ${responseData.runtimeType}');
          
          if (responseData is List) {
            print('✅ Basic plots endpoint returns List with ${responseData.length} items');
          } else if (responseData is Map) {
            print('✅ Basic plots endpoint returns Map with keys: ${responseData.keys}');
          } else {
            print('❌ Unexpected response format: ${responseData.runtimeType}');
          }
          
        } catch (parseError) {
          print('❌ JSON parsing error in basic plots endpoint: $parseError');
        }
      } else {
        print('❌ Basic plots endpoint error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Basic plots endpoint test failed: $e');
    }
  }
  
  /// Test filtered plots endpoint
  static Future<void> _testFilteredPlotsEndpoint() async {
    print('\n📡 Testing filtered plots endpoint...');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/filtered-plots?price_from=5000000&price_to=10000000'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      print('📊 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseBody = response.body;
        print('📊 Response body length: ${responseBody.length}');
        
        if (responseBody.isEmpty || responseBody == '[]') {
          print('⚠️ Empty response from filtered plots endpoint');
          return;
        }
        
        try {
          final dynamic responseData = json.decode(responseBody);
          print('📊 Response type: ${responseData.runtimeType}');
          
          if (responseData is List) {
            print('✅ Filtered plots endpoint returns List with ${responseData.length} items');
          } else if (responseData is Map) {
            print('✅ Filtered plots endpoint returns Map with keys: ${responseData.keys}');
          } else {
            print('❌ Unexpected response format: ${responseData.runtimeType}');
          }
          
        } catch (parseError) {
          print('❌ JSON parsing error in filtered plots endpoint: $parseError');
        }
      } else {
        print('❌ Filtered plots endpoint error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Filtered plots endpoint test failed: $e');
    }
  }
  
  /// Test progressive filter service
  static Future<void> _testProgressiveFilterService() async {
    print('\n📡 Testing ProgressiveFilterService...');
    
    try {
      final response = await ProgressiveFilterService.filterByPriceRange(
        priceFrom: 5000000,
        priceTo: 10000000,
      );
      
      print('✅ ProgressiveFilterService returned ${response.plots.length} plots');
      print('✅ Success: ${response.success}');
      print('✅ Total count: ${response.counts.totalCount}');
      
    } catch (e) {
      print('❌ ProgressiveFilterService test failed: $e');
      print('❌ Error type: ${e.runtimeType}');
    }
  }
  
  /// Test enhanced plots API service
  static Future<void> _testEnhancedPlotsApiService() async {
    print('\n📡 Testing EnhancedPlotsApiService...');
    
    try {
      final plots = await EnhancedPlotsApiService.fetchFilteredPlots(
        minPrice: 5000000,
        maxPrice: 10000000,
      );
      
      print('✅ EnhancedPlotsApiService returned ${plots.length} plots');
      
    } catch (e) {
      print('❌ EnhancedPlotsApiService test failed: $e');
      print('❌ Error type: ${e.runtimeType}');
    }
  }
  
  /// Test plots service
  static Future<void> _testPlotsService() async {
    print('\n📡 Testing PlotsService...');
    
    try {
      final response = await PlotsService.getAllPlots();
      
      print('✅ PlotsService returned ${response.plots.length} plots');
      print('✅ Status: ${response.status}');
      
    } catch (e) {
      print('❌ PlotsService test failed: $e');
      print('❌ Error type: ${e.runtimeType}');
    }
  }
  
  /// Test specific error scenarios
  static Future<void> testErrorScenarios() async {
    print('\n🔍 Testing error scenarios...');
    
    // Test with invalid parameters
    try {
      final response = await ProgressiveFilterService.filterByPriceRange(
        priceFrom: -1,
        priceTo: -1,
      );
      print('⚠️ Unexpected success with invalid parameters');
    } catch (e) {
      print('✅ Correctly handled invalid parameters: $e');
    }
    
    // Test with extreme values
    try {
      final response = await ProgressiveFilterService.filterByPriceRange(
        priceFrom: 999999999,
        priceTo: 999999999,
      );
      print('✅ Handled extreme values: ${response.plots.length} plots');
    } catch (e) {
      print('✅ Correctly handled extreme values: $e');
    }
  }
}
