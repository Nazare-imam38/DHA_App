import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../data/models/plot_model.dart';

/// State manager for polygon coordinates to avoid repeated parsing
class PolygonStateProvider extends ChangeNotifier {
  // Cache for all polygon coordinates
  final Map<int, List<List<LatLng>>> _polygonCache = {};
  
  // Track which plots have been processed
  final Set<int> _processedPlots = {};
  
  // Track parsing errors
  final Map<int, String> _parsingErrors = {};
  
  /// Get polygon coordinates for a plot (with caching)
  List<List<LatLng>> getPolygonCoordinates(PlotModel plot) {
    // Return cached coordinates if available
    if (_polygonCache.containsKey(plot.id)) {
      return _polygonCache[plot.id]!;
    }
    
    // Parse and cache coordinates
    return _parseAndCachePolygonCoordinates(plot);
  }
  
  /// Parse and cache polygon coordinates for a plot
  List<List<LatLng>> _parseAndCachePolygonCoordinates(PlotModel plot) {
    try {
      print('PolygonStateProvider: Parsing coordinates for plot ${plot.plotNo} (ID: ${plot.id})');
      
      // Use the plot's polygon coordinates getter
      final coordinates = plot.polygonCoordinates;
      
      if (coordinates.isNotEmpty) {
        // Cache the successful result
        _polygonCache[plot.id] = coordinates;
        _processedPlots.add(plot.id);
        print('PolygonStateProvider: ✅ Cached ${coordinates.length} polygons for plot ${plot.plotNo}');
        return coordinates;
      } else {
        print('PolygonStateProvider: ⚠️ No polygons found for plot ${plot.plotNo}');
        _parsingErrors[plot.id] = 'No polygons found';
        _processedPlots.add(plot.id);
        return [];
      }
    } catch (e) {
      print('PolygonStateProvider: ❌ Error parsing plot ${plot.plotNo}: $e');
      _parsingErrors[plot.id] = e.toString();
      _processedPlots.add(plot.id);
      return [];
    }
  }
  
  /// Pre-cache polygon coordinates for multiple plots
  void preCachePolygonCoordinates(List<PlotModel> plots) {
    print('PolygonStateProvider: Pre-caching coordinates for ${plots.length} plots...');
    
    int successCount = 0;
    int errorCount = 0;
    
    for (final plot in plots) {
      try {
        final coordinates = getPolygonCoordinates(plot);
        if (coordinates.isNotEmpty) {
          successCount++;
        } else {
          errorCount++;
        }
      } catch (e) {
        errorCount++;
        print('PolygonStateProvider: Error pre-caching plot ${plot.plotNo}: $e');
      }
    }
    
    print('PolygonStateProvider: Pre-caching completed - Success: $successCount, Errors: $errorCount');
    notifyListeners();
  }
  
  /// Get plots with valid polygon coordinates
  List<PlotModel> getPlotsWithPolygons(List<PlotModel> plots) {
    return plots.where((plot) => getPolygonCoordinates(plot).isNotEmpty).toList();
  }
  
  /// Check if a plot has valid polygon coordinates
  bool hasValidPolygons(PlotModel plot) {
    return getPolygonCoordinates(plot).isNotEmpty;
  }
  
  /// Get polygon statistics
  Map<String, dynamic> getPolygonStats(List<PlotModel> plots) {
    int totalPlots = plots.length;
    int plotsWithPolygons = 0;
    int processedPlots = 0;
    int errorPlots = 0;
    
    for (final plot in plots) {
      if (_processedPlots.contains(plot.id)) {
        processedPlots++;
        if (hasValidPolygons(plot)) {
          plotsWithPolygons++;
        } else {
          errorPlots++;
        }
      }
    }
    
    return {
      'total_plots': totalPlots,
      'processed_plots': processedPlots,
      'plots_with_polygons': plotsWithPolygons,
      'error_plots': errorPlots,
      'cache_size': _polygonCache.length,
    };
  }
  
  /// Clear polygon cache for a specific plot
  void clearPlotCache(int plotId) {
    _polygonCache.remove(plotId);
    _processedPlots.remove(plotId);
    _parsingErrors.remove(plotId);
    print('PolygonStateProvider: Cleared cache for plot ID: $plotId');
  }
  
  /// Clear all polygon caches
  void clearAllCaches() {
    _polygonCache.clear();
    _processedPlots.clear();
    _parsingErrors.clear();
    print('PolygonStateProvider: Cleared all polygon caches');
    notifyListeners();
  }
  
  /// Get parsing error for a plot
  String? getParsingError(int plotId) {
    return _parsingErrors[plotId];
  }
  
  /// Check if a plot has been processed
  bool isPlotProcessed(int plotId) {
    return _processedPlots.contains(plotId);
  }
}
