import 'dart:convert';
import 'package:http/http.dart' as http;

/// Progressive filter service for dynamic API-based filtering
class ProgressiveFilterService {
  static const String baseUrl = 'https://backend-apis.dhamarketplace.com/api';
  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  /// Load all plots initially (price range 0 to 100,000,000)
  static Future<FilteredPlotsResponse> loadAllPlots() async {
    print('ProgressiveFilterService: Loading all plots (price range 0-100,000,000)');
    
    final url = '$baseUrl/filtered-plots?price_from=0&price_to=100000000';
    
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
          
          print('ProgressiveFilterService: ✅ Loaded ${result.plots.length} total plots');
          return result;
        } else {
          throw Exception('Failed to load all plots: ${response.statusCode}');
        }
      } catch (e) {
        print('ProgressiveFilterService: Attempt $attempt failed: $e');
        
        if (attempt == _maxRetries) {
          throw Exception('Failed to load all plots after $_maxRetries attempts: $e');
        }
        
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    
    throw Exception('Failed to load all plots');
  }

  /// Step 1: Filter by price range only
  static Future<FilteredPlotsResponse> filterByPriceRange({
    required double priceFrom,
    required double priceTo,
  }) async {
    print('ProgressiveFilterService: Filtering by price range $priceFrom - $priceTo');
    
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
          
          print('ProgressiveFilterService: ✅ Price filter returned ${result.plots.length} plots');
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
  }

  /// Step 2: Filter by category within price range
  static Future<FilteredPlotsResponse> filterByCategory({
    required String category,
    required double priceFrom,
    required double priceTo,
  }) async {
    print('ProgressiveFilterService: Filtering by category $category with price $priceFrom - $priceTo');
    
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
          
          print('ProgressiveFilterService: ✅ Category filter returned ${result.plots.length} plots');
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
    
    final url = '$baseUrl/filter-plots-range?price_from=${priceFrom.toInt()}&price_to=${priceTo.toInt()}&phase=$phase&category=$category&size=$size';
    
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
      final sizes = result.plots.map((plot) => plot.size).toSet().toList();
      
      print('ProgressiveFilterService: Available sizes for $phase, $category in price $priceFrom-$priceTo: $sizes');
      return sizes;
    } catch (e) {
      print('ProgressiveFilterService: Error getting available sizes: $e');
      return [];
    }
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
          ?.map((plot) => PlotData.fromJson(plot))
          .toList() ?? [],
      counts: PlotCounts.fromJson(json['data']['counts'] ?? {}),
    );
  }
}

/// Individual plot data model
class PlotData {
  final int id;
  final int eventHistoryId;
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
  final String expoBasePrice;
  final String oneYrEp;
  final String twoYrsEp;
  final String twoFiveYrsEp;
  final String threeYrsEp;
  final String vloggerBasePrice;
  final String vloggerOneYrPlan;
  final String vloggerTwoYrsPlan;
  final String stAsgeojson;
  final EventHistory eventHistory;

  PlotData({
    required this.id,
    required this.eventHistoryId,
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
    required this.expoBasePrice,
    required this.oneYrEp,
    required this.twoYrsEp,
    required this.twoFiveYrsEp,
    required this.threeYrsEp,
    required this.vloggerBasePrice,
    required this.vloggerOneYrPlan,
    required this.vloggerTwoYrsPlan,
    required this.stAsgeojson,
    required this.eventHistory,
  });

  factory PlotData.fromJson(Map<String, dynamic> json) {
    return PlotData(
      id: json['id'] ?? 0,
      eventHistoryId: json['event_history_id'] ?? 0,
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
      expoBasePrice: json['base_price'] ?? '', // Fixed: was expo_base_price
      oneYrEp: json['one_yr_plan'] ?? '', // Fixed: was one_yr_ep
      twoYrsEp: json['two_yrs_plan'] ?? '', // Fixed: was two_yrs_ep
      twoFiveYrsEp: json['two_five_yrs_plan'] ?? '', // Fixed: was two_five_yrs_ep
      threeYrsEp: json['three_yrs_plan'] ?? '', // Fixed: was three_yrs_ep
      vloggerBasePrice: json['base_price'] ?? '', // Using base_price for vlogger
      vloggerOneYrPlan: json['one_yr_plan'] ?? '', // Using one_yr_plan for vlogger
      vloggerTwoYrsPlan: json['two_yrs_plan'] ?? '', // Using two_yrs_plan for vlogger
      stAsgeojson: json['st_asgeojson'] ?? '',
      eventHistory: EventHistory.fromJson(json['event_history'] ?? {}),
    );
  }
}

/// Event history model
class EventHistory {
  final int id;
  final int eventId;
  final bool isBidding;
  final Event event;

  EventHistory({
    required this.id,
    required this.eventId,
    required this.isBidding,
    required this.event,
  });

  factory EventHistory.fromJson(Map<String, dynamic> json) {
    return EventHistory(
      id: json['id'] ?? 0,
      eventId: json['event_id'] ?? 0,
      isBidding: json['is_bidding'] ?? false,
      event: Event.fromJson(json['event'] ?? {}),
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
