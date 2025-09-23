import 'package:flutter/foundation.dart';
import '../../data/models/plot_model.dart';
import 'polygon_preloader.dart';

/// Service to handle app initialization and polygon preloading
class AppInitializationService {
  static bool _isInitialized = false;
  static bool _isPreloading = false;

  /// Initialize the app with polygon preloading
  static Future<void> initializeApp(List<PlotModel> plots) async {
    if (_isInitialized) {
      print('AppInitializationService: App already initialized');
      return;
    }

    print('AppInitializationService: 🚀 Starting app initialization...');
    _isPreloading = true;

    try {
      // Start polygon preloading in the background
      if (kDebugMode) {
        print('AppInitializationService: Starting polygon preloading for ${plots.length} plots...');
      }

      // Preload polygons asynchronously
      unawaited(_preloadPolygonsAsync(plots));

      _isInitialized = true;
      print('AppInitializationService: ✅ App initialization completed');
    } catch (e) {
      print('AppInitializationService: ❌ Error during initialization: $e');
      _isPreloading = false;
    }
  }

  /// Preload polygons asynchronously
  static Future<void> _preloadPolygonsAsync(List<PlotModel> plots) async {
    try {
      await PolygonPreloader.preloadAllPolygons(plots);
      _isPreloading = false;
      
      final stats = PolygonPreloader.getStatistics();
      print('AppInitializationService: ✅ Polygon preloading completed');
      print('AppInitializationService: Preloaded ${stats['preloadedPlots']} plots with ${stats['totalPolygons']} polygons');
    } catch (e) {
      print('AppInitializationService: ❌ Error during polygon preloading: $e');
      _isPreloading = false;
    }
  }

  /// Check if app is initialized
  static bool get isInitialized => _isInitialized;

  /// Check if polygon preloading is in progress
  static bool get isPreloading => _isPreloading;

  /// Get initialization progress
  static Map<String, dynamic> getInitializationProgress() {
    final preloadingProgress = PolygonPreloader.getPreloadingProgress();
    
    return {
      'isInitialized': _isInitialized,
      'isPreloading': _isPreloading,
      'preloadingProgress': preloadingProgress,
    };
  }

  /// Reset initialization state (useful for testing)
  static void reset() {
    _isInitialized = false;
    _isPreloading = false;
    PolygonPreloader.clearPreloadedData();
    print('AppInitializationService: Reset initialization state');
  }
}

/// Helper function to avoid await warnings
void unawaited(Future<void> future) {
  future.catchError((error) {
    print('Unawaited future error: $error');
  });
}
