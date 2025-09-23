import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/plot_model.dart';
import 'plots_cache_service_enhanced.dart';

/// Optimized plots service with instant loading and smart caching
class OptimizedPlotsService {
  static const String baseUrl = 'https://testingbackend.dhamarketplace.com/api';
  static const Duration _cacheValidity = Duration(hours: 6);
  static const int _maxRetries = 3;
  static const Duration _timeout = Duration(seconds: 30);
  
  /// Load plots with instant cache fallback and zoom optimization
  static Future<List<PlotModel>> loadPlotsOptimized({
    int? zoomLevel,
    bool forceRefresh = false,
    bool useCache = true,
  }) async {
    print('OptimizedPlotsService: Loading plots with zoom level: $zoomLevel');
    
    // Try cache first if not forcing refresh
    if (useCache && !forceRefresh) {
      if (await PlotsCacheServiceEnhanced.isCacheValid(zoomLevel: zoomLevel)) {
        print('OptimizedPlotsService: Loading from enhanced cache');
        final cachedPlots = await PlotsCacheServiceEnhanced.getCachedPlots(zoomLevel: zoomLevel);
        if (cachedPlots.isNotEmpty) {
          return cachedPlots;
        }
      }
    }
    
    // Load from API with optimizations
    try {
      final plots = await _fetchPlotsFromApi(zoomLevel: zoomLevel);
      
      // Cache the results for future use
      if (plots.isNotEmpty) {
        await PlotsCacheServiceEnhanced.cachePlots(plots, zoomLevel: zoomLevel);
        print('OptimizedPlotsService: Cached ${plots.length} plots');
      }
      
      return plots;
    } catch (e) {
      print('OptimizedPlotsService: API failed, trying cache fallback: $e');
      
      // Fallback to cache even if expired
      final cachedPlots = await PlotsCacheServiceEnhanced.getCachedPlots(zoomLevel: zoomLevel);
      if (cachedPlots.isNotEmpty) {
        print('OptimizedPlotsService: Using cache fallback with ${cachedPlots.length} plots');
        return cachedPlots;
      }
      
      rethrow;
    }
  }
  
  /// Fetch plots from API with retry logic and timeout
  static Future<List<PlotModel>> _fetchPlotsFromApi({int? zoomLevel}) async {
    int attempts = 0;
    
    while (attempts < _maxRetries) {
      try {
        print('OptimizedPlotsService: API attempt ${attempts + 1}/$_maxRetries');
        
        final response = await http.get(
          Uri.parse('$baseUrl/plots'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Cache-Control': 'no-cache',
          },
        ).timeout(_timeout);
        
        print('OptimizedPlotsService: Response status: ${response.statusCode}');
        print('OptimizedPlotsService: Response size: ${response.body.length} bytes');
        
        if (response.statusCode == 200) {
          if (response.body.isEmpty) {
            throw Exception('Empty response from API');
          }
          
          final List<dynamic> jsonData = jsonDecode(response.body);
          final plots = jsonData.map((json) => PlotModel.fromJson(json)).toList();
          
          // Apply zoom-level optimization
          final optimizedPlots = _optimizePlotsForZoom(plots, zoomLevel);
          
          print('OptimizedPlotsService: Loaded ${plots.length} plots, optimized to ${optimizedPlots.length}');
          return optimizedPlots;
        } else if (response.statusCode == 429) {
          // Rate limited, wait and retry
          final waitTime = Duration(seconds: 2 * (attempts + 1));
          print('OptimizedPlotsService: Rate limited, waiting ${waitTime.inSeconds}s');
          await Future.delayed(waitTime);
          attempts++;
          continue;
        } else {
          throw Exception('API Error ${response.statusCode}: ${response.reasonPhrase}');
        }
      } catch (e) {
        attempts++;
        print('OptimizedPlotsService: Error attempt $attempts: $e');
        
        if (attempts >= _maxRetries) {
          print('OptimizedPlotsService: All retry attempts failed');
          throw Exception('Failed to load plots after $_maxRetries attempts: $e');
        }
        
        // Wait before retrying
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
    
    throw Exception('Failed to load plots after $_maxRetries attempts');
  }
  
  /// Optimize plots based on zoom level for better performance
  static List<PlotModel> _optimizePlotsForZoom(List<PlotModel> plots, int? zoomLevel) {
    if (zoomLevel == null) return plots;
    
    // At lower zoom levels, show fewer plots for better performance
    if (zoomLevel < 12) {
      return plots.take(50).toList(); // Show only first 50 plots
    } else if (zoomLevel < 15) {
      return plots.take(100).toList(); // Show first 100 plots
    } else if (zoomLevel < 18) {
      return plots.take(200).toList(); // Show first 200 plots
    }
    
    return plots; // Show all plots at high zoom levels
  }
  
  /// Load plots by phase with optimization
  static Future<List<PlotModel>> loadPlotsByPhase(String phase, {int? zoomLevel}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/plots?phase=$phase'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final plots = jsonData.map((json) => PlotModel.fromJson(json)).toList();
        return _optimizePlotsForZoom(plots, zoomLevel);
      } else {
        throw Exception('Failed to load plots by phase: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading plots by phase: $e');
      throw Exception('Failed to load plots by phase: $e');
    }
  }
  
  /// Load plots with filters and optimization
  static Future<List<PlotModel>> loadPlotsWithFilters({
    String? phase,
    String? category,
    String? status,
    double? minPrice,
    double? maxPrice,
    int? zoomLevel,
  }) async {
    try {
      final queryParams = <String, String>{};
      
      if (phase != null) queryParams['phase'] = phase;
      if (category != null) queryParams['category'] = category;
      if (status != null) queryParams['status'] = status;
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      
      final uri = Uri.parse('$baseUrl/plots').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final plots = jsonData.map((json) => PlotModel.fromJson(json)).toList();
        return _optimizePlotsForZoom(plots, zoomLevel);
      } else {
        throw Exception('Failed to load filtered plots: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading filtered plots: $e');
      throw Exception('Failed to load filtered plots: $e');
    }
  }
  
  /// Preload plots in background for instant access
  static Future<void> preloadPlots({int? zoomLevel}) async {
    try {
      print('OptimizedPlotsService: Preloading plots in background...');
      await loadPlotsOptimized(zoomLevel: zoomLevel, useCache: false);
      print('OptimizedPlotsService: Preload completed');
    } catch (e) {
      print('OptimizedPlotsService: Preload failed: $e');
    }
  }
  
  /// Get cache statistics
  static Future<Map<String, dynamic>> getCacheStats() async {
    return await PlotsCacheServiceEnhanced.getCacheStats();
  }
  
  /// Clear cache
  static Future<void> clearCache() async {
    await PlotsCacheServiceEnhanced.clearCache();
  }
  
  /// Check if cache is valid
  static Future<bool> isCacheValid({int? zoomLevel}) async {
    return await PlotsCacheServiceEnhanced.isCacheValid(zoomLevel: zoomLevel);
  }
}
