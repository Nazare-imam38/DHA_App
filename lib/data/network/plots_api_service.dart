import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/plot_model.dart';
import '../repository/plots_repository.dart';

class PlotsApiService {
  static const String baseUrl = 'https://backend-apis.dhamarketplace.com/api';
  
  static Future<List<PlotModel>> fetchPlots({int retryCount = 3}) async {
    int attempts = 0;
    
    print('PlotsApiService: Starting API call to $baseUrl/plots');
    print('PlotsApiService: Full URL: $baseUrl/plots');
    
    while (attempts < retryCount) {
      try {
        print('PlotsApiService: Attempt ${attempts + 1}/$retryCount');
        final response = await http.get(
          Uri.parse('$baseUrl/plots'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 30));
        
        print('PlotsApiService: Response status: ${response.statusCode}');
        print('PlotsApiService: Response body length: ${response.body.length}');

        if (response.statusCode == 200) {
          final responseBody = response.body;
          print('PlotsApiService: Full response body: $responseBody');
          
          if (responseBody.isEmpty) {
            print('PlotsApiService: ❌ Empty response body');
            throw Exception('Empty response body');
          }
          
          try {
            final List<dynamic> jsonData = json.decode(responseBody);
            print('PlotsApiService: Parsed ${jsonData.length} JSON objects');
            
            if (jsonData.isEmpty) {
              print('PlotsApiService: ⚠️ No plots found in API response');
              print('PlotsApiService: Full response body: $responseBody');
              return [];
            }
            
            print('PlotsApiService: First JSON object keys: ${jsonData.first.keys.toList()}');
            
            final plots = jsonData.map((json) => PlotModel.fromJson(json)).toList();
            
            print('PlotsApiService: ✅ Successfully fetched ${plots.length} plots from API');
            if (plots.isNotEmpty) {
              print('PlotsApiService: First plot: ${plots.first.plotNo}');
              print('PlotsApiService: First plot GeoJSON length: ${plots.first.stAsgeojson.length}');
              print('PlotsApiService: First plot GeoJSON preview: ${plots.first.stAsgeojson.substring(0, min(200, plots.first.stAsgeojson.length))}...');
            }
            return plots;
          } catch (parseError) {
            print('PlotsApiService: ❌ Error parsing JSON: $parseError');
            print('PlotsApiService: Raw response: $responseBody');
            throw Exception('JSON parsing error: $parseError');
          }
        } else if (response.statusCode == 429) {
          // Rate limited, wait and retry
          await Future.delayed(Duration(seconds: 2 * (attempts + 1)));
          attempts++;
          continue;
        } else {
          throw Exception('API Error ${response.statusCode}: ${response.reasonPhrase}');
        }
      } catch (e) {
        attempts++;
        print('Error fetching plots (attempt $attempts/$retryCount): $e');
        print('Error type: ${e.runtimeType}');
        print('Error details: $e');
        
        if (attempts >= retryCount) {
          print('All retry attempts failed. Final error: $e');
          throw Exception('Failed to load plots after $retryCount attempts: $e');
        }
        
        // Wait before retrying
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
    
    throw Exception('Failed to load plots after $retryCount attempts');
  }

  static Future<List<PlotModel>> fetchPlotsByPhase(String phase) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/plots?phase=$phase'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => PlotModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load plots by phase: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching plots by phase: $e');
      throw Exception('Failed to load plots by phase: $e');
    }
  }

  static Future<List<PlotModel>> fetchPlotsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/plots?category=$category'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => PlotModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load plots by category: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching plots by category: $e');
      throw Exception('Failed to load plots by category: $e');
    }
  }

  static Future<List<PlotModel>> fetchPlotsByPriceRange(double minPrice, double maxPrice) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/plots?min_price=$minPrice&max_price=$maxPrice'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => PlotModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load plots by price range: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching plots by price range: $e');
      throw Exception('Failed to load plots by price range: $e');
    }
  }

  static Future<List<PlotModel>> fetchPlotsByStatus(String status) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/plots?status=$status'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => PlotModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load plots by status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching plots by status: $e');
      throw Exception('Failed to load plots by status: $e');
    }
  }

  /// Fetch a single plot by ID
  static Future<PlotModel> fetchPlotById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/plot/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Handle different response formats
        Map<String, dynamic> jsonData;
        if (responseData is Map<String, dynamic>) {
          jsonData = responseData;
        } else if (responseData is List && responseData.isNotEmpty) {
          jsonData = responseData.first as Map<String, dynamic>;
        } else {
          throw Exception('Invalid response format for plot $id');
        }
        
        return PlotModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load plot $id: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching plot by ID: $e');
      throw Exception('Failed to load plot $id: $e');
    }
  }

  /// Search plots with multiple criteria using the new filter endpoint
  static Future<List<PlotModel>> searchPlots({
    String? phase,
    String? sector,
    String? status,
    String? category,
    String? size,
    double? minPrice,
    double? maxPrice,
    double? minTokenAmount,
    double? maxTokenAmount,
    bool? hasInstallmentPlan,
    bool? isAvailable,
    bool? hasRemarks,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      // Use the new filter-plots-range endpoint for price filtering
      if (minPrice != null) queryParams['price_from'] = minPrice.toString();
      if (maxPrice != null) queryParams['price_to'] = maxPrice.toString();
      
      // For other filters, we'll use the regular plots endpoint
      if (phase != null) queryParams['phase'] = phase;
      if (sector != null) queryParams['sector'] = sector;
      if (status != null) queryParams['status'] = status;
      if (category != null) queryParams['category'] = category;
      if (size != null) queryParams['cat_area'] = size;

      // Use the new endpoint if we have price filters, otherwise use the regular endpoint
      final String endpoint = (minPrice != null || maxPrice != null) 
          ? '$baseUrl/filter-plots-range' 
          : '$baseUrl/plots';
      
      final uri = Uri.parse(endpoint).replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Handle the new API response format
        List<dynamic> jsonData;
        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          jsonData = responseData['data']['plots'] ?? [];
        } else {
          jsonData = responseData is List ? responseData : [];
        }
        
        List<PlotModel> plots = jsonData.map((json) => PlotModel.fromJson(json)).toList();
        
        // Apply additional client-side filters
        if (minTokenAmount != null || maxTokenAmount != null) {
          plots = plots.where((plot) {
            final tokenAmount = double.tryParse(plot.tokenAmount) ?? 0;
            if (minTokenAmount != null && tokenAmount < minTokenAmount) return false;
            if (maxTokenAmount != null && tokenAmount > maxTokenAmount) return false;
            return true;
          }).toList();
        }
        
        if (hasInstallmentPlan == true) {
          plots = plots.where((plot) {
            return (double.tryParse(plot.oneYrPlan) ?? 0) > 0 ||
                   (double.tryParse(plot.twoYrsPlan) ?? 0) > 0 ||
                   (double.tryParse(plot.twoFiveYrsPlan) ?? 0) > 0 ||
                   (double.tryParse(plot.threeYrsPlan) ?? 0) > 0;
          }).toList();
        }
        
        if (isAvailable == true) {
          plots = plots.where((plot) => plot.status.toLowerCase() == 'unsold').toList();
        }
        
        if (hasRemarks == true) {
          plots = plots.where((plot) => plot.remarks != null && plot.remarks!.isNotEmpty).toList();
        }
        
        return plots;
      } else {
        throw Exception('Failed to search plots: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching plots: $e');
      throw Exception('Failed to search plots: $e');
    }
  }

  /// Get all plots (for repository compatibility)
  Future<PlotsResponse> getAllPlots() async {
    try {
      final plots = await fetchPlots();
      return PlotsResponse(
        status: 'success',
        plots: plots,
      );
    } catch (e) {
      return PlotsResponse(
        status: 'error',
        plots: [],
        message: e.toString(),
      );
    }
  }

  /// Get plot by ID (for repository compatibility)
  Future<PlotModel> getPlotById(int plotId) async {
    return await fetchPlotById(plotId);
  }

  /// Search plots with keyword (for repository compatibility)
  Future<PlotsResponse> searchPlotsWithFilters(String keyword) async {
    try {
      final plots = await fetchPlots();
      
      // Filter by keyword if provided
      final filteredPlots = keyword.isNotEmpty
          ? plots.where((plot) =>
              plot.plotNo.toLowerCase().contains(keyword.toLowerCase()) ||
              plot.phase.toLowerCase().contains(keyword.toLowerCase()) ||
              plot.sector.toLowerCase().contains(keyword.toLowerCase()) ||
              plot.category.toLowerCase().contains(keyword.toLowerCase()))
          : plots;
      
      return PlotsResponse(
        status: 'success',
        plots: filteredPlots.toList(),
      );
    } catch (e) {
      return PlotsResponse(
        status: 'error',
        plots: [],
        message: e.toString(),
      );
    }
  }
}