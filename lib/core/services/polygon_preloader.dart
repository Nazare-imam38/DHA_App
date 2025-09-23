import 'dart:convert';
import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../utils/optimized_utm_converter.dart';
import '../../data/models/plot_model.dart';

/// Polygon preloader service that converts all UTM coordinates once at app startup
/// This eliminates the performance bottleneck of converting coordinates on every map render
class PolygonPreloader {
  static final Map<int, List<List<LatLng>>> _preloadedCoordinates = {};
  static final Map<int, bool> _preloadingStatus = {};
  static bool _isPreloading = false;
  static int _totalPlots = 0;
  static int _processedPlots = 0;

  /// Preload polygon coordinates for all plots
  static Future<void> preloadAllPolygons(List<PlotModel> plots) async {
    if (_isPreloading) {
      print('PolygonPreloader: Already preloading, skipping...');
      return;
    }

    _isPreloading = true;
    _totalPlots = plots.length;
    _processedPlots = 0;

    print('PolygonPreloader: 🚀 Starting preload of ${plots.length} plots...');
    final stopwatch = Stopwatch()..start();

    try {
      // Process plots in batches to avoid blocking the UI
      const batchSize = 10;
      for (int i = 0; i < plots.length; i += batchSize) {
        final batch = plots.skip(i).take(batchSize).toList();
        await _preloadBatch(batch);
        
        // Allow UI to update between batches
        await Future.delayed(const Duration(milliseconds: 10));
      }

      stopwatch.stop();
      print('PolygonPreloader: ✅ Preload completed in ${stopwatch.elapsedMilliseconds}ms');
      print('PolygonPreloader: Successfully processed ${_processedPlots}/${_totalPlots} plots');
    } catch (e) {
      print('PolygonPreloader: ❌ Error during preload: $e');
    } finally {
      _isPreloading = false;
    }
  }

  /// Preload a batch of plots
  static Future<void> _preloadBatch(List<PlotModel> plots) async {
    for (final plot in plots) {
      try {
        if (_preloadingStatus[plot.id] == true) {
          continue; // Already processed
        }

        final coordinates = _parseAndConvertPolygonCoordinates(plot);
        if (coordinates.isNotEmpty) {
          _preloadedCoordinates[plot.id] = coordinates;
          _preloadingStatus[plot.id] = true;
          _processedPlots++;
          
          if (_processedPlots % 50 == 0) {
            print('PolygonPreloader: Processed ${_processedPlots}/${_totalPlots} plots...');
          }
        } else {
          _preloadingStatus[plot.id] = false;
          _processedPlots++;
        }
      } catch (e) {
        print('PolygonPreloader: Error processing plot ${plot.plotNo}: $e');
        _preloadingStatus[plot.id] = false;
        _processedPlots++;
      }
    }
  }

  /// Parse and convert polygon coordinates using optimized UTM conversion
  static List<List<LatLng>> _parseAndConvertPolygonCoordinates(PlotModel plot) {
    try {
      if (plot.stAsgeojson.isEmpty) {
        return [];
      }

      final geoJson = json.decode(plot.stAsgeojson);
      final coordinates = geoJson['coordinates'];
      
      if (coordinates == null || coordinates is! List) {
        return [];
      }

      final polygons = <List<LatLng>>[];

      if (geoJson['type'] == 'MultiPolygon' && coordinates.isNotEmpty) {
        for (final polygon in coordinates) {
          if (polygon is List && polygon.isNotEmpty) {
            final firstRing = polygon[0] as List;
            final ring = <LatLng>[];

            for (final point in firstRing) {
              if (point is List && point.length >= 2) {
                final x = point[0].toDouble();
                final y = point[1].toDouble();

                // Use optimized UTM conversion
                final latLng = OptimizedUtmConverter.utmToLatLng(x, y, 43, northernHemisphere: true);
                ring.add(latLng);
              }
            }

            if (ring.length >= 3) {
              // Ensure polygon is closed
              if (ring.first.latitude != ring.last.latitude || 
                  ring.first.longitude != ring.last.longitude) {
                ring.add(ring.first);
              }
              polygons.add(ring);
            }
          }
        }
      } else if (geoJson['type'] == 'Polygon' && coordinates.isNotEmpty) {
        final firstRing = coordinates[0] as List;
        final ring = <LatLng>[];

        for (final point in firstRing) {
          if (point is List && point.length >= 2) {
            final x = point[0].toDouble();
            final y = point[1].toDouble();
            final latLng = OptimizedUtmConverter.utmToLatLng(x, y, 43, northernHemisphere: true);
            ring.add(latLng);
          }
        }

        if (ring.length >= 3) {
          // Ensure polygon is closed
          if (ring.first.latitude != ring.last.latitude || 
              ring.first.longitude != ring.last.longitude) {
            ring.add(ring.first);
          }
          polygons.add(ring);
        }
      }

      return polygons;
    } catch (e) {
      print('PolygonPreloader: Error parsing plot ${plot.plotNo}: $e');
      return [];
    }
  }

