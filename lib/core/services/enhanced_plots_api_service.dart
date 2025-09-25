import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/plot_model.dart';

/// Enhanced plots API service with modern filtering capabilities
class EnhancedPlotsApiService {
  static const String baseUrl = 'https://backend-apis.dhamarketplace.com/api';
  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  /// Fetch plots with modern filtering
  static Future<List<PlotModel>> fetchFilteredPlots({
    double? minPrice,
    double? maxPrice,
    String? category,
    String? phase,
    String? size,
    String? status,
    String? sector,
  }) async {
    print('EnhancedPlotsApiService: Fetching filtered plots...');
    
    // Build query parameters
    final Map<String, String> queryParams = {};
    
    if (minPrice != null) queryParams['price_min'] = minPrice.toString();
    if (maxPrice != null) queryParams['price_max'] = maxPrice.toString();
    if (category != null) queryParams['category'] = category;
    if (phase != null) {
      // Convert phase names to API format
      String apiPhase = _convertPhaseToApiFormat(phase);
      queryParams['phase'] = apiPhase;
    }
    if (size != null) queryParams['size'] = size;
    if (status != null) queryParams['status'] = status;
    if (sector != null) queryParams['sector'] = sector;
    
    // Build URL with query parameters
    final uri = Uri.parse('$baseUrl/plots').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    
    print('EnhancedPlotsApiService: Request URL: $uri');
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        print('EnhancedPlotsApiService: Attempt $attempt/$_maxRetries');
        
        final response = await http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(_timeout);
        
        print('EnhancedPlotsApiService: Response status: ${response.statusCode}');
        print('EnhancedPlotsApiService: Response body length: ${response.body.length}');
        
        if (response.statusCode == 200) {
          final responseBody = response.body;
          print('EnhancedPlotsApiService: Raw response: $responseBody');
          
          if (responseBody.isEmpty || responseBody == '[]') {
            print('EnhancedPlotsApiService: ⚠️ Empty response from API');
            return [];
          }
          
          try {
            final List<dynamic> jsonData = json.decode(responseBody);
            print('EnhancedPlotsApiService: Parsed ${jsonData.length} items from API');
            
            if (jsonData.isEmpty) {
              print('EnhancedPlotsApiService: ⚠️ No plots in API response');
              return [];
            }
            
            // Parse each plot with error handling
            final List<PlotModel> plots = [];
            for (int i = 0; i < jsonData.length; i++) {
              try {
                final plot = PlotModel.fromJson(jsonData[i] as Map<String, dynamic>);
                plots.add(plot);
                print('EnhancedPlotsApiService: ✅ Parsed plot ${i + 1}: ${plot.plotNo}');
              } catch (e) {
                print('EnhancedPlotsApiService: ❌ Error parsing plot ${i + 1}: $e');
                // Continue with other plots
                continue;
              }
            }
            
            print('EnhancedPlotsApiService: ✅ Successfully loaded ${plots.length} filtered plots');
            return plots;
            
          } catch (parseError) {
            print('EnhancedPlotsApiService: ❌ JSON parsing error: $parseError');
            print('EnhancedPlotsApiService: Raw response: $responseBody');
            throw Exception('Failed to parse API response: $parseError');
          }
        } else {
          print('EnhancedPlotsApiService: ❌ API error ${response.statusCode}: ${response.reasonPhrase}');
          throw Exception('API error ${response.statusCode}: ${response.reasonPhrase}');
        }
      } catch (e) {
        print('EnhancedPlotsApiService: ❌ Attempt $attempt failed: $e');
        
        if (attempt == _maxRetries) {
          print('EnhancedPlotsApiService: ❌ All attempts failed');
          throw Exception('Failed to fetch filtered plots after $_maxRetries attempts: $e');
        }
        
        // Wait before retry
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    
    throw Exception('Failed to fetch filtered plots');
  }

  /// Fetch all plots (no filters)
  static Future<List<PlotModel>> fetchAllPlots() async {
    return fetchFilteredPlots();
  }

  /// Convert phase names to API format
  static String _convertPhaseToApiFormat(String phase) {
    print('EnhancedPlotsApiService: Converting phase "$phase" to API format');
    
    // Handle different phase formats
    if (phase.toLowerCase().contains('phase')) {
      // Extract number from "Phase 1", "Phase 2", etc.
      final match = RegExp(r'phase\s*(\d+)', caseSensitive: false).firstMatch(phase);
      if (match != null) {
        final number = match.group(1);
        print('EnhancedPlotsApiService: Converted "$phase" to "$number"');
        return number!;
      }
    }
    
    // Handle RVS and other special cases
    if (phase.toUpperCase() == 'RVS') {
      print('EnhancedPlotsApiService: Keeping RVS as is');
      return 'RVS';
    }
    
    // If it's already a number, return as is
    if (RegExp(r'^\d+$').hasMatch(phase)) {
      print('EnhancedPlotsApiService: Phase is already a number: $phase');
      return phase;
    }
    
    // Default fallback
    print('EnhancedPlotsApiService: Using phase as-is: $phase');
    return phase;
  }

  /// Test API connectivity with filters
  static Future<Map<String, dynamic>> testFilteredApi({
    double? minPrice,
    double? maxPrice,
    String? category,
    String? phase,
    String? size,
    String? status,
    String? sector,
  }) async {
    try {
      print('EnhancedPlotsApiService: Testing filtered API connectivity...');
      
      // Build query parameters
      final Map<String, String> queryParams = {};
      
      if (minPrice != null) queryParams['price_min'] = minPrice.toString();
      if (maxPrice != null) queryParams['price_max'] = maxPrice.toString();
      if (category != null) queryParams['category'] = category;
      if (phase != null) {
        // Convert phase names to API format
        String apiPhase = _convertPhaseToApiFormat(phase);
        queryParams['phase'] = apiPhase;
      }
      if (size != null) queryParams['size'] = size;
      if (status != null) queryParams['status'] = status;
      if (sector != null) queryParams['sector'] = sector;
      
      // Build URL with query parameters
      final uri = Uri.parse('$baseUrl/plots').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('EnhancedPlotsApiService: Test response status: ${response.statusCode}');
      print('EnhancedPlotsApiService: Test response body: ${response.body}');
      
      return {
        'statusCode': response.statusCode,
        'bodyLength': response.body.length,
        'body': response.body,
        'isEmpty': response.body.isEmpty || response.body == '[]',
        'url': uri.toString(),
      };
    } catch (e) {
      print('EnhancedPlotsApiService: Test error: $e');
      return {
        'error': e.toString(),
      };
    }
  }
}
