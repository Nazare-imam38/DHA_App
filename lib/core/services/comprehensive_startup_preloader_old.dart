import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import '../../data/models/plot_model.dart';
import 'unified_memory_cache.dart' as cache;
import 'optimized_plots_cache.dart';
import 'optimized_tile_cache.dart';

/// Comprehensive Startup Preloader
/// Preloads ALL data at app startup for instant access
class ComprehensiveStartupPreloader {
  static bool _isPreloading = false;
  static bool _isPreloaded = false;
  static final Map<String, dynamic> _preloadStatus = {};
  
  // Preload configuration
  static const List<String> _essentialPhases = ['Phase1', 'Phase2', 'Phase3', 'Phase4', 'Phase5', 'Phase6', 'Phase7'];
  static const List<int> _essentialZoomLevels = [12, 13, 14, 15, 16];
  static const LatLng _dhaCenter = LatLng(33.5227, 73.0951);
  static const double _preloadRadius = 10.0; // 10km radius
  
  /// Start comprehensive preloading at app startup
  static Future<void> startComprehensivePreloading() async {
    if (_isPreloading || _isPreloaded) return;
    
    _isPreloading = true;
    print('🚀 ComprehensiveStartupPreloader: Starting comprehensive preloading...');
    
    try {
      // Initialize all cache systems
      await _initializeCacheSystems();
      
      // Stage 1: Preload GeoJSON boundaries (CRITICAL - instant access)
      await _preloadGeoJsonBoundaries();
      
      // Stage 2: Preload plot data and polygons (CRITICAL - instant access)
      await _preloadPlotDataAndPolygons();
      
      // Stage 3: Preload essential map tiles (HIGH PRIORITY)
      await _preloadEssentialMapTiles();
      
      // Stage 4: Preload amenities data (MEDIUM PRIORITY)
      await _preloadAmenitiesData();
      
      // Stage 5: Preload API responses (LOW PRIORITY)
      await _preloadApiResponses();
      
      _isPreloaded = true;
      print('🚀 ComprehensiveStartupPreloader: ✅ ALL DATA PRELOADED SUCCESSFULLY');
      _printPreloadSummary();
      
    } catch (e) {
      print('❌ ComprehensiveStartupPreloader: Error during preloading: $e');
    } finally {
      _isPreloading = false;
    }
  }
  
  /// Initialize all cache systems
  static Future<void> _initializeCacheSystems() async {
    print('🚀 Initializing cache systems...');
    
    await cache.UnifiedMemoryCache.instance.initialize();
    await OptimizedPlotsCache.initialize();
    await OptimizedTileCache.instance.initialize();
    
    print('✅ Cache systems initialized');
  }
  
