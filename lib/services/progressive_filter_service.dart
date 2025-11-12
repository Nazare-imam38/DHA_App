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
      final url = '$baseUrl/filtered-plots?price_from=${priceFrom.toInt()}&price_to=${priceTo.toInt()}';
      
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
            final Map<String, dynamic> jsonData = json.decode(response.body);
            final result = FilteredPlotsResponse.fromJson(jsonData);
            
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
      final url = '$baseUrl/filter-plots-range?category=$category&price_from=${priceFrom.toInt()}&price_to=${priceTo.toInt()}';
      
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
            final Map<String, dynamic> jsonData = json.decode(response.body);
            final result = FilteredPlotsResponse.fromJson(jsonData);
            
            // Performance optimization: Cache the response
            _cacheResponse(cacheKey, result);
            
            print('ProgressiveFilterService: ✅ Category filter returned ${result.plots.length} plots');
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
    print('ProgressiveFilterService: Filtering by phase $phase with category $category and price $priceFrom - $priceTo');
    
    final url = '$baseUrl/filter-plots-range?phase=$phase&category=$category&price_from=${priceFrom.toInt()}&price_to=${priceTo.toInt()}';
    
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
          final Map<String, dynamic> jsonData = json.decode(response.body);
          final result = FilteredPlotsResponse.fromJson(jsonData);
          
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
    print('ProgressiveFilterService: Filtering by size $size with phase $phase, category $category and price $priceFrom - $priceTo');
    
    final url = '$baseUrl/filter-plots-range?price_from=${priceFrom.toInt()}&price_to=${priceTo.toInt()}&phase=$phase&category=$category&cat_area=$size';
    
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
          final Map<String, dynamic> jsonData = json.decode(response.body);
          final result = FilteredPlotsResponse.fromJson(jsonData);
          
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
      
      // Extract unique phases from the plots
      final phases = result.plots.map((plot) => plot.phase).toSet().toList();
      
      print('ProgressiveFilterService: Available phases for $category in price $priceFrom-$priceTo: $phases');
      return phases;
    } catch (e) {
      print('ProgressiveFilterService: Error getting available phases: $e');
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

  factory FilteredPlotsResponse.fromJson(Map<String, dynamic> json) {
    return FilteredPlotsResponse(
      success: json['success'] ?? false,
      plots: (json['data']['plots'] as List<dynamic>?)
          ?.map((plot) => PlotData.fromJson(plot as Map<String, dynamic>))
          .toList() ?? [],
      counts: PlotCounts.fromJson(json['data']['counts'] ?? {}),
    );
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
      phase: json['phase'] ?? '',
      sector: json['sector'] ?? '',
      streetNo: json['street_no'] ?? '',
      block: json['block'] ?? '',
      status: json['status'] ?? '',
      tokenAmount: json['token_amount'] ?? '',
      remarks: json['remarks'] ?? '',
      holdBy: json['hold_by'],
      expireTime: json['expire_time'],
      basePrice: json['base_price'] ?? '',
      oneYrPlan: json['one_yr_plan'] ?? '',
      twoYrsPlan: json['two_yrs_plan'] ?? '',
      twoFiveYrsPlan: json['two_five_yrs_plan'] ?? '',
      threeYrsPlan: json['three_yrs_plan'] ?? '',
      stAsgeojson: json['st_asgeojson'] ?? '',
      eventHistory: EventHistory.fromJson(json['event_history'] ?? {}),
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
    return EventHistory(
      events: (json['event'] as List<dynamic>?)
          ?.map((event) => Event.fromJson(event as Map<String, dynamic>))
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

  PlotCounts({
    required this.totalCount,
  });

  factory PlotCounts.fromJson(Map<String, dynamic> json) {
    return PlotCounts(
      totalCount: json['total_count'] ?? 0,
    );
  }
}
