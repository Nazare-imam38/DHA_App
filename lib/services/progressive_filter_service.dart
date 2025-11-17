import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

/// Progressive filter service for dynamic API-based filtering
class ProgressiveFilterService {
  static const String baseUrl = 'https://marketplace-testingbackend.dhamarketplace.com/api';
  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRetries = 3;
  
  // Performance optimization: Request deduplication
  static final Map<String, Completer<FilteredPlotsResponse>> _pendingRequests = {};
  static final Map<String, DateTime> _requestTimestamps = {};
  static const Duration _requestDeduplicationWindow = Duration(milliseconds: 500);
  
  // Performance optimization: Response caching
  static final Map<String, CachedResponse> _responseCache = {};
  static const Duration _cacheValidity = Duration(minutes: 5);
  
  // Performance optimization: Smart preloading
  static final Set<String> _preloadedFilters = {};
  static bool _isPreloading = false;

  /// Step 1: Filter by price range only
  static Future<FilteredPlotsResponse> filterByPriceRange({
    required double priceFrom,
    required double priceTo,
  }) async {
    final cacheKey = 'price_range_${priceFrom.toInt()}_${priceTo.toInt()}';
    
    // Performance optimization: Check cache first
    final cachedResponse = _getCachedResponse(cacheKey);
    if (cachedResponse != null) {
      print('ProgressiveFilterService: ✅ Cache hit for price range $priceFrom - $priceTo');
      return cachedResponse;
    }
    
    // Performance optimization: Check for pending request
    if (_pendingRequests.containsKey(cacheKey)) {
      print('ProgressiveFilterService: ⏳ Waiting for pending price range request');
      return await _pendingRequests[cacheKey]!.future;
    }
    
    print('ProgressiveFilterService: Filtering by price range $priceFrom - $priceTo');
    
    final completer = Completer<FilteredPlotsResponse>();
    _pendingRequests[cacheKey] = completer;
    _requestTimestamps[cacheKey] = DateTime.now();
    
    try {
      final url = '$baseUrl/filter-plots-range?price_from=${priceFrom.toInt()}&price_to=${priceTo.toInt()}';
      
      for (int attempt = 1; attempt <= _maxRetries; attempt++) {
        try {
          print('ProgressiveFilterService: Attempt $attempt/$_maxRetries - $url');
          
          final response = await http.get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ).timeout(_timeout);
          
          if (response.statusCode == 200) {
            final responseData = json.decode(response.body);
            final result = FilteredPlotsResponse.fromJson(responseData);
            
            // Performance optimization: Cache the response
            _cacheResponse(cacheKey, result);
            
            print('ProgressiveFilterService: ✅ Price filter returned ${result.plots.length} plots');
            completer.complete(result);
            return result;
          } else {
            throw Exception('Failed to fetch price filtered plots: ${response.statusCode}');
          }
        } catch (e) {
          print('ProgressiveFilterService: Attempt $attempt failed: $e');
          
          if (attempt == _maxRetries) {
            throw Exception('Failed to fetch price filtered plots after $_maxRetries attempts: $e');
          }
          
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
      
      throw Exception('Failed to fetch price filtered plots');
    } finally {
      _pendingRequests.remove(cacheKey);
      _requestTimestamps.remove(cacheKey);
    }
  }

  /// Step 2: Filter by category within price range
  static Future<FilteredPlotsResponse> filterByCategory({
    required String category,
    required double priceFrom,
    required double priceTo,
  }) async {
    final cacheKey = 'category_${category}_${priceFrom.toInt()}_${priceTo.toInt()}';
    
    // Performance optimization: Check cache first
    final cachedResponse = _getCachedResponse(cacheKey);
    if (cachedResponse != null) {
      print('ProgressiveFilterService: ✅ Cache hit for category $category with price $priceFrom - $priceTo');
      return cachedResponse;
    }
    
    // Performance optimization: Check for pending request
    if (_pendingRequests.containsKey(cacheKey)) {
      print('ProgressiveFilterService: ⏳ Waiting for pending category request');
      return await _pendingRequests[cacheKey]!.future;
    }
    
    print('ProgressiveFilterService: Filtering by category $category with price $priceFrom - $priceTo');
    
    final completer = Completer<FilteredPlotsResponse>();
    _pendingRequests[cacheKey] = completer;
    _requestTimestamps[cacheKey] = DateTime.now();
    
    try {
      final url = '$baseUrl/filter-plots-range?price_from=${priceFrom.toInt()}&price_to=${priceTo.toInt()}&category=$category';
      
      for (int attempt = 1; attempt <= _maxRetries; attempt++) {
        try {
          print('ProgressiveFilterService: Attempt $attempt/$_maxRetries - $url');
          
          final response = await http.get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ).timeout(_timeout);
          
          if (response.statusCode == 200) {
            final responseData = json.decode(response.body);
            print('ProgressiveFilterService: 📦 Raw API response type: ${responseData.runtimeType}');
            if (responseData is Map) {
              print('ProgressiveFilterService: 📦 Response keys: ${(responseData as Map).keys.toList()}');
              if ((responseData as Map).containsKey('data')) {
                final data = (responseData as Map)['data'];
                if (data is Map) {
                  print('ProgressiveFilterService: 📦 Data keys: ${(data as Map).keys.toList()}');
                  if ((data as Map).containsKey('plots')) {
                    final plots = (data as Map)['plots'];
                    print('ProgressiveFilterService: 📦 Plots type: ${plots.runtimeType}, count: ${plots is List ? plots.length : 'N/A'}');
                  }
                }
              }
            }
            final result = FilteredPlotsResponse.fromJson(responseData);
            
            // Performance optimization: Cache the response
            _cacheResponse(cacheKey, result);
            
            print('ProgressiveFilterService: ✅ Category filter returned ${result.plots.length} plots');
            if (result.plots.isNotEmpty) {
              print('ProgressiveFilterService: 📋 First plot: id=${result.plots.first.id}, plotNo=${result.plots.first.plotNo}, category=${result.plots.first.category}');
            }
            completer.complete(result);
            return result;
          } else {
            throw Exception('Failed to fetch category filtered plots: ${response.statusCode}');
          }
        } catch (e) {
          print('ProgressiveFilterService: Attempt $attempt failed: $e');
          
          if (attempt == _maxRetries) {
            throw Exception('Failed to fetch category filtered plots after $_maxRetries attempts: $e');
          }
          
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
      
      throw Exception('Failed to fetch category filtered plots');
    } finally {
      _pendingRequests.remove(cacheKey);
      _requestTimestamps.remove(cacheKey);
    }
  }

  /// Step 3: Filter by phase within category and price range
  static Future<FilteredPlotsResponse> filterByPhase({
    required String phase,
    required String category,
    required double priceFrom,
    required double priceTo,
  }) async {
    // Convert phase format: "Phase 1" -> "1", "Phase 2" -> "2", etc.
    final apiPhase = _convertPhaseToApiFormat(phase);
    print('ProgressiveFilterService: Filtering by phase $phase (API format: $apiPhase) with category $category and price $priceFrom - $priceTo');
    
    final url = '$baseUrl/filter-plots-range?phase=$apiPhase&category=$category&price_from=${priceFrom.toInt()}&price_to=${priceTo.toInt()}';
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        print('ProgressiveFilterService: Attempt $attempt/$_maxRetries - $url');
        
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(_timeout);
        
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final result = FilteredPlotsResponse.fromJson(responseData);
          
          print('ProgressiveFilterService: ✅ Phase filter returned ${result.plots.length} plots');
          return result;
        } else {
          throw Exception('Failed to fetch phase filtered plots: ${response.statusCode}');
        }
      } catch (e) {
        print('ProgressiveFilterService: Attempt $attempt failed: $e');
        
        if (attempt == _maxRetries) {
          throw Exception('Failed to fetch phase filtered plots after $_maxRetries attempts: $e');
        }
        
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    
    throw Exception('Failed to fetch phase filtered plots');
  }

  /// Step 4: Filter by plot size within all previous filters
  static Future<FilteredPlotsResponse> filterBySize({
    required String size,
    required String phase,
    required String category,
    required double priceFrom,
    required double priceTo,
  }) async {
    // Convert phase format: "Phase 1" -> "1", "Phase 2" -> "2", etc.
    final apiPhase = _convertPhaseToApiFormat(phase);
    // URL-encode the size parameter (e.g., "5 Kanal" -> "5+Kanal" or "5%20Kanal")
    final encodedSize = Uri.encodeComponent(size).replaceAll('%20', '+');
    print('ProgressiveFilterService: Filtering by size $size (encoded: $encodedSize) with phase $phase (API format: $apiPhase), category $category and price $priceFrom - $priceTo');
    
    final url = '$baseUrl/filter-plots-range?price_from=${priceFrom.toInt()}&price_to=${priceTo.toInt()}&phase=$apiPhase&category=$category&cat_area=$encodedSize';
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        print('ProgressiveFilterService: Attempt $attempt/$_maxRetries - $url');
        
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(_timeout);
        
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final result = FilteredPlotsResponse.fromJson(responseData);
          
          print('ProgressiveFilterService: ✅ Size filter returned ${result.plots.length} plots');
          return result;
        } else {
          throw Exception('Failed to fetch size filtered plots: ${response.statusCode}');
        }
      } catch (e) {
        print('ProgressiveFilterService: Attempt $attempt failed: $e');
        
        if (attempt == _maxRetries) {
          throw Exception('Failed to fetch size filtered plots after $_maxRetries attempts: $e');
        }
        
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    
    throw Exception('Failed to fetch size filtered plots');
  }

