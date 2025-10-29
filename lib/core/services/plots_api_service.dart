import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/plot_model.dart';

/// Simple plots API service for basic functionality
class PlotsApiService {
  static const String baseUrl = 'https://testingbackend.dhamarketplace.com/api';
  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  /// Fetch all plots from the API
  static Future<List<PlotModel>> fetchPlots() async {
    print('PlotsApiService: Fetching plots from $baseUrl/plots');
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        print('PlotsApiService: Attempt $attempt/$_maxRetries');
        
        final response = await http.get(
          Uri.parse('$baseUrl/plots'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(_timeout);
        
        print('PlotsApiService: Response status: ${response.statusCode}');
        print('PlotsApiService: Response body length: ${response.body.length}');
        
        if (response.statusCode == 200) {
          final responseBody = response.body;
          print('PlotsApiService: Raw response: $responseBody');
          
          if (responseBody.isEmpty || responseBody == '[]') {
            print('PlotsApiService: ⚠️ Empty response from API');
            return [];
          }
          
          try {
            final List<dynamic> jsonData = json.decode(responseBody);
            print('PlotsApiService: Parsed ${jsonData.length} items from API');
            
            if (jsonData.isEmpty) {
              print('PlotsApiService: ⚠️ No plots in API response');
              return [];
            }
            
            // Parse each plot with error handling
            final List<PlotModel> plots = [];
            for (int i = 0; i < jsonData.length; i++) {
              try {
                final plot = PlotModel.fromJson(jsonData[i] as Map<String, dynamic>);
                plots.add(plot);
                print('PlotsApiService: ✅ Parsed plot ${i + 1}: ${plot.plotNo}');
              } catch (e) {
                print('PlotsApiService: ❌ Error parsing plot ${i + 1}: $e');
                // Continue with other plots
                continue;
              }
            }
            
            print('PlotsApiService: ✅ Successfully loaded ${plots.length} plots');
            return plots;
            
          } catch (parseError) {
            print('PlotsApiService: ❌ JSON parsing error: $parseError');
            print('PlotsApiService: Raw response: $responseBody');
            throw Exception('Failed to parse API response: $parseError');
          }
        } else {
          print('PlotsApiService: ❌ API error ${response.statusCode}: ${response.reasonPhrase}');
          throw Exception('API error ${response.statusCode}: ${response.reasonPhrase}');
        }
      } catch (e) {
        print('PlotsApiService: ❌ Attempt $attempt failed: $e');
        
        if (attempt == _maxRetries) {
          print('PlotsApiService: ❌ All attempts failed');
          throw Exception('Failed to fetch plots after $_maxRetries attempts: $e');
        }
        
        // Wait before retry
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    
    throw Exception('Failed to fetch plots');
  }

  /// Test API connectivity
  static Future<Map<String, dynamic>> testApi() async {
    try {
      print('PlotsApiService: Testing API connectivity...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/plots'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('PlotsApiService: Test response status: ${response.statusCode}');
      print('PlotsApiService: Test response body: ${response.body}');
      
      return {
        'statusCode': response.statusCode,
        'bodyLength': response.body.length,
        'body': response.body,
        'isEmpty': response.body.isEmpty || response.body == '[]',
      };
    } catch (e) {
      print('PlotsApiService: Test error: $e');
      return {
        'error': e.toString(),
      };
    }
  }
}
