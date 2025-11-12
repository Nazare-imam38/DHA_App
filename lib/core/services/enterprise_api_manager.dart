import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../../data/models/plot_model.dart';

/// Enterprise-grade API manager for production app
/// Handles thousands of users with optimized performance
class EnterpriseAPIManager {
  static const String baseUrl = 'https://marketplace-testingbackend.dhamarketplace.com/api';
  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRetries = 3;
  
  
  // Performance monitoring
  static final Map<String, int> _performanceMetrics = {};
  static final Map<String, DateTime> _requestTimestamps = {};
  
  /// Load plots with enterprise-grade optimization
  static Future<List<PlotModel>> loadPlotsOptimized({
    LatLng? center,
    double? radius,
    int? zoomLevel,
    bool useCache = true,
  }) async {
    final startTime = DateTime.now();
    final requestId = 'load_plots_${DateTime.now().millisecondsSinceEpoch}';
    
    try {
      // Load basic plot data first (fast response)
      final basicPlots = await _loadBasicPlotsData(center: center, radius: radius);
      
      _recordPerformance('api_success', 1);
      
      final loadTime = DateTime.now().difference(startTime).inMilliseconds;
      _recordPerformance('load_time_ms', loadTime);
      
      print('EnterpriseAPIManager: Loaded ${basicPlots.length} plots in ${loadTime}ms');
      return basicPlots;
      
    } catch (e) {
      _recordPerformance('api_error', 1);
      print('EnterpriseAPIManager: Error loading plots: $e');
      rethrow;
    }
  }
  