  /// Get available categories for a given price range
  static Future<List<String>> getAvailableCategories({
    required double priceFrom,
    required double priceTo,
  }) async {
    try {
      final result = await filterByPriceRange(priceFrom: priceFrom, priceTo: priceTo);
      
      // Extract unique categories from the plots
      final categories = result.plots.map((plot) => plot.category).toSet().toList();
      
      print('ProgressiveFilterService: Available categories for price $priceFrom-$priceTo: $categories');
      return categories;
    } catch (e) {
      print('ProgressiveFilterService: Error getting available categories: $e');
      return [];
    }
  }

  /// Get available phases for a given category and price range
  static Future<List<String>> getAvailablePhases({
    required String category,
    required double priceFrom,
    required double priceTo,
  }) async {
    try {
      final result = await filterByCategory(
        category: category,
        priceFrom: priceFrom,
        priceTo: priceTo,
      );
      
      // First, try to get phases from the counts object (more reliable)
      List<String> phases = [];
      if (result.counts.phaseCounts != null && result.counts.phaseCounts!.isNotEmpty) {
        phases = result.counts.phaseCounts!.keys.toList();
        print('ProgressiveFilterService: Extracted phases from counts: $phases');
      }
      
      // Fallback: Extract unique phases from the plots if counts not available
      if (phases.isEmpty) {
        phases = result.plots.map((plot) => plot.phase).where((phase) => phase.isNotEmpty).toSet().toList();
        print('ProgressiveFilterService: Extracted phases from plots: $phases');
      }
      
      // Convert phase format to UI format: "1" -> "Phase 1", "4" -> "Phase 4", "RVS" -> "RVS", etc.
      phases = phases.map((phase) {
        // Check if it's a numeric phase
        final phaseNum = int.tryParse(phase.trim());
        if (phaseNum != null) {
          return 'Phase $phaseNum';
        }
        // Check if it's already in "Phase X" format
        if (phase.toLowerCase().startsWith('phase ')) {
          return phase; // Already formatted
        }
        // For text phases like "RVS", "Margalla Enclave", return as-is
        return phase;
      }).toList();
      
      // Sort phases for consistent display (handle numeric phases vs text)
      phases.sort((a, b) {
        // Extract numbers from "Phase 1", "Phase 2", etc.
        final aMatch = RegExp(r'Phase\s*(\d+)', caseSensitive: false).firstMatch(a);
        final bMatch = RegExp(r'Phase\s*(\d+)', caseSensitive: false).firstMatch(b);
        
        if (aMatch != null && bMatch != null) {
          final aNum = int.parse(aMatch.group(1)!);
          final bNum = int.parse(bMatch.group(1)!);
          return aNum.compareTo(bNum);
        }
        if (aMatch != null) return -1; // Numeric phases first
        if (bMatch != null) return 1;
        return a.compareTo(b); // Text phases alphabetically
      });
      
      print('ProgressiveFilterService: ✅ Available phases for $category in price $priceFrom-$priceTo: $phases');
      return phases;
    } catch (e) {
      print('ProgressiveFilterService: ❌ Error getting available phases: $e');
      return [];
    }
  }

  /// Get available plot sizes for given filters
  static Future<List<String>> getAvailableSizes({
    required String phase,
    required String category,
    required double priceFrom,
    required double priceTo,
  }) async {
    try {
      final result = await filterByPhase(
        phase: phase,
        category: category,
        priceFrom: priceFrom,
        priceTo: priceTo,
      );
      
      // Extract unique sizes from the plots
      final sizes = result.plots.map((plot) => plot.catArea).toSet().toList();
      
      print('ProgressiveFilterService: Available sizes for $phase, $category in price $priceFrom-$priceTo: $sizes');
      return sizes;
    } catch (e) {
      print('ProgressiveFilterService: Error getting available sizes: $e');
      return [];
    }
  }
  
  /// Convert phase format for API: "Phase 1" -> "1", "Phase 2" -> "2", "RVS" -> "RVS"
  static String _convertPhaseToApiFormat(String phase) {
    // Handle different phase formats
    if (phase.toLowerCase().contains('phase')) {
      // Extract number from "Phase 1", "Phase 2", etc.
      final match = RegExp(r'phase\s*(\d+)', caseSensitive: false).firstMatch(phase);
      if (match != null) {
        return match.group(1)!;
      }
    }
    
    // Handle RVS and other special cases
    if (phase.toUpperCase() == 'RVS') {
      return 'RVS';
    }
    
    // If it's already a number, return as is
    if (RegExp(r'^\d+$').hasMatch(phase)) {
      return phase;
    }
    
    // Default fallback
    return phase;
  }
  
