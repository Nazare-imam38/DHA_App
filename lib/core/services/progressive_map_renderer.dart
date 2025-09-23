import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/plot_model.dart';

/// Progressive map renderer for enterprise-grade performance
/// Renders data progressively based on zoom level and viewport
class ProgressiveMapRenderer {
  static const int _maxPlotsLowZoom = 50;
  static const int _maxPlotsMediumZoom = 200;
  static const int _maxPlotsHighZoom = 500;
  
  // Rendering state management
  static final Map<String, List<PlotModel>> _renderedPlots = {};
  static final Map<String, DateTime> _renderTimestamps = {};
  static final Map<String, double> _lastZoomLevels = {};
  
  // Performance monitoring
  static final Map<String, int> _performanceMetrics = {};
  
  /// Render plots progressively based on zoom level
  static Future<List<PlotModel>> renderPlotsProgressive({
    required List<PlotModel> allPlots,
    required double zoomLevel,
    required LatLng center,
    required double radiusKm,
    bool forceRerender = false,
  }) async {
    final startTime = DateTime.now();
    final renderKey = _createRenderKey(zoomLevel, center, radiusKm);
    
    // Check if we can use cached render
    if (!forceRerender && _isRenderCacheValid(renderKey, zoomLevel)) {
      _recordPerformance('render_cache_hit', 1);
      return _getFromRenderCache(renderKey);
    }
    
    // Determine rendering strategy based on zoom level
    List<PlotModel> plotsToRender;
    
    if (zoomLevel < 12) {
      // Low zoom: Show only markers, no polygons
      plotsToRender = _renderLowZoom(allPlots, center, radiusKm);
    } else if (zoomLevel < 15) {
      // Medium zoom: Show simplified polygons
      plotsToRender = _renderMediumZoom(allPlots, center, radiusKm);
    } else {
      // High zoom: Show full detail
      plotsToRender = _renderHighZoom(allPlots, center, radiusKm);
    }
    
    // Cache the rendered result
    _storeInRenderCache(renderKey, plotsToRender, zoomLevel);
    
    final renderTime = DateTime.now().difference(startTime).inMilliseconds;
    _recordPerformance('render_time_ms', renderTime);
    
    print('ProgressiveMapRenderer: Rendered ${plotsToRender.length} plots in ${renderTime}ms (zoom: $zoomLevel)');
    return plotsToRender;
  }
  
  /// Render for low zoom levels (markers only)
  static List<PlotModel> _renderLowZoom(
    List<PlotModel> allPlots,
    LatLng center,
    double radiusKm,
  ) {
    // Filter by viewport
    final viewportPlots = _filterByViewport(allPlots, center, radiusKm);
    
    // Limit number of plots for performance
    final limitedPlots = viewportPlots.take(_maxPlotsLowZoom).toList();
    
    // Sort by importance (price, status, etc.)
    limitedPlots.sort((a, b) {
      // Prioritize available plots
      if (a.status.toLowerCase() == 'unsold' && b.status.toLowerCase() != 'unsold') return -1;
      if (b.status.toLowerCase() == 'unsold' && a.status.toLowerCase() != 'unsold') return 1;
      
      // Then by price (higher price first)
      final priceA = double.tryParse(a.basePrice) ?? 0;
      final priceB = double.tryParse(b.basePrice) ?? 0;
      return priceB.compareTo(priceA);
    });
    
    return limitedPlots;
  }
  
  /// Render for medium zoom levels (simplified polygons)
  static List<PlotModel> _renderMediumZoom(
    List<PlotModel> allPlots,
    LatLng center,
    double radiusKm,
  ) {
    // Filter by viewport
    final viewportPlots = _filterByViewport(allPlots, center, radiusKm);
    
    // Limit number of plots
    final limitedPlots = viewportPlots.take(_maxPlotsMediumZoom).toList();
    
    // Sort by importance
    limitedPlots.sort((a, b) {
      // Prioritize by category (commercial first)
      if (a.category.toLowerCase() == 'commercial' && b.category.toLowerCase() != 'commercial') return -1;
      if (b.category.toLowerCase() == 'commercial' && a.category.toLowerCase() != 'commercial') return 1;
      
      // Then by price
      final priceA = double.tryParse(a.basePrice) ?? 0;
      final priceB = double.tryParse(b.basePrice) ?? 0;
      return priceB.compareTo(priceA);
    });
    
    return limitedPlots;
  }
  