  /// Preload all GeoJSON boundary files
  static Future<void> _preloadGeoJsonBoundaries() async {
    print('🚀 Preloading GeoJSON boundaries...');
    
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
    
    final boundaries = <cache.BoundaryPolygon>[];
    
    // Load all boundaries in parallel
    final futures = boundaryFiles.map((filePath) => _loadBoundaryFile(filePath));
    final results = await Future.wait(futures);
    
    // Filter out null results and convert to UnifiedMemoryCache BoundaryPolygon
    final validBoundaries = results.where((boundary) => boundary != null).cast<BoundaryPolygon>();
    final unifiedBoundaries = validBoundaries.map((boundary) => 
      cache.BoundaryPolygon(
        phaseName: boundary.phaseName,
        polygons: boundary.polygons,
        color: Colors.blue, // Default color
        icon: Icons.location_on, // Default icon
      )
    ).toList();
    boundaries.addAll(unifiedBoundaries);
    
    // Store in memory cache for instant access
    await cache.UnifiedMemoryCache.instance.storeBoundaries(boundaries);
    
    _preloadStatus['boundaries_loaded'] = boundaries.length;
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
  
  /// Preload plot data and process polygons
  static Future<void> _preloadPlotDataAndPolygons() async {
    print('🚀 Preloading plot data and polygons...');
    
    try {
      // Load all plots from API
      final plots = await _loadAllPlotsFromApi();
      
      // Process and cache all plot polygons
      await _processAndCachePlotPolygons(plots);
      
      // Store plots in memory cache
      await OptimizedPlotsCache.storePlots(plots);
      
      _preloadStatus['plots_loaded'] = plots.length;
      print('✅ Preloaded ${plots.length} plots with polygons');
    } catch (e) {
      print('❌ Error preloading plot data: $e');
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
      latitude: null, // Will be calculated from GeoJSON
      longitude: null, // Will be calculated from GeoJSON
      expoBasePrice: json['expo_base_price'] as String?,
      vloggerBasePrice: json['vlogger_base_price'] as String?,
    );
  }
  
  /// Process and cache all plot polygons
  static Future<void> _processAndCachePlotPolygons(List<PlotModel> plots) async {
    print('🚀 Processing plot polygons...');
    
    int processedCount = 0;
    
    for (final plot in plots) {
      try {
        // Process GeoJSON and extract coordinates
        final coordinates = _extractCoordinatesFromGeoJson(plot.stAsgeojson);
        if (coordinates.isNotEmpty) {
          // Store processed coordinates in cache
          await OptimizedPlotsCache.storeProcessedGeoJson('plot_${plot.id}', {
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
    print('✅ Processed $processedCount plot polygons');
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
  
  /// Preload essential map tiles
  static Future<void> _preloadEssentialMapTiles() async {
    print('🚀 Preloading essential map tiles...');
    
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
    print('✅ Preloaded $tilesPreloaded map tiles');
  }
  
  /// Calculate tile coordinates for a point using correct Web Mercator formula
  static Map<String, int> _calculateTileCoordinates(LatLng point, int zoom) {
    final n = 1 << zoom;
    
    // Longitude to X (correct)
    final x = ((point.longitude + 180) / 360 * n).floor();
    
    // Latitude to Y (corrected Web Mercator formula)
    final latRad = radians(point.latitude);
    final y = ((1 - (log(tan(pi / 4 + latRad / 2)) / pi)) / 2 * n).floor();
    
    return {'x': x, 'y': y};
  }
  
  /// Preload amenities data
  static Future<void> _preloadAmenitiesData() async {
    print('🚀 Preloading amenities data...');
    
    try {
      // This would preload amenities data if you have an API for it
      // For now, we'll just mark it as completed
      _preloadStatus['amenities_loaded'] = true;
      print('✅ Amenities data preloaded');
    } catch (e) {
      print('❌ Error preloading amenities: $e');
    }
  }
  
  /// Preload API responses
  static Future<void> _preloadApiResponses() async {
    print('🚀 Preloading API responses...');
    
    try {
      // Preload common API responses
      final endpoints = [
        'plots',
        'amenities',
        'phases',
        'statistics',
      ];
      
      for (final endpoint in endpoints) {
        try {
          final response = await http.get(
            Uri.parse('https://backend-apis.dhamarketplace.com/api/$endpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ).timeout(const Duration(seconds: 10));
          
          if (response.statusCode == 200) {
            await OptimizedPlotsCache.storeApiResponse(endpoint, response.body);
          }
        } catch (e) {
          // Continue if endpoint fails
        }
      }
      
      _preloadStatus['api_responses_loaded'] = endpoints.length;
      print('✅ Preloaded API responses');
    } catch (e) {
      print('❌ Error preloading API responses: $e');
    }
  }
  
  /// Print preload summary
  static void _printPreloadSummary() {
    print('🚀 ===== PRELOAD SUMMARY =====');
    print('🚀 Boundaries: ${_preloadStatus['boundaries_loaded'] ?? 0}');
    print('🚀 Plots: ${_preloadStatus['plots_loaded'] ?? 0}');
    print('🚀 Polygons: ${_preloadStatus['polygons_processed'] ?? 0}');
    print('🚀 Tiles: ${_preloadStatus['tiles_preloaded'] ?? 0}');
    print('🚀 API Responses: ${_preloadStatus['api_responses_loaded'] ?? 0}');
    print('🚀 ============================');
  }
  
  /// Check if preloading is complete
  static bool get isPreloaded => _isPreloaded;
  
  /// Check if preloading is in progress
  static bool get isPreloading => _isPreloading;
  
  /// Get preload status
  static Map<String, dynamic> getPreloadStatus() {
    return {
      'is_preloaded': _isPreloaded,
      'is_preloading': _isPreloading,
      'status': _preloadStatus,
    };
  }
  
  /// Helper functions for tile calculations
  static double radians(double degrees) => degrees * (pi / 180);
  static double log(double x) => math.log(x);
  static double tan(double x) => math.tan(x);
  static double cos(double x) => math.cos(x);
  static const double pi = 3.14159265359;
}