  // Performance optimization: Cache helper methods
  static FilteredPlotsResponse? _getCachedResponse(String cacheKey) {
    final cached = _responseCache[cacheKey];
    if (cached != null && !cached.isExpired) {
      return cached.data;
    }
    return null;
  }
  
  static void _cacheResponse(String cacheKey, FilteredPlotsResponse response) {
    _responseCache[cacheKey] = CachedResponse(
      data: response,
      timestamp: DateTime.now(),
    );
    
    // Clean up old cache entries to prevent memory leaks
    _cleanupExpiredCache();
  }
  
  static void _cleanupExpiredCache() {
    final now = DateTime.now();
    _responseCache.removeWhere((key, cached) => 
      now.difference(cached.timestamp) > _cacheValidity);
  }
  
  // Performance optimization: Smart preloading
  static Future<void> preloadCommonFilters() async {
    if (_isPreloading) return;
    _isPreloading = true;
    
    try {
      print('ProgressiveFilterService: 🚀 Starting smart preloading...');
      
      // Preload common price ranges
      final commonPriceRanges = [
        {'from': 1000000, 'to': 3000000},
        {'from': 3000000, 'to': 5000000},
        {'from': 5000000, 'to': 10000000},
      ];
      
      for (final range in commonPriceRanges) {
        final cacheKey = 'price_range_${range['from']}_${range['to']}';
        if (!_preloadedFilters.contains(cacheKey)) {
          try {
            await filterByPriceRange(
              priceFrom: range['from']!.toDouble(),
              priceTo: range['to']!.toDouble(),
            );
            _preloadedFilters.add(cacheKey);
            print('ProgressiveFilterService: ✅ Preloaded price range ${range['from']}-${range['to']}');
          } catch (e) {
            print('ProgressiveFilterService: ⚠️ Failed to preload price range ${range['from']}-${range['to']}: $e');
          }
        }
      }
      
      print('ProgressiveFilterService: ✅ Smart preloading completed');
    } finally {
      _isPreloading = false;
    }
  }
  
  // Performance optimization: Clear cache when needed
  static void clearCache() {
    _responseCache.clear();
    _preloadedFilters.clear();
    print('ProgressiveFilterService: 🧹 Cache cleared');
  }
  
  // Performance optimization: Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'cache_size': _responseCache.length,
      'preloaded_filters': _preloadedFilters.length,
      'pending_requests': _pendingRequests.length,
    };
  }
}

// Performance optimization: Cached response model
class CachedResponse {
  final FilteredPlotsResponse data;
  final DateTime timestamp;
  
  CachedResponse({
    required this.data,
    required this.timestamp,
  });
  
  bool get isExpired {
    return DateTime.now().difference(timestamp) > ProgressiveFilterService._cacheValidity;
  }
}

/// Response model for filtered plots
class FilteredPlotsResponse {
  final bool success;
  final List<PlotData> plots;
  final PlotCounts counts;

  FilteredPlotsResponse({
    required this.success,
    required this.plots,
    required this.counts,
  });

  factory FilteredPlotsResponse.fromJson(dynamic json) {
    // Handle different response formats from the API
    if (json is List) {
      // API returns a list directly
      return FilteredPlotsResponse(
        success: true,
        plots: json
            .map((plot) {
              if (plot is Map<String, dynamic>) {
                return PlotData.fromJson(plot);
              } else if (plot is Map) {
                return PlotData.fromJson(Map<String, dynamic>.from(plot));
              } else {
                throw FormatException('Plot data is not a Map: ${plot.runtimeType}');
              }
            })
            .toList(),
        counts: PlotCounts(totalCount: json.length),
      );
    }
    
    // API returns a Map/object - handle both Map<String, dynamic> and _JsonMap (web)
    Map<String, dynamic>? jsonMap;
    if (json is Map<String, dynamic>) {
      jsonMap = json;
    } else if (json is Map) {
      // Handle _JsonMap and other Map types (web compatibility)
      jsonMap = Map<String, dynamic>.from(json);
    }
    
    if (jsonMap != null) {
      // Check if response has nested 'data' structure
      final dataValue = jsonMap['data'];
      if (dataValue != null) {
        Map<String, dynamic>? data;
        if (dataValue is Map<String, dynamic>) {
          data = dataValue;
        } else if (dataValue is Map) {
          data = Map<String, dynamic>.from(dataValue);
        }
        
        if (data != null) {
          // Safely extract plots - handle both List and ensure it's not a Map
          List<dynamic> plotsList = [];
          if (data.containsKey('plots')) {
            final plotsValue = data['plots'];
            if (plotsValue is List) {
              plotsList = plotsValue;
              print('ProgressiveFilterService: ✅ Successfully extracted ${plotsList.length} plots from data.plots');
            } else if (plotsValue is Map) {
              // If plots is a Map, it's an error - log and use empty list
              print('ProgressiveFilterService: ⚠️ ERROR - plots is a Map, not a List! Type: ${plotsValue.runtimeType}');
              plotsList = [];
            } else {
              print('ProgressiveFilterService: ⚠️ plots is neither List nor Map. Type: ${plotsValue.runtimeType}');
              plotsList = [];
            }
          } else {
            print('ProgressiveFilterService: ⚠️ data does not contain "plots" key');
          }
          
          // Safely extract counts - handle both Map and int
          Map<String, dynamic> countsMap = {};
          if (data.containsKey('counts')) {
            final countsValue = data['counts'];
            if (countsValue is Map) {
              countsMap = Map<String, dynamic>.from(countsValue);
              print('ProgressiveFilterService: ✅ Successfully extracted counts Map with keys: ${countsMap.keys.toList()}');
            } else if (countsValue is int) {
              // If counts is an integer, create a map with total_count
              countsMap = {'total_count': countsValue};
              print('ProgressiveFilterService: ✅ Converted counts int ($countsValue) to Map');
            } else {
              print('ProgressiveFilterService: ⚠️ counts is neither Map nor int. Type: ${countsValue.runtimeType}');
              countsMap = {};
            }
          } else {
            print('ProgressiveFilterService: ⚠️ data does not contain "counts" key');
          }
          
          final result = FilteredPlotsResponse(
            success: jsonMap['success'] ?? true,
            plots: plotsList
                .map((plot) {
                  if (plot is Map<String, dynamic>) {
                    return PlotData.fromJson(plot);
                  } else if (plot is Map) {
                    return PlotData.fromJson(Map<String, dynamic>.from(plot));
                  } else {
                    throw FormatException('Plot data is not a Map: ${plot.runtimeType}');
                  }
                })
                .toList(),
            counts: PlotCounts.fromJson(countsMap),
          );
          
          print('ProgressiveFilterService: ✅ Parsed response - ${result.plots.length} plots, totalCount: ${result.counts.totalCount}');
          return result;
        }
      }
      
      // Check if plots are directly in the root (alternative API format)
      final plotsValue = jsonMap['plots'];
      if (plotsValue != null && plotsValue is List) {
        // Safely extract counts - handle both Map and int
        Map<String, dynamic> countsMap = {};
        if (jsonMap.containsKey('counts')) {
          final countsValue = jsonMap['counts'];
          if (countsValue is Map) {
            countsMap = Map<String, dynamic>.from(countsValue);
          } else if (countsValue is int) {
            // If counts is an integer, create a map with total_count
            countsMap = {'total_count': countsValue};
          } else {
            print('ProgressiveFilterService: ⚠️ counts is neither Map nor int. Type: ${countsValue.runtimeType}');
            countsMap = {};
          }
        }
        
        return FilteredPlotsResponse(
          success: jsonMap['success'] ?? true,
          plots: (plotsValue as List)
              .map((plot) {
                if (plot is Map<String, dynamic>) {
                  return PlotData.fromJson(plot);
                } else if (plot is Map) {
                  return PlotData.fromJson(Map<String, dynamic>.from(plot));
                } else {
                  throw FormatException('Plot data is not a Map: ${plot.runtimeType}');
                }
              })
              .toList(),
          counts: PlotCounts.fromJson(countsMap),
        );
      }
      
      // Fallback: try to extract plots from any structure
      return FilteredPlotsResponse(
        success: jsonMap['success'] ?? true,
        plots: [],
        counts: PlotCounts(totalCount: 0),
      );
    }
    
    // Unknown format
    throw FormatException('Unexpected response format: ${json.runtimeType}');
  }
}