  /// Render for high zoom levels (full detail)
  static List<PlotModel> _renderHighZoom(
    List<PlotModel> allPlots,
    LatLng center,
    double radiusKm,
  ) {
    // Filter by viewport
    final viewportPlots = _filterByViewport(allPlots, center, radiusKm);
    
    // Limit number of plots
    final limitedPlots = viewportPlots.take(_maxPlotsHighZoom).toList();
    
    // Sort by distance from center
    limitedPlots.sort((a, b) {
      if (a.latitude == null || a.longitude == null) return 1;
      if (b.latitude == null || b.longitude == null) return -1;
      
      final distanceA = _calculateDistance(
        center.latitude,
        center.longitude,
        a.latitude!,
        a.longitude!,
      );
      final distanceB = _calculateDistance(
        center.latitude,
        center.longitude,
        b.latitude!,
        b.longitude!,
      );
      
      return distanceA.compareTo(distanceB);
    });
    
    return limitedPlots;
  }
  
  /// Filter plots by viewport
  static List<PlotModel> _filterByViewport(
    List<PlotModel> plots,
    LatLng center,
    double radiusKm,
  ) {
    return plots.where((plot) {
      if (plot.latitude == null || plot.longitude == null) return false;
      
      final distance = _calculateDistance(
        center.latitude,
        center.longitude,
        plot.latitude!,
        plot.longitude!,
      );
      
      return distance <= radiusKm;
    }).toList();
  }
  
  /// Calculate distance between two points
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
  }
  
  static double _degreesToRadians(double degrees) => degrees * (3.14159265359 / 180);
  
  /// Create render cache key
  static String _createRenderKey(double zoomLevel, LatLng center, double radiusKm) {
    return 'render_${zoomLevel.round()}_${center.latitude.toStringAsFixed(2)}_${center.longitude.toStringAsFixed(2)}_${radiusKm.toStringAsFixed(1)}';
  }
  
  /// Render cache management
  static void _storeInRenderCache(String key, List<PlotModel> data, double zoomLevel) {
    _renderedPlots[key] = data;
    _renderTimestamps[key] = DateTime.now();
    _lastZoomLevels[key] = zoomLevel;
  }
  
  static List<PlotModel> _getFromRenderCache(String key) {
    return _renderedPlots[key] ?? [];
  }
  
  static bool _isRenderCacheValid(String key, double zoomLevel) {
    if (!_renderedPlots.containsKey(key)) return false;
    
    final timestamp = _renderTimestamps[key];
    if (timestamp == null) return false;
    
    // Cache is valid for 5 minutes
    if (DateTime.now().difference(timestamp) > const Duration(minutes: 5)) return false;
    
    // Check if zoom level changed significantly
    final lastZoom = _lastZoomLevels[key];
    if (lastZoom != null && (zoomLevel - lastZoom).abs() > 1) return false;
    
    return true;
  }
  
  /// Performance monitoring
  static void _recordPerformance(String metric, int value) {
    _performanceMetrics[metric] = (_performanceMetrics[metric] ?? 0) + value;
  }
  
  /// Get performance statistics
  static Map<String, dynamic> getPerformanceStats() {
    return {
      'render_cache_hits': _performanceMetrics['render_cache_hit'] ?? 0,
      'avg_render_time': _performanceMetrics['render_time_ms'] ?? 0,
      'cache_size': _renderedPlots.length,
    };
  }
  
  /// Clear render cache
  static void clearRenderCache() {
    _renderedPlots.clear();
    _renderTimestamps.clear();
    _lastZoomLevels.clear();
    _performanceMetrics.clear();
  }
  
  /// Get optimal plot count for zoom level
  static int getOptimalPlotCount(double zoomLevel) {
    if (zoomLevel < 12) return _maxPlotsLowZoom;
    if (zoomLevel < 15) return _maxPlotsMediumZoom;
    return _maxPlotsHighZoom;
  }
  
  /// Check if plots should be rendered as polygons
  static bool shouldRenderPolygons(double zoomLevel) {
    return zoomLevel >= 12;
  }
  
  /// Check if plots should be rendered as detailed polygons
  static bool shouldRenderDetailedPolygons(double zoomLevel) {
    return zoomLevel >= 15;
  }
}
