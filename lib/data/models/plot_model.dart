import 'dart:convert';
import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../../core/utils/enhanced_geojson_parser.dart';
import '../../core/services/robust_polygon_parser.dart';
import '../../core/services/coordinate_cache_manager.dart';
import '../../core/services/polygon_preloader.dart';

class PlotModel {
  final int id;
  final String? eventHistoryId;
  final String plotNo;
  final String size;
  final String category;
  final String catArea;
  final String? dimension;
  final String phase;
  final String sector;
  final String streetNo;
  final String? block;
  final String status;
  final String tokenAmount;
  final String? remarks;
  final String basePrice;
  final String? holdBy;
  final String? expireTime;
  final String oneYrPlan;
  final String twoYrsPlan;
  final String twoFiveYrsPlan;
  final String threeYrsPlan;
  final String stAsgeojson;
  final EventHistory eventHistory;
  final double? latitude;
  final double? longitude;
  
  // Additional fields for enhanced functionality
  final String? expoBasePrice;
  final String? vloggerBasePrice;
  
  // Cache for converted coordinates to avoid repeated UTM conversions
  List<List<LatLng>>? _cachedPolygonCoordinates;
  

  PlotModel({
    required this.id,
    this.eventHistoryId,
    required this.plotNo,
    required this.size,
    required this.category,
    required this.catArea,
    this.dimension,
    required this.phase,
    required this.sector,
    required this.streetNo,
    this.block,
    required this.status,
    required this.tokenAmount,
    this.remarks,
    required this.basePrice,
    this.holdBy,
    this.expireTime,
    required this.oneYrPlan,
    required this.twoYrsPlan,
    required this.twoFiveYrsPlan,
    required this.threeYrsPlan,
    required this.stAsgeojson,
    required this.eventHistory,
    this.latitude,
    this.longitude,
    this.expoBasePrice,
    this.vloggerBasePrice,
  });