/// Individual plot data model
class PlotData {
  final int id;
  final int? eventHistoryId;
  final String plotNo;
  final String size;
  final String category;
  final String catArea;
  final String dimension;
  final String phase;
  final String sector;
  final String streetNo;
  final String block;
  final String status;
  final String tokenAmount;
  final String remarks;
  final String? holdBy;
  final String? expireTime;
  final String basePrice;
  final String oneYrPlan;
  final String twoYrsPlan;
  final String twoFiveYrsPlan;
  final String threeYrsPlan;
  final String stAsgeojson;
  final EventHistory eventHistory;

  PlotData({
    required this.id,
    this.eventHistoryId,
    required this.plotNo,
    required this.size,
    required this.category,
    required this.catArea,
    required this.dimension,
    required this.phase,
    required this.sector,
    required this.streetNo,
    required this.block,
    required this.status,
    required this.tokenAmount,
    required this.remarks,
    this.holdBy,
    this.expireTime,
    required this.basePrice,
    required this.oneYrPlan,
    required this.twoYrsPlan,
    required this.twoFiveYrsPlan,
    required this.threeYrsPlan,
    required this.stAsgeojson,
    required this.eventHistory,
  });

  factory PlotData.fromJson(Map<String, dynamic> json) {
    return PlotData(
      id: json['id'] ?? 0,
      eventHistoryId: json['event_history_id'],
      plotNo: json['plot_no'] ?? '',
      size: json['size'] ?? '',
      category: json['category'] ?? '',
      catArea: json['cat_area'] ?? '',
      dimension: json['dimension'] ?? '',
      phase: json['phase']?.toString() ?? '',
      sector: json['sector'] ?? '',
      streetNo: json['street_no'] ?? '',
      block: json['block'] ?? '',
      status: json['status'] ?? '',
      tokenAmount: json['token_amount'] ?? '',
      remarks: json['remarks'] ?? '',
      holdBy: json['hold_by'],
      expireTime: json['expire_time'],
      // API returns expo_base_price, fallback to base_price for compatibility
      basePrice: json['expo_base_price']?.toString() ?? json['base_price']?.toString() ?? '0',
      // API returns one_yr_ep, two_yrs_ep, etc. (not one_yr_plan)
      oneYrPlan: json['one_yr_ep']?.toString() ?? json['one_yr_plan']?.toString() ?? '0',
      twoYrsPlan: json['two_yrs_ep']?.toString() ?? json['two_yrs_plan']?.toString() ?? '0',
      twoFiveYrsPlan: json['two_five_yrs_ep']?.toString() ?? json['two_five_yrs_plan']?.toString() ?? '0',
      threeYrsPlan: json['three_yrs_ep']?.toString() ?? json['three_yrs_plan']?.toString() ?? '0',
      stAsgeojson: json['st_asgeojson'] ?? '',
      eventHistory: EventHistory.fromJson(
        json['event_history'] is Map<String, dynamic>
            ? json['event_history'] as Map<String, dynamic>
            : json['event_history'] is Map
                ? Map<String, dynamic>.from(json['event_history'] as Map)
                : <String, dynamic>{},
      ),
    );
  }
}