  /// Get preloaded coordinates for a plot
  static List<List<LatLng>>? getPreloadedCoordinates(int plotId) {
    return _preloadedCoordinates[plotId];
  }

  /// Check if coordinates are preloaded for a plot
  static bool isPreloaded(int plotId) {
    return _preloadingStatus[plotId] == true && _preloadedCoordinates.containsKey(plotId);
  }

  /// Get preloading progress
  static Map<String, dynamic> getPreloadingProgress() {
    return {
      'isPreloading': _isPreloading,
      'totalPlots': _totalPlots,
      'processedPlots': _processedPlots,
      'progress': _totalPlots > 0 ? (_processedPlots / _totalPlots) * 100 : 0.0,
      'preloadedCount': _preloadedCoordinates.length,
    };
  }

  /// Clear all preloaded data (useful for memory management)
  static void clearPreloadedData() {
    _preloadedCoordinates.clear();
    _preloadingStatus.clear();
    _isPreloading = false;
    _totalPlots = 0;
    _processedPlots = 0;
    print('PolygonPreloader: Cleared all preloaded data');
  }

  /// Get statistics about preloaded data
  static Map<String, dynamic> getStatistics() {
    int totalPolygons = 0;
    int totalPoints = 0;

    for (final coordinates in _preloadedCoordinates.values) {
      totalPolygons += coordinates.length;
      for (final polygon in coordinates) {
        totalPoints += polygon.length;
      }
    }

    return {
      'preloadedPlots': _preloadedCoordinates.length,
      'totalPolygons': totalPolygons,
      'totalPoints': totalPoints,
      'averagePolygonsPerPlot': _preloadedCoordinates.isNotEmpty 
          ? totalPolygons / _preloadedCoordinates.length 
          : 0.0,
      'averagePointsPerPolygon': totalPolygons > 0 
          ? totalPoints / totalPolygons 
          : 0.0,
    };
  }

  /// Preload coordinates for a single plot (useful for new plots)
  static Future<void> preloadSinglePlot(PlotModel plot) async {
    try {
      if (_preloadingStatus[plot.id] == true) {
        return; // Already processed
      }

      final coordinates = _parseAndConvertPolygonCoordinates(plot);
      if (coordinates.isNotEmpty) {
        _preloadedCoordinates[plot.id] = coordinates;
        _preloadingStatus[plot.id] = true;
        print('PolygonPreloader: ✅ Preloaded plot ${plot.plotNo} (${coordinates.length} polygons)');
      } else {
        _preloadingStatus[plot.id] = false;
        print('PolygonPreloader: ⚠️ No coordinates found for plot ${plot.plotNo}');
      }
    } catch (e) {
      print('PolygonPreloader: ❌ Error preloading plot ${plot.plotNo}: $e');
      _preloadingStatus[plot.id] = false;
    }
  }
}