  factory PlotModel.fromJson(Map<String, dynamic> json) {
    // Parse GeoJSON to extract coordinates
    final geoJsonString = json['st_asgeojson'] as String;
    final geoJson = jsonDecode(geoJsonString);
    final coordinates = _extractCoordinates(geoJson);
    
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
      latitude: coordinates['latitude'],
      longitude: coordinates['longitude'],
      expoBasePrice: json['expo_base_price'] as String?,
      vloggerBasePrice: json['vlogger_base_price'] as String?,
    );
  }

  static Map<String, double?> _extractCoordinates(Map<String, dynamic> geoJson) {
    try {
      if (geoJson['type'] == 'MultiPolygon' && geoJson['coordinates'] != null) {
        final coordinates = geoJson['coordinates'] as List;
        if (coordinates.isNotEmpty) {
          final firstPolygon = coordinates[0] as List;
          if (firstPolygon.isNotEmpty) {
            final firstRing = firstPolygon[0] as List;
            if (firstRing.isNotEmpty) {
              // Calculate center point from all coordinates
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
                
                // Convert UTM coordinates to lat/lng
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
      print('Error parsing coordinates: $e');
    }
    return {'latitude': null, 'longitude': null};
  }

  // Proper UTM to Lat/Lng conversion for EPSG:32643 (UTM Zone 43N)
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
  
  /// Clear cached polygon coordinates (useful for memory management)
  void clearPolygonCache() {
    _cachedPolygonCoordinates = null;
    print('PlotModel: Cleared polygon cache for plot ${plotNo}');
  }
  
  /// Pre-cache polygon coordinates to avoid parsing during map rendering
  void preCachePolygonCoordinates() {
    if (_cachedPolygonCoordinates == null) {
      // Trigger parsing and caching
      final _ = polygonCoordinates;
      print('PlotModel: Pre-cached polygon coordinates for plot ${plotNo}');
    }
  }
  
  /// Check if polygon coordinates are cached
  bool get hasCachedPolygonCoordinates => _cachedPolygonCoordinates != null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'event_history_id': eventHistoryId,
      'plot_no': plotNo,
      'size': size,
      'category': category,
      'cat_area': catArea,
      'dimension': dimension,
      'phase': phase,
      'sector': sector,
      'street_no': streetNo,
      'block': block,
      'status': status,
      'token_amount': tokenAmount,
      'remarks': remarks,
      'base_price': basePrice,
      'hold_by': holdBy,
      'expire_time': expireTime,
      'one_yr_plan': oneYrPlan,
      'two_yrs_plan': twoYrsPlan,
      'two_five_yrs_plan': twoFiveYrsPlan,
      'three_yrs_plan': threeYrsPlan,
      'st_asgeojson': stAsgeojson,
      'event_history': eventHistory.toJson(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Helper methods for display
  String get formattedPrice {
    final price = double.tryParse(basePrice) ?? 0;
    if (price >= 1000000) {
      return 'PKR ${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return 'PKR ${(price / 1000).toStringAsFixed(0)}K';
    } else {
      return 'PKR ${price.toStringAsFixed(0)}';
    }
  }

  String get installmentPlans {
    final plans = <String>[];
    if (double.tryParse(oneYrPlan) != null && double.parse(oneYrPlan) > 0) {
      plans.add('1 Year: PKR ${(double.parse(oneYrPlan) / 1000000).toStringAsFixed(1)}M');
    }
    if (double.tryParse(twoYrsPlan) != null && double.parse(twoYrsPlan) > 0) {
      plans.add('2 Years: PKR ${(double.parse(twoYrsPlan) / 1000000).toStringAsFixed(1)}M');
    }
    if (double.tryParse(twoFiveYrsPlan) != null && double.parse(twoFiveYrsPlan) > 0) {
      plans.add('2.5 Years: PKR ${(double.parse(twoFiveYrsPlan) / 1000000).toStringAsFixed(1)}M');
    }
    if (double.tryParse(threeYrsPlan) != null && double.parse(threeYrsPlan) > 0) {
      plans.add('3 Years: PKR ${(double.parse(threeYrsPlan) / 1000000).toStringAsFixed(1)}M');
    }
    return plans.isEmpty ? 'No installment plans available' : plans.join('\n');
  }

  String get statusColor {
    switch (status.toLowerCase()) {
      case 'available':
        return 'green';
      case 'sold':
        return 'red';
      case 'reserved':
        return 'orange';
      case 'unsold':
        return 'blue';
      default:
        return 'grey';
    }
  }

  /// Check if plot has installment plans available
  bool get hasInstallmentPlans {
    return (double.tryParse(oneYrPlan) ?? 0) > 0 ||
           (double.tryParse(twoYrsPlan) ?? 0) > 0 ||
           (double.tryParse(twoFiveYrsPlan) ?? 0) > 0 ||
           (double.tryParse(threeYrsPlan) ?? 0) > 0;
  }

  /// Check if plot is available for booking
  bool get isAvailable {
    return status.toLowerCase() == 'unsold' && holdBy == null;
  }

  /// Check if plot is on hold
  bool get isOnHold {
    return holdBy != null && holdBy!.isNotEmpty;
  }

  /// Get formatted token amount
  String get formattedTokenAmount {
    final amount = double.tryParse(tokenAmount) ?? 0;
    if (amount >= 1000000) {
      return 'PKR ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'PKR ${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return 'PKR ${amount.toStringAsFixed(0)}';
    }
  }

  /// Get available payment plans with amounts
  List<Map<String, String>> get availablePaymentPlans {
    final plans = <Map<String, String>>[];
    
    if ((double.tryParse(oneYrPlan) ?? 0) > 0) {
      plans.add({
        'period': '1 Year',
        'amount': oneYrPlan,
        'formatted': 'PKR ${(double.parse(oneYrPlan) / 1000000).toStringAsFixed(1)}M'
      });
    }
    
    if ((double.tryParse(twoYrsPlan) ?? 0) > 0) {
      plans.add({
        'period': '2 Years',
        'amount': twoYrsPlan,
        'formatted': 'PKR ${(double.parse(twoYrsPlan) / 1000000).toStringAsFixed(1)}M'
      });
    }
    
    if ((double.tryParse(twoFiveYrsPlan) ?? 0) > 0) {
      plans.add({
        'period': '2.5 Years',
        'amount': twoFiveYrsPlan,
        'formatted': 'PKR ${(double.parse(twoFiveYrsPlan) / 1000000).toStringAsFixed(1)}M'
      });
    }
    
    if ((double.tryParse(threeYrsPlan) ?? 0) > 0) {
      plans.add({
        'period': '3 Years',
        'amount': threeYrsPlan,
        'formatted': 'PKR ${(double.parse(threeYrsPlan) / 1000000).toStringAsFixed(1)}M'
      });
    }
    
    return plans;
  }

  /// Get hold status information
  String get holdStatus {
    if (isOnHold) {
      return 'On Hold by ${holdBy}';
    } else if (expireTime != null) {
      return 'Expires: $expireTime';
    } else {
      return 'Available';
    }
  }

  /// Extract polygon coordinates for map rendering using preloaded coordinates
  List<List<LatLng>> get polygonCoordinates {
    // Check preloaded coordinates first (fastest)
    final preloadedCoordinates = PolygonPreloader.getPreloadedCoordinates(id);
    if (preloadedCoordinates != null) {
      print('PlotModel: Using preloaded coordinates for plot ${plotNo} (${preloadedCoordinates.length} polygons)');
      return preloadedCoordinates;
    }
    
    final cacheManager = CoordinateCacheManager();
    
    // Check global cache second
    final cachedCoordinates = cacheManager.getCachedCoordinates(id);
    if (cachedCoordinates != null) {
      print('PlotModel: Using global cache for plot ${plotNo} (${cachedCoordinates.length} polygons)');
      return cachedCoordinates;
    }
    
    // Check local cache third
    if (_cachedPolygonCoordinates != null) {
      print('PlotModel: Using local cache for plot ${plotNo} (${_cachedPolygonCoordinates!.length} polygons)');
      // Also store in global cache for future use
      cacheManager.cacheCoordinates(id, _cachedPolygonCoordinates!);
      return _cachedPolygonCoordinates!;
    }
    
    try {
      print('PlotModel: Converting coordinates for plot ${plotNo} (first time)');
      print('PlotModel: GeoJSON length: ${stAsgeojson.length}');
      
      // Use robust parser with multiple fallback strategies
      final result = RobustPolygonParser.parsePolygonCoordinates(stAsgeojson);
      print('PlotModel: Parsed ${result.length} polygons for plot ${plotNo}');
      
      if (result.isNotEmpty) {
        print('PlotModel: First polygon has ${result.first.length} points');
        if (result.first.isNotEmpty) {
          print('PlotModel: First point: ${result.first.first}');
          print('PlotModel: Last point: ${result.first.last}');
        }
        // Cache in both local and global cache
        _cachedPolygonCoordinates = result;
        cacheManager.cacheCoordinates(id, result);
        return result;
      } else {
        print('PlotModel: ⚠️ No polygons parsed for plot ${plotNo}, trying enhanced parser...');
        // Try enhanced parser as fallback
        final enhancedResult = EnhancedGeoJsonParser.parsePolygonCoordinates(stAsgeojson);
        if (enhancedResult.isNotEmpty) {
          // Cache the enhanced result
          _cachedPolygonCoordinates = enhancedResult;
          cacheManager.cacheCoordinates(id, enhancedResult);
          return enhancedResult;
        } else {
          print('PlotModel: ⚠️ Enhanced parser also failed, trying basic fallback...');
          // Try basic fallback parsing
          final fallbackResult = _fallbackPolygonParsing();
          // Cache the fallback result
          _cachedPolygonCoordinates = fallbackResult;
          cacheManager.cacheCoordinates(id, fallbackResult);
          return fallbackResult;
        }
      }
    } catch (e) {
      print('PlotModel: ❌ Error parsing polygon coordinates for plot ${plotNo}: $e');
      // Try fallback parsing
      final fallbackResult = _fallbackPolygonParsing();
      // Cache the fallback result
      _cachedPolygonCoordinates = fallbackResult;
      cacheManager.cacheCoordinates(id, fallbackResult);
      return fallbackResult;
    }
  }
  
  /// Fallback polygon parsing for when enhanced parser fails
  List<List<LatLng>> _fallbackPolygonParsing() {
    try {
      print('PlotModel: Trying fallback parsing for plot ${plotNo}');
      
      // Simple fallback - try to parse as basic GeoJSON
      final geoJson = json.decode(stAsgeojson);
      final coordinates = geoJson['coordinates'] as List;
      
      if (coordinates.isNotEmpty && coordinates[0] is List && coordinates[0][0] is List) {
        final firstRing = coordinates[0][0] as List;
        final ring = <LatLng>[];
        
        for (final point in firstRing) {
          if (point is List && point.length >= 2) {
            final x = point[0].toDouble();
            final y = point[1].toDouble();
            
            // Check if coordinates are in lat/lng range
            if (x >= -180 && x <= 180 && y >= -90 && y <= 90) {
              ring.add(LatLng(y, x)); // Note: GeoJSON is [lng, lat]
            } else {
              // Assume UTM and convert
              final latLng = _utmToLatLng(x, y, 43, northernHemisphere: true);
              ring.add(latLng);
            }
          }
        }
        
        if (ring.length >= 3) {
          // Ensure polygon is closed
          if (ring.first.latitude != ring.last.latitude || 
              ring.first.longitude != ring.last.longitude) {
            ring.add(ring.first);
          }
          print('PlotModel: ✅ Fallback parsing successful: ${ring.length} points');
          return [ring];
        }
      }
      
      print('PlotModel: ❌ Fallback parsing also failed');
      return [];
    } catch (e) {
      print('PlotModel: ❌ Fallback parsing error: $e');
      return [];
    }
  }
  
  
}

class EventHistory {
  final List<dynamic> event;

  EventHistory({required this.event});

  factory EventHistory.fromJson(Map<String, dynamic> json) {
    return EventHistory(
      event: json['event'] as List<dynamic>? ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event': event,
    };
  }
}

class PlotsResponse {
  final String status;
  final List<PlotModel> plots;
  final String? message;

  PlotsResponse({
    required this.status,
    required this.plots,
    this.message,
  });

  factory PlotsResponse.fromJson(Map<String, dynamic> json) {
    return PlotsResponse(
      status: json['status'] as String? ?? 'error',
      plots: (json['plots'] as List<dynamic>?)
          ?.map((plot) => PlotModel.fromJson(plot as Map<String, dynamic>))
          .toList() ?? [],
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'plots': plots.map((plot) => plot.toJson()).toList(),
      'message': message,
    };
  }
}