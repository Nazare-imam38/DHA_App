import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../services/polygon_preloader.dart';
import '../data/models/plot_model.dart';
import 'optimized_utm_converter.dart';

/// Performance test utility to verify polygon conversion improvements
class PerformanceTestUtility {
  /// Test UTM conversion performance
  static void testUtmConversionPerformance() {
    print('=== UTM Conversion Performance Test ===');
    
    final testCoordinates = [
      [500000.0, 3700000.0],
      [300000.0, 3700000.0],
      [700000.0, 3700000.0],
      [500000.0, 3600000.0],
      [500000.0, 3800000.0],
    ];
    
    final stopwatch = Stopwatch()..start();
    
    for (int i = 0; i < 1000; i++) {
      for (final coord in testCoordinates) {
        OptimizedUtmConverter.utmToLatLng(coord[0], coord[1], 43, northernHemisphere: true);
      }
    }
    
    stopwatch.stop();
    
    final totalConversions = testCoordinates.length * 1000;
    final conversionsPerSecond = totalConversions / (stopwatch.elapsedMilliseconds / 1000);
    
    print('PerformanceTestUtility: Converted $totalConversions coordinates in ${stopwatch.elapsedMilliseconds}ms');
    print('PerformanceTestUtility: Rate: ${conversionsPerSecond.toStringAsFixed(0)} conversions/second');
    
    if (conversionsPerSecond > 10000) {
      print('PerformanceTestUtility: ✅ Performance is excellent (>10k conversions/sec)');
    } else if (conversionsPerSecond > 5000) {
      print('PerformanceTestUtility: ✅ Performance is good (>5k conversions/sec)');
    } else {
      print('PerformanceTestUtility: ⚠️ Performance could be improved (<5k conversions/sec)');
    }
  }

  /// Test polygon preloading performance
  static Future<void> testPolygonPreloadingPerformance(List<PlotModel> plots) async {
    print('=== Polygon Preloading Performance Test ===');
    
    if (plots.isEmpty) {
      print('PerformanceTestUtility: No plots to test');
      return;
    }
    
    // Test with a subset of plots for performance testing
    final testPlots = plots.take(min(50, plots.length)).toList();
    print('PerformanceTestUtility: Testing with ${testPlots.length} plots');
    
    final stopwatch = Stopwatch()..start();
    
    // Clear any existing preloaded data
    PolygonPreloader.clearPreloadedData();
    
    // Preload polygons
    await PolygonPreloader.preloadAllPolygons(testPlots);
    
    stopwatch.stop();
    
    final stats = PolygonPreloader.getStatistics();
    final plotsPerSecond = testPlots.length / (stopwatch.elapsedMilliseconds / 1000);
    
    print('PerformanceTestUtility: Preloaded ${stats['preloadedPlots']} plots in ${stopwatch.elapsedMilliseconds}ms');
    print('PerformanceTestUtility: Rate: ${plotsPerSecond.toStringAsFixed(1)} plots/second');
    print('PerformanceTestUtility: Total polygons: ${stats['totalPolygons']}');
    print('PerformanceTestUtility: Total points: ${stats['totalPoints']}');
    print('PerformanceTestUtility: Avg polygons per plot: ${stats['averagePolygonsPerPlot'].toStringAsFixed(1)}');
    print('PerformanceTestUtility: Avg points per polygon: ${stats['averagePointsPerPolygon'].toStringAsFixed(1)}');
    
    if (plotsPerSecond > 10) {
      print('PerformanceTestUtility: ✅ Preloading performance is excellent (>10 plots/sec)');
    } else if (plotsPerSecond > 5) {
      print('PerformanceTestUtility: ✅ Preloading performance is good (>5 plots/sec)');
    } else {
      print('PerformanceTestUtility: ⚠️ Preloading performance could be improved (<5 plots/sec)');
    }
  }

  /// Test map rendering performance with preloaded coordinates
  static void testMapRenderingPerformance(List<PlotModel> plots) {
    print('=== Map Rendering Performance Test ===');
    
    if (plots.isEmpty) {
      print('PerformanceTestUtility: No plots to test');
      return;
    }
    
    // Test with a subset of plots
    final testPlots = plots.take(min(100, plots.length)).toList();
    print('PerformanceTestUtility: Testing map rendering with ${testPlots.length} plots');
    
    final stopwatch = Stopwatch()..start();
    
    // Simulate map rendering by accessing polygon coordinates
    int totalPolygons = 0;
    int totalPoints = 0;
    
    for (final plot in testPlots) {
      try {
        final coordinates = plot.polygonCoordinates;
        totalPolygons += coordinates.length;
        
        for (final polygon in coordinates) {
          totalPoints += polygon.length;
        }
      } catch (e) {
        print('PerformanceTestUtility: Error accessing coordinates for plot ${plot.plotNo}: $e');
      }
    }
    
    stopwatch.stop();
    
    final plotsPerSecond = testPlots.length / (stopwatch.elapsedMilliseconds / 1000);
    final polygonsPerSecond = totalPolygons / (stopwatch.elapsedMilliseconds / 1000);
    final pointsPerSecond = totalPoints / (stopwatch.elapsedMilliseconds / 1000);
    
    print('PerformanceTestUtility: Rendered ${testPlots.length} plots in ${stopwatch.elapsedMilliseconds}ms');
    print('PerformanceTestUtility: Rate: ${plotsPerSecond.toStringAsFixed(1)} plots/second');
    print('PerformanceTestUtility: Rate: ${polygonsPerSecond.toStringAsFixed(0)} polygons/second');
    print('PerformanceTestUtility: Rate: ${pointsPerSecond.toStringAsFixed(0)} points/second');
    print('PerformanceTestUtility: Total polygons: $totalPolygons');
    print('PerformanceTestUtility: Total points: $totalPoints');
    
    if (plotsPerSecond > 50) {
      print('PerformanceTestUtility: ✅ Map rendering performance is excellent (>50 plots/sec)');
    } else if (plotsPerSecond > 20) {
      print('PerformanceTestUtility: ✅ Map rendering performance is good (>20 plots/sec)');
    } else {
      print('PerformanceTestUtility: ⚠️ Map rendering performance could be improved (<20 plots/sec)');
    }
  }

  /// Run comprehensive performance tests
  static Future<void> runComprehensivePerformanceTests(List<PlotModel> plots) async {
    print('🚀 Starting Comprehensive Performance Tests...\n');
    
    // Test 1: UTM Conversion Performance
    testUtmConversionPerformance();
    print('');
    
    // Test 2: Polygon Preloading Performance
    await testPolygonPreloadingPerformance(plots);
    print('');
    
    // Test 3: Map Rendering Performance
    testMapRenderingPerformance(plots);
    print('');
    
    // Test 4: Memory Usage
    _testMemoryUsage();
    print('');
    
    print('✅ Comprehensive Performance Tests Completed!');
  }

  /// Test memory usage
  static void _testMemoryUsage() {
    print('=== Memory Usage Test ===');
    
    final stats = PolygonPreloader.getStatistics();
    
    // Estimate memory usage (rough calculation)
    final estimatedMemoryMB = (stats['totalPoints'] * 16) / (1024 * 1024); // 16 bytes per LatLng point
    
    print('PerformanceTestUtility: Estimated memory usage: ${estimatedMemoryMB.toStringAsFixed(2)} MB');
    print('PerformanceTestUtility: Preloaded plots: ${stats['preloadedPlots']}');
    print('PerformanceTestUtility: Total polygons: ${stats['totalPolygons']}');
    print('PerformanceTestUtility: Total points: ${stats['totalPoints']}');
    
    if (estimatedMemoryMB < 50) {
      print('PerformanceTestUtility: ✅ Memory usage is excellent (<50 MB)');
    } else if (estimatedMemoryMB < 100) {
      print('PerformanceTestUtility: ✅ Memory usage is good (<100 MB)');
    } else {
      print('PerformanceTestUtility: ⚠️ Memory usage is high (>100 MB)');
    }
  }

  /// Generate performance report
  static Map<String, dynamic> generatePerformanceReport() {
    final stats = PolygonPreloader.getStatistics();
    final preloadingProgress = PolygonPreloader.getPreloadingProgress();
    
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'preloadingStats': preloadingProgress,
      'polygonStats': stats,
      'memoryUsage': {
        'estimatedMB': (stats['totalPoints'] * 16) / (1024 * 1024),
        'totalPoints': stats['totalPoints'],
        'totalPolygons': stats['totalPolygons'],
      },
      'performance': {
        'isPreloaded': preloadingProgress['isPreloading'] == false,
        'preloadedPlots': stats['preloadedPlots'],
        'successRate': stats['preloadedPlots'] / (preloadingProgress['totalPlots'] ?? 1) * 100,
      }
    };
  }
}
