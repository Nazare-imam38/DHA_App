import 'dart:convert';
import 'package:http/http.dart' as http;
import '../data/models/plot_model.dart';

class PlotsService {
  static const String baseUrl = 'https://backend-apis.dhamarketplace.com/api';
  
  // Test the API endpoint
  static Future<void> testPlotsApi() async {
    try {
      print('Testing plots API...');
      final response = await http.get(
        Uri.parse('$baseUrl/plots'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API Response Structure:');
        print('- Status: ${data['status']}');
        print('- Plots count: ${data['plots']?.length ?? 0}');
        
        if (data['plots'] != null && data['plots'].isNotEmpty) {
          print('Sample plot data:');
          print(json.encode(data['plots'][0]));
        }
      } else {
        print('API Error: ${response.statusCode}');
        print('Error body: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
    }
  }

  // Get all plots
  static Future<PlotsResponse> getAllPlots() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/plots'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Handle both response formats: List directly or Map with wrapper
        if (data is List) {
          // API returns List directly
          return PlotsResponse.fromJsonArray(data);
        } else if (data is Map<String, dynamic>) {
          // API returns Map with wrapper
          return PlotsResponse.fromJson(data);
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load plots: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching plots: $e');
    }
  }

  // Get plots with filters
  static Future<PlotsResponse> getPlotsWithFilters({
    String? category,
    String? phase,
    String? sector,
    String? size,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      String url = '$baseUrl/plots';
      final queryParams = <String, String>{};
      
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (phase != null && phase.isNotEmpty) {
        queryParams['phase'] = phase;
      }
      if (sector != null && sector.isNotEmpty) {
        queryParams['sector'] = sector;
      }
      if (size != null && size.isNotEmpty) {
        queryParams['cat_area'] = size;
      }
      if (minPrice != null) {
        queryParams['min_price'] = minPrice.toString();
      }
      if (maxPrice != null) {
        queryParams['max_price'] = maxPrice.toString();
      }

      if (queryParams.isNotEmpty) {
        final uri = Uri.parse(url).replace(queryParameters: queryParams);
        url = uri.toString();
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Handle both response formats: List directly or Map with wrapper
        if (data is List) {
          // API returns List directly
          return PlotsResponse.fromJsonArray(data);
        } else if (data is Map<String, dynamic>) {
          // API returns Map with wrapper
          return PlotsResponse.fromJson(data);
        } else {
          throw Exception('Unexpected response format: ${data.runtimeType}');
        }
      } else {
        throw Exception('Failed to load plots: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching plots: $e');
    }
  }
}
