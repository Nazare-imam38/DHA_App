import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../../data/models/plot_model.dart';
import 'unified_cache_manager.dart';
import 'unified_memory_cache.dart';
import 'optimized_plots_cache.dart';
import 'optimized_tile_cache.dart';

/// Enhanced Startup Preloader with Progress Tracking
/// Preloads essential data during splash screen with weighted progress
class EnhancedStartupPreloader {
  static bool _isPreloading = false;
  static bool _isPreloaded = false;
  static final Map<String, dynamic> _preloadStatus = {};
  
  // Progress tracking
  static double _currentProgress = 0.0;
  static String _currentMessage = 'Initializing...';
  static final StreamController<PreloadProgress> _progressController = 
      StreamController<PreloadProgress>.broadcast();
  
  // Preload weights (must sum to 100)
  static const double _boundariesWeight = 20.0;
  static const double _plotsWeight = 30.0;
  static const double _polygonsWeight = 30.0;
  static const double _tilesWeight = 15.0;
  static const double _filtersWeight = 5.0;
  
  // Configuration
  static const List<String> _essentialPhases = ['Phase1', 'Phase2', 'Phase3', 'Phase4', 'Phase5', 'Phase6', 'Phase7'];
  static const List<int> _essentialZoomLevels = [12, 13, 14, 15, 16];
  static const LatLng _dhaCenter = LatLng(33.5227, 73.0951);
  static const Duration _maxPreloadTime = Duration(seconds: 10);
  
  /// Start enhanced preloading with progress tracking
  static Future<void> startEnhancedPreloading() async {
    if (_isPreloading || _isPreloaded) return;
    
    _isPreloading = true;
    _currentProgress = 0.0;
    _currentMessage = 'Starting preload...';
    
    print('🚀 EnhancedStartupPreloader: Starting enhanced preloading with progress tracking...');
    
    try {
      // Initialize unified cache manager
      await _updateProgress(0.0, 'Initializing cache systems...');
      await UnifiedCacheManager.instance.initialize();
      
      // Stage 1: Preload GeoJSON boundaries (20% weight)
      await _preloadGeoJsonBoundaries();
      
      // Stage 2: Preload plot data (30% weight)
      await _preloadPlotData();
      
      // Stage 3: Preload plot polygons (30% weight)
      await _preloadPlotPolygons();
      
      // Stage 4: Preload essential map tiles (15% weight)
      await _preloadEssentialMapTiles();
      
      // Stage 5: Preload filter metadata (5% weight)
      await _preloadFilterMetadata();
      
      _isPreloaded = true;
      await _updateProgress(100.0, 'Preloading complete!');
      
      print('🚀 EnhancedStartupPreloader: ✅ ALL ESSENTIAL DATA PRELOADED');
      _printPreloadSummary();
      
    } catch (e) {
      print('❌ EnhancedStartupPreloader: Error during preloading: $e');
      await _updateProgress(_currentProgress, 'Error occurred, continuing...');
    } finally {
      _isPreloading = false;
    }
  }
  
  /// Preload GeoJSON boundaries with progress tracking
  static Future<void> _preloadGeoJsonBoundaries() async {
    await _updateProgress(_currentProgress, 'Loading boundaries...');
    
    final boundaryFiles = [
      'assets/Boundaries/geojsons/Phase1.geojson',
      'assets/Boundaries/geojsons/Phase2.geojson',
      'assets/Boundaries/geojsons/Phase3.geojson',
      'assets/Boundaries/geojsons/Phase4.geojson',
      'assets/Boundaries/geojsons/Phase4_GV.geojson',
      'assets/Boundaries/geojsons/Phase4_RVN.geojson',
      'assets/Boundaries/geojsons/Phase4_RVS.geojson',
      'assets/Boundaries/geojsons/Phase5.geojson',
      'assets/Boundaries/geojsons/Phase6.geojson',
      'assets/Boundaries/geojsons/Phase7.geojson',
    ];
    
    final boundaries = <BoundaryPolygon>[];
    
    // Load all boundaries in parallel
    final futures = boundaryFiles.map((filePath) => _loadBoundaryFile(filePath));
    final results = await Future.wait(futures);
    
    // Filter out null results
    boundaries.addAll(results.where((boundary) => boundary != null).cast<BoundaryPolygon>());
    
    // Store in unified cache
    await UnifiedCacheManager.instance.put('boundaries', boundaries);
    
    _preloadStatus['boundaries_loaded'] = boundaries.length;
    await _updateProgress(_currentProgress + _boundariesWeight, 'Boundaries loaded');
    
    print('✅ Preloaded ${boundaries.length} GeoJSON boundaries');
  }
  
  /// Load a single boundary file
  static Future<BoundaryPolygon?> _loadBoundaryFile(String filePath) async {
    try {
      final jsonString = await rootBundle.loadString(filePath);
      final jsonData = jsonDecode(jsonString);
      
      // Extract phase name from file path
      final phaseName = filePath.split('/').last.replaceAll('.geojson', '');
      
      return _parseGeoJsonBoundary(jsonData, phaseName);
    } catch (e) {
      print('❌ Error loading boundary $filePath: $e');
      return null;
    }
  }
  
  /// Parse GeoJSON boundary data
  static BoundaryPolygon? _parseGeoJsonBoundary(Map<String, dynamic> geoJson, String phaseName) {
    try {
      if (geoJson['type'] != 'FeatureCollection') return null;
      
      final features = geoJson['features'] as List<dynamic>;
      if (features.isEmpty) return null;
      
      final polygons = <List<LatLng>>[];
      
      for (final feature in features) {
        final geometry = feature['geometry'] as Map<String, dynamic>;
        final coordinates = geometry['coordinates'] as List<dynamic>;
        
        if (geometry['type'] == 'MultiPolygon') {
          for (final polygon in coordinates) {
            final polygonCoords = _parsePolygonCoordinates(polygon as List<dynamic>);
            if (polygonCoords.isNotEmpty) {
              polygons.add(polygonCoords);
            }
          }
        } else if (geometry['type'] == 'Polygon') {
          final polygonCoords = _parsePolygonCoordinates(coordinates);
          if (polygonCoords.isNotEmpty) {
            polygons.add(polygonCoords);
          }
        }
      }
      
      if (polygons.isEmpty) return null;
      
      // Get phase color and icon
      final phaseColors = {
        'Phase1': 0xFF4CAF50,
        'Phase2': 0xFF2196F3,
        'Phase3': 0xFFFF9800,
        'Phase4': 0xFF9C27B0,
        'Phase4_GV': 0xFF9C27B0,
        'Phase4_RVN': 0xFF9C27B0,
        'Phase4_RVS': 0xFF9C27B0,
        'Phase5': 0xFFF44336,
        'Phase6': 0xFF00BCD4,
        'Phase7': 0xFF795548,
      };
      
      return BoundaryPolygon(
        phaseName: phaseName,
        polygons: polygons,
        color: Color(phaseColors[phaseName] ?? 0xFF4CAF50),
        icon: Icons.home_work,
      );
    } catch (e) {
      print('❌ Error parsing GeoJSON for $phaseName: $e');
      return null;
    }
  }
  
  /// Parse polygon coordinates
  static List<LatLng> _parsePolygonCoordinates(List<dynamic> coordinates) {
    if (coordinates.isEmpty) return [];
    
    final firstRing = coordinates[0] as List<dynamic>;
    final points = <LatLng>[];
    
    for (final point in firstRing) {
      if (point is List && point.length >= 2) {
        final lng = point[0] as double;
        final lat = point[1] as double;
        points.add(LatLng(lat, lng));
      }
    }
    
    return points;
  }
  
  /// Preload plot data with progress tracking
  static Future<void> _preloadPlotData() async {
    await _updateProgress(_currentProgress, 'Loading plot data...');
    
    try {
      // Load all plots from API
      final plots = await _loadAllPlotsFromApi();
      
      // Store in unified cache
      await UnifiedCacheManager.instance.put('plots', plots);
      
      _preloadStatus['plots_loaded'] = plots.length;
      await _updateProgress(_currentProgress + _plotsWeight, 'Plot data loaded');
      
      print('✅ Preloaded ${plots.length} plots');
    } catch (e) {
      print('❌ Error preloading plot data: $e');
      await _updateProgress(_currentProgress + _plotsWeight, 'Plot data failed, continuing...');
    }
  }
  