  /// Load basic plot data without heavy GeoJSON parsing
  static Future<List<PlotModel>> _loadBasicPlotsData({
    LatLng? center,
    double? radius,
  }) async {
    int attempts = 0;
    
    while (attempts < _maxRetries) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/plots'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Cache-Control': 'no-cache',
          },
        ).timeout(_timeout);
        
        if (response.statusCode == 200) {
          final List<dynamic> jsonData = jsonDecode(response.body);
          
          // Parse only essential data, defer GeoJSON parsing
          final plots = jsonData.map((json) => _createBasicPlotModel(json)).toList();
          
          // Apply viewport filtering if specified
          if (center != null && radius != null) {
            return _filterPlotsByViewport(plots, center, radius);
          }
          
          return plots;
        } else {
          throw Exception('API Error ${response.statusCode}');
        }
      } catch (e) {
        attempts++;
        if (attempts >= _maxRetries) {
          rethrow;
        }
        await Future.delayed(Duration(seconds: attempts * 2));
      }
    }
    
    throw Exception('Failed to load plots after $_maxRetries attempts');
  }
  
  /// Create basic plot model without heavy GeoJSON parsing
  static PlotModel _createBasicPlotModel(Map<String, dynamic> json) {
    // Extract only essential data for fast loading
    final geoJsonString = json['st_asgeojson'] as String;
    
    // Parse coordinates only for lat/lng, defer polygon parsing
    final coordinates = _extractBasicCoordinates(geoJsonString);
    
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
      stAsgeojson: geoJsonString, // Store raw GeoJSON for later parsing
      eventHistory: EventHistory.fromJson(json['event_history'] as Map<String, dynamic>),
      latitude: coordinates['latitude'],
      longitude: coordinates['longitude'],
      expoBasePrice: json['expo_base_price'] as String?,
      vloggerBasePrice: json['vlogger_base_price'] as String?,
    );
  }
  
  /// Extract basic coordinates without full GeoJSON parsing
  static Map<String, double?> _extractBasicCoordinates(String geoJsonString) {
    try {
      final geoJson = jsonDecode(geoJsonString);
      
      if (geoJson['type'] == 'MultiPolygon' && geoJson['coordinates'] != null) {
        final coordinates = geoJson['coordinates'] as List;
        if (coordinates.isNotEmpty) {
          final firstPolygon = coordinates[0] as List;
          if (firstPolygon.isNotEmpty) {
            final firstRing = firstPolygon[0] as List;
            if (firstRing.isNotEmpty) {
              // Calculate center point quickly
              double sumX = 0;
              double sumY = 0;
              int count = 0;
              
              for (final point in firstRing) {
                if (point is List && point.length >= 2) {
                  sumX += point[0] as double;
                  sumY += point[1] as double;
                  count++;
                }
              }
              
              if (count > 0) {
                final centerX = sumX / count;
                final centerY = sumY / count;
                
                // Convert UTM coordinates to lat/lng using proper UTM Zone 43N conversion
                final latLng = _utmToLatLng(centerX, centerY, 43, northernHemisphere: true);
                return {
                  'latitude': latLng.latitude,
                  'longitude': latLng.longitude,
                };
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error extracting basic coordinates: $e');
    }
    return {'latitude': null, 'longitude': null};
  }
  
  /// Filter plots by viewport for performance
  static List<PlotModel> _filterPlotsByViewport(
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
  
  /// Convert UTM coordinates to LatLng using proper UTM Zone 43N conversion
  static LatLng _utmToLatLng(double easting, double northing, int zoneNumber,
      {bool northernHemisphere = true}) {
    const double a = 6378137.0; // WGS84 major axis
    const double e = 0.081819191; // WGS84 eccentricity
    const double k0 = 0.9996;

    double x = easting - 500000.0; // remove 500,000 meter offset
    double y = northing;

    if (!northernHemisphere) {
      y -= 10000000.0; // adjust for southern hemisphere
    }

    double m = y / k0;
    double mu = m / (a * (1 - pow(e, 2) / 4 - 3 * pow(e, 4) / 64 - 5 * pow(e, 6) / 256));

    double e1 = (1 - sqrt(1 - pow(e, 2))) / (1 + sqrt(1 - pow(e, 2)));

    double j1 = (3 * e1 / 2 - 27 * pow(e1, 3) / 32);
    double j2 = (21 * pow(e1, 2) / 16 - 55 * pow(e1, 4) / 32);
    double j3 = (151 * pow(e1, 3) / 96);
    double j4 = (1097 * pow(e1, 4) / 512);

    double fp = mu +
        j1 * sin(2 * mu) +
        j2 * sin(4 * mu) +
        j3 * sin(6 * mu) +
        j4 * sin(8 * mu);

    double e2 = pow((e * a / (a * (1 - pow(e, 2)))), 2).toDouble();
    double c1 = e2 * pow(cos(fp), 2).toDouble();
    double t1 = pow(tan(fp), 2).toDouble();
    double r1 = a * (1 - pow(e, 2)) /
        pow(1 - pow(e, 2) * pow(sin(fp), 2), 1.5).toDouble();
    double n1 = a / sqrt(1 - pow(e, 2) * pow(sin(fp), 2));

    double d = x / (n1 * k0);

    double q1 = n1 * tan(fp) / r1;
    double q2 = (pow(d, 2) / 2);
    double q3 = (5 + 3 * t1 + 10 * c1 - 4 * pow(c1, 2) - 9 * e2) * pow(d, 4) / 24;
    double q4 = (61 + 90 * t1 + 298 * c1 + 45 * pow(t1, 2) - 3 * pow(c1, 2) - 252 * e2) * pow(d, 6) / 720;
    double lat = fp - q1 * (q2 - q3 + q4);

    double q5 = d;
    double q6 = (1 + 2 * t1 + c1) * pow(d, 3) / 6;
    double q7 = (5 - 2 * c1 + 28 * t1 - 3 * pow(c1, 2) + 8 * e2 + 24 * pow(t1, 2)) * pow(d, 5) / 120;
    double lng = (d - q6 + q7) / cos(fp);

    double lonOrigin = (zoneNumber - 1) * 6 - 180 + 3;

    lat = lat * (180 / pi);
    lng = lonOrigin + lng * (180 / pi);

    return LatLng(lat, lng);
  }
  
  
  /// Performance monitoring
  static void _recordPerformance(String metric, int value) {
    _performanceMetrics[metric] = (_performanceMetrics[metric] ?? 0) + value;
  }
  
  /// Get performance statistics
  static Map<String, dynamic> getPerformanceStats() {
    return {
      'api_success': _performanceMetrics['api_success'] ?? 0,
      'api_errors': _performanceMetrics['api_error'] ?? 0,
      'avg_load_time': _performanceMetrics['load_time_ms'] ?? 0,
    };
  }
}