/// Event history model
class EventHistory {
  final List<Event> events;

  EventHistory({
    required this.events,
  });

  factory EventHistory.fromJson(Map<String, dynamic> json) {
    final eventValue = json['event'];
    List<dynamic>? eventsList;
    
    if (eventValue is List) {
      eventsList = eventValue;
    } else if (eventValue is List<dynamic>) {
      eventsList = eventValue;
    }
    
    return EventHistory(
      events: eventsList
          ?.map((event) {
            if (event is Map<String, dynamic>) {
              return Event.fromJson(event);
            } else if (event is Map) {
              return Event.fromJson(Map<String, dynamic>.from(event));
            } else {
              throw FormatException('Event data is not a Map: ${event.runtimeType}');
            }
          })
          .toList() ?? [],
    );
  }
}

/// Event model
class Event {
  final int id;
  final String title;
  final String status;
  final String startDate;
  final String endDate;

  Event({
    required this.id,
    required this.title,
    required this.status,
    required this.startDate,
    required this.endDate,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      status: json['status'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
    );
  }
}

/// Plot counts model
class PlotCounts {
  final int totalCount;
  final Map<String, int>? phaseCounts;

  PlotCounts({
    required this.totalCount,
    this.phaseCounts,
  });

  factory PlotCounts.fromJson(Map<String, dynamic> json) {
    Map<String, int>? phases;
    
    // Handle phases - can be a Map or _JsonMap (web)
    final phasesValue = json['phases'];
    if (phasesValue != null) {
      Map? phasesMap;
      if (phasesValue is Map<String, dynamic>) {
        phasesMap = phasesValue;
      } else if (phasesValue is Map) {
        phasesMap = phasesValue;
      }
      
      if (phasesMap != null) {
        phases = {};
        phasesMap.forEach((key, value) {
          phases![key.toString()] = value is int ? value : (int.tryParse(value.toString()) ?? 0);
        });
      }
    }
    
    return PlotCounts(
      totalCount: json['total_count'] ?? 0,
      phaseCounts: phases,
    );
  }
}