  /// Load all plots from API
  static Future<List<PlotModel>> _loadAllPlotsFromApi() async {
    try {
      final response = await http.get(
        Uri.parse('https://backend-apis.dhamarketplace.com/api/plots'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((json) => _createPlotModel(json)).toList();
      } else {
        throw Exception('API Error ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading plots from API: $e');
      return [];
    }
  }
  
  /// Create plot model from JSON
  static PlotModel _createPlotModel(Map<String, dynamic> json) {
    return PlotModel(
      id: json['id'] as int,
      eventHistoryId: json['event_history_id'] as String?,
      plotNo: json['plot_no'] as String,
      size: json['size'] as String,
      category: json['category'] as String,
      catArea: json['cat_area'] as String,
      dimension: json['dimension'] as String?,
      phase: json['phase'] as String,
      sector: json['sector'] as String,
      streetNo: json['street_no'] as String,
      block: json['block'] as String?,
      status: json['status'] as String,
      tokenAmount: json['token_amount'] as String,
      remarks: json['remarks'] as String?,
      basePrice: json['base_price'] as String,
      holdBy: json['hold_by'] as String?,
      expireTime: json['expire_time'] as String?,
      oneYrPlan: json['one_yr_plan'] as String,
      twoYrsPlan: json['two_yrs_plan'] as String,
      twoFiveYrsPlan: json['two_five_yrs_plan'] as String,
      threeYrsPlan: json['three_yrs_plan'] as String,
      stAsgeojson: json['st_asgeojson'] as String,
      eventHistory: EventHistory.fromJson(json['event_history'] as Map<String, dynamic>),
      latitude: null,
      longitude: null,
      expoBasePrice: json['expo_base_price'] as String?,
      vloggerBasePrice: json['vlogger_base_price'] as String?,
    );
  }
  
  /// Preload plot polygons with progress tracking
  static Future<void> _preloadPlotPolygons() async {
    await _updateProgress(_currentProgress, 'Processing polygons...');
    
    try {
      // Get plots from cache
      final plots = await UnifiedCacheManager.instance.get<List<PlotModel>>('plots');
      if (plots == null || plots.isEmpty) {
        await _updateProgress(_currentProgress + _polygonsWeight, 'No plots to process');
        return;
      }
      
      int processedCount = 0;
      
      for (final plot in plots) {
        try {
          // Process GeoJSON and extract coordinates
          final coordinates = _extractCoordinatesFromGeoJson(plot.stAsgeojson);
          if (coordinates.isNotEmpty) {
            // Store processed coordinates in cache
            await UnifiedCacheManager.instance.put('plot_polygon_${plot.id}', {
              'plot_id': plot.id,
              'coordinates': coordinates,
              'center': _calculateCenter(coordinates),
            });
            processedCount++;
          }
        } catch (e) {
          print('❌ Error processing plot ${plot.id}: $e');
        }
      }
      
      _preloadStatus['polygons_processed'] = processedCount;
      await _updateProgress(_currentProgress + _polygonsWeight, 'Polygons processed');
      
      print('✅ Processed $processedCount plot polygons');
    } catch (e) {
      print('❌ Error preloading plot polygons: $e');
      await _updateProgress(_currentProgress + _polygonsWeight, 'Polygons failed, continuing...');
    }
  }
  
  /// Extract coordinates from GeoJSON
  static List<List<LatLng>> _extractCoordinatesFromGeoJson(String geoJsonString) {
    try {
      final geoJson = jsonDecode(geoJsonString);
      
      if (geoJson['type'] == 'MultiPolygon' && geoJson['coordinates'] != null) {
        final coordinates = geoJson['coordinates'] as List;
        final polygons = <List<LatLng>>[];
        
        for (final polygon in coordinates) {
          if (polygon is List && polygon.isNotEmpty) {
            final firstRing = polygon[0] as List;
            final points = <LatLng>[];
            
            for (final point in firstRing) {
              if (point is List && point.length >= 2) {
                final lng = point[0] as double;
                final lat = point[1] as double;
                points.add(LatLng(lat, lng));
              }
            }
            
            if (points.isNotEmpty) {
              polygons.add(points);
            }
          }
        }
        
        return polygons;
      }
    } catch (e) {
      print('❌ Error extracting coordinates: $e');
    }
    
    return [];
  }
  
  /// Calculate center point of coordinates
  static LatLng _calculateCenter(List<List<LatLng>> polygons) {
    if (polygons.isEmpty) return const LatLng(0, 0);
    
    double totalLat = 0;
    double totalLng = 0;
    int pointCount = 0;
    
    for (final polygon in polygons) {
      for (final point in polygon) {
        totalLat += point.latitude;
        totalLng += point.longitude;
        pointCount++;
      }
    }
    
    return pointCount > 0 
        ? LatLng(totalLat / pointCount, totalLng / pointCount)
        : const LatLng(0, 0);
  }
  
  /// Preload essential map tiles with progress tracking
  static Future<void> _preloadEssentialMapTiles() async {
    await _updateProgress(_currentProgress, 'Loading map tiles...');
    
    int tilesPreloaded = 0;
    
    // Preload tiles for essential phases and zoom levels
    for (final phase in _essentialPhases) {
      for (final zoom in _essentialZoomLevels) {
        try {
          // Calculate tile coordinates for DHA center
          final tileCoords = _calculateTileCoordinates(_dhaCenter, zoom);
          
          // Preload a 3x3 grid of tiles around center
          for (int x = tileCoords['x']! - 1; x <= tileCoords['x']! + 1; x++) {
            for (int y = tileCoords['y']! - 1; y <= tileCoords['y']! + 1; y++) {
              try {
                await OptimizedTileCache.instance.getTile(phase, zoom, x, y);
                tilesPreloaded++;
              } catch (e) {
                // Continue if tile fails
              }
            }
          }
        } catch (e) {
          print('❌ Error preloading tiles for $phase zoom $zoom: $e');
        }
      }
    }
    
    _preloadStatus['tiles_preloaded'] = tilesPreloaded;
    await _updateProgress(_currentProgress + _tilesWeight, 'Map tiles loaded');
    
    print('✅ Preloaded $tilesPreloaded map tiles');
  }
  
  /// Calculate tile coordinates for a point using correct Web Mercator formula
  static Map<String, int> _calculateTileCoordinates(LatLng point, int zoom) {
    final n = 1 << zoom;
    
    // Longitude to X (correct)
    final x = ((point.longitude + 180) / 360 * n).floor();
    
    // Latitude to Y (corrected Web Mercator formula)
    final latRad = radians(point.latitude);
    final y = ((1 - (math.log(math.tan(math.pi / 4 + latRad / 2)) / math.pi)) / 2 * n).floor();
    
    return {'x': x, 'y': y};
  }
  
  /// Preload filter metadata with progress tracking
  static Future<void> _preloadFilterMetadata() async {
    await _updateProgress(_currentProgress, 'Preparing filters...');
    
    try {
      // Preload common filter combinations
      final filterMetadata = {
        'phases': _essentialPhases,
        'categories': ['Residential', 'Commercial', 'Industrial'],
        'statuses': ['Available', 'Sold', 'Reserved'],
        'price_ranges': [
          {'min': 0, 'max': 5000000},
          {'min': 5000000, 'max': 10000000},
          {'min': 10000000, 'max': 20000000},
          {'min': 20000000, 'max': 50000000},
        ],
      };
      
      await UnifiedCacheManager.instance.put('filter_metadata', filterMetadata);
      
      _preloadStatus['filters_loaded'] = true;
      await _updateProgress(_currentProgress + _filtersWeight, 'Filters ready');
      
      print('✅ Preloaded filter metadata');
    } catch (e) {
      print('❌ Error preloading filter metadata: $e');
      await _updateProgress(_currentProgress + _filtersWeight, 'Filters failed, continuing...');
    }
  }
  
  /// Update progress and notify listeners
  static Future<void> _updateProgress(double progress, String message) async {
    _currentProgress = progress;
    _currentMessage = message;
    
    _progressController.add(PreloadProgress(
      progress: progress,
      message: message,
      isComplete: progress >= 100.0,
    ));
    
    print('📊 Progress: ${progress.toStringAsFixed(1)}% - $message');
  }
  
  /// Print preload summary
  static void _printPreloadSummary() {
    print('🚀 ===== ENHANCED PRELOAD SUMMARY =====');
    print('🚀 Boundaries: ${_preloadStatus['boundaries_loaded'] ?? 0}');
    print('🚀 Plots: ${_preloadStatus['plots_loaded'] ?? 0}');
    print('🚀 Polygons: ${_preloadStatus['polygons_processed'] ?? 0}');
    print('🚀 Tiles: ${_preloadStatus['tiles_preloaded'] ?? 0}');
    print('🚀 Filters: ${_preloadStatus['filters_loaded'] ?? false}');
    print('🚀 =====================================');
  }
  
  /// Helper functions for tile calculations
  static double radians(double degrees) => degrees * (math.pi / 180);
  
  /// Get current progress
  static double get currentProgress => _currentProgress;
  
  /// Get current message
  static String get currentMessage => _currentMessage;
  
  /// Get progress stream
  static Stream<PreloadProgress> get progressStream => _progressController.stream;
  
  /// Check if preloading is complete
  static bool get isPreloaded => _isPreloaded;
  
  /// Check if preloading is in progress
  static bool get isPreloading => _isPreloading;
  
  /// Get preload status
  static Map<String, dynamic> getPreloadStatus() {
    return {
      'is_preloaded': _isPreloaded,
      'is_preloading': _isPreloading,
      'current_progress': _currentProgress,
      'current_message': _currentMessage,
      'status': _preloadStatus,
    };
  }
  
  /// Dispose resources
  static void dispose() {
    _progressController.close();
  }
}

/// Progress data class
class PreloadProgress {
  final double progress;
  final String message;
  final bool isComplete;
  
  PreloadProgress({
    required this.progress,
    required this.message,
    required this.isComplete,
  });
}

/// BoundaryPolygon class for preloading
class BoundaryPolygon {
  final String phaseName;
  final List<List<LatLng>> polygons;
  final Color color;
  final IconData icon;
  
  BoundaryPolygon({
    required this.phaseName,
    required this.polygons,
    required this.color,
    required this.icon,
  });
  
  /// Get the center point of the boundary (cached for performance)
  LatLng? _cachedCenter;
  LatLng get center {
    if (_cachedCenter != null) return _cachedCenter!;
    
    if (polygons.isEmpty) {
      _cachedCenter = const LatLng(0, 0);
      return _cachedCenter!;
    }
    
    double totalLat = 0;
    double totalLng = 0;
    int pointCount = 0;
    
    for (final polygon in polygons) {
      for (final point in polygon) {
        totalLat += point.latitude;
        totalLng += point.longitude;
        pointCount++;
      }
    }
    
    if (pointCount == 0) {
      _cachedCenter = const LatLng(0, 0);
    } else {
      _cachedCenter = LatLng(totalLat / pointCount, totalLng / pointCount);
    }
    
    return _cachedCenter!;
  }
  
  /// Get bounds of the boundary (cached for performance)
  Map<String, LatLng>? _cachedBounds;
  Map<String, LatLng> get bounds {
    if (_cachedBounds != null) return _cachedBounds!;
    
    if (polygons.isEmpty) {
      _cachedBounds = {
        'north': const LatLng(0, 0),
        'south': const LatLng(0, 0),
        'east': const LatLng(0, 0),
        'west': const LatLng(0, 0),
      };
      return _cachedBounds!;
    }
    
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;
    
    for (final polygon in polygons) {
      for (final point in polygon) {
        minLat = minLat < point.latitude ? minLat : point.latitude;
        maxLat = maxLat > point.latitude ? maxLat : point.latitude;
        minLng = minLng < point.longitude ? minLng : point.longitude;
        maxLng = maxLng > point.longitude ? maxLng : point.longitude;
      }
    }
    
    _cachedBounds = {
      'north': LatLng(maxLat, 0),
      'south': LatLng(minLat, 0),
      'east': LatLng(0, maxLng),
      'west': LatLng(0, minLng),
    };
    
    return _cachedBounds!;
  }
}
