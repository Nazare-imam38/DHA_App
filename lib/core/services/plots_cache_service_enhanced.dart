import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/plot_model.dart';

/// Enhanced cache service for plots with zoom-level awareness and performance optimization
class PlotsCacheServiceEnhanced {
  static const String _cacheKey = 'enhanced_plots_cache';
  static const String _timestampKey = 'enhanced_plots_timestamp';
  static const String _zoomKey = 'enhanced_plots_zoom';
  static const Duration _cacheValidity = Duration(hours: 6);
  
  /// Check if cache is valid and fresh
  static Future<bool> isCacheValid({int? zoomLevel}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestampString = prefs.getString(_timestampKey);
      
      if (timestampString == null) return false;
      
      final timestamp = DateTime.parse(timestampString);
      final isTimeValid = DateTime.now().difference(timestamp) < _cacheValidity;
      
      if (zoomLevel != null) {
        final cachedZoom = prefs.getInt(_zoomKey) ?? 0;
        final isZoomValid = (zoomLevel - cachedZoom).abs() <= 2; // Allow 2 zoom levels difference
        return isTimeValid && isZoomValid;
      }
      
      return isTimeValid;
    } catch (e) {
      print('Error checking cache validity: $e');
      return false;
    }
  }
  
  /// Get cached plots with zoom level optimization
  static Future<List<PlotModel>> getCachedPlots({int? zoomLevel}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plotsString = prefs.getString(_cacheKey);
      
      if (plotsString == null) return [];
      
      final plotsJson = jsonDecode(plotsString) as List<dynamic>;
      final plots = plotsJson.map((json) => PlotModel.fromJson(json as Map<String, dynamic>)).toList();
      
      // Apply zoom-level optimization
      if (zoomLevel != null) {
        return _optimizePlotsForZoom(plots, zoomLevel);
      }
      
      return plots;
    } catch (e) {
      print('Error loading cached plots: $e');
      return [];
    }
  }
  
  /// Cache plots with zoom level information
  static Future<void> cachePlots(List<PlotModel> plots, {int? zoomLevel}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Optimize plots for caching (remove unnecessary data)
      final optimizedPlots = _optimizePlotsForCaching(plots);
      
      final plotsJson = optimizedPlots.map((plot) => plot.toJson()).toList();
      final plotsString = jsonEncode(plotsJson);
      
      await prefs.setString(_cacheKey, plotsString);
      await prefs.setString(_timestampKey, DateTime.now().toIso8601String());
      
      if (zoomLevel != null) {
        await prefs.setInt(_zoomKey, zoomLevel);
      }
      
      print('Enhanced cache: Stored ${plots.length} plots (${plotsString.length} bytes)');
    } catch (e) {
      print('Error caching plots: $e');
    }
  }
  
  /// Optimize plots for specific zoom level
  static List<PlotModel> _optimizePlotsForZoom(List<PlotModel> plots, int zoomLevel) {
    // At lower zoom levels, show fewer plots for better performance
    if (zoomLevel < 12) {
      return plots.take(50).toList(); // Show only first 50 plots
    } else if (zoomLevel < 15) {
      return plots.take(100).toList(); // Show first 100 plots
    }
    
    return plots; // Show all plots at high zoom levels
  }
  
  /// Optimize plots for caching by reducing data size
  static List<PlotModel> _optimizePlotsForCaching(List<PlotModel> plots) {
    return plots.map((plot) {
      // Create a simplified version for caching
      return PlotModel(
        id: plot.id,
        eventHistoryId: plot.eventHistoryId,
        plotNo: plot.plotNo,
        size: plot.size,
        category: plot.category,
        catArea: plot.catArea,
        dimension: plot.dimension,
        phase: plot.phase,
        sector: plot.sector,
        streetNo: plot.streetNo,
        block: plot.block,
        status: plot.status,
        tokenAmount: plot.tokenAmount,
        remarks: plot.remarks,
        basePrice: plot.basePrice,
        holdBy: plot.holdBy,
        expireTime: plot.expireTime,
        oneYrPlan: plot.oneYrPlan,
        twoYrsPlan: plot.twoYrsPlan,
        twoFiveYrsPlan: plot.twoFiveYrsPlan,
        threeYrsPlan: plot.threeYrsPlan,
        stAsgeojson: plot.stAsgeojson, // Keep GeoJSON for polygons
        eventHistory: plot.eventHistory,
        latitude: plot.latitude,
        longitude: plot.longitude,
        expoBasePrice: plot.expoBasePrice,
        vloggerBasePrice: plot.vloggerBasePrice,
      );
    }).toList();
  }
  
  /// Clear cache
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_timestampKey);
      await prefs.remove(_zoomKey);
      print('Enhanced cache cleared');
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }
  
  /// Get cache statistics
  static Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final plotsString = prefs.getString(_cacheKey);
      final timestampString = prefs.getString(_timestampKey);
      final zoomLevel = prefs.getInt(_zoomKey);
      
      int plotCount = 0;
      DateTime? lastUpdated;
      
      if (plotsString != null) {
        final plotsJson = jsonDecode(plotsString) as List;
        plotCount = plotsJson.length;
      }
      
      if (timestampString != null) {
        lastUpdated = DateTime.parse(timestampString);
      }
      
      return {
        'plot_count': plotCount,
        'cache_size_mb': (plotsString?.length ?? 0) / (1024 * 1024),
        'last_updated': lastUpdated?.toIso8601String(),
        'zoom_level': zoomLevel,
        'is_valid': await isCacheValid(),
      };
    } catch (e) {
      print('Error getting cache stats: $e');
      return {
        'plot_count': 0,
        'cache_size_mb': 0.0,
        'last_updated': null,
        'zoom_level': null,
        'is_valid': false,
      };
    }
  }
  
  /// Preload cache in background
  static Future<void> preloadCache(List<PlotModel> plots, {int? zoomLevel}) async {
    try {
      await cachePlots(plots, zoomLevel: zoomLevel);
      print('Cache preloaded with ${plots.length} plots');
    } catch (e) {
      print('Error preloading cache: $e');
    }
  }
}
