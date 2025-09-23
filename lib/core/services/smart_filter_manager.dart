import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/plot_model.dart';

/// Smart filter manager with enterprise-grade performance
/// Handles thousands of plots with instant filtering
class SmartFilterManager {
  static const String _filterCacheKey = 'smart_filter_cache';
  static const Duration _cacheValidity = Duration(hours: 2);
  
  // In-memory cache for instant access
  static final Map<String, List<PlotModel>> _filterCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  
  // Performance metrics
  static final Map<String, int> _performanceMetrics = {};
  
  /// Apply filters with smart caching and optimization
  static Future<List<PlotModel>> applyFilters({
    required List<PlotModel> allPlots,
    String? phase,
    String? category,
    String? status,
    String? sector,
    String? size,
    double? minPrice,
    double? maxPrice,
    double? minTokenAmount,
    double? maxTokenAmount,
    bool? hasInstallmentPlans,
    bool? isAvailableOnly,
    bool? hasRemarks,
    String? searchQuery,
  }) async {
    final startTime = DateTime.now();
    
    // Create filter key for caching
    final filterKey = _createFilterKey(
      phase: phase,
      category: category,
      status: status,
      sector: sector,
      size: size,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minTokenAmount: minTokenAmount,
      maxTokenAmount: maxTokenAmount,
      hasInstallmentPlans: hasInstallmentPlans,
      isAvailableOnly: isAvailableOnly,
      hasRemarks: hasRemarks,
      searchQuery: searchQuery,
    );
    
    // Check cache first (instant access)
    if (_isFilterCacheValid(filterKey)) {
      _recordPerformance('filter_cache_hit', 1);
      return _getFromFilterCache(filterKey);
    }
    
    // Apply filters in optimized stages
    List<PlotModel> filteredPlots = allPlots;
    
    // Stage 1: Quick filters (fast operations)
    filteredPlots = _applyQuickFilters(
      filteredPlots,
      phase: phase,
      category: category,
      status: status,
      sector: sector,
      size: size,
    );
    
    // Stage 2: Price filters (medium operations)
    filteredPlots = _applyPriceFilters(
      filteredPlots,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minTokenAmount: minTokenAmount,
      maxTokenAmount: maxTokenAmount,
    );
    
    // Stage 3: Complex filters (slower operations)
    filteredPlots = _applyComplexFilters(
      filteredPlots,
      hasInstallmentPlans: hasInstallmentPlans,
      isAvailableOnly: isAvailableOnly,
      hasRemarks: hasRemarks,
    );
    
    // Stage 4: Search filter (text operations)
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filteredPlots = _applySearchFilter(filteredPlots, searchQuery);
    }
    
    // Cache the result for instant future access
    _storeInFilterCache(filterKey, filteredPlots);
    
    final filterTime = DateTime.now().difference(startTime).inMilliseconds;
    _recordPerformance('filter_time_ms', filterTime);
    
    print('SmartFilterManager: Filtered ${filteredPlots.length} plots in ${filterTime}ms');
    return filteredPlots;
  }
  
  /// Apply quick filters (fast operations)
  static List<PlotModel> _applyQuickFilters(
    List<PlotModel> plots, {
    String? phase,
    String? category,
    String? status,
    String? sector,
    String? size,
  }) {
    return plots.where((plot) {
      if (phase != null && plot.phase != phase) return false;
      if (category != null && plot.category.toLowerCase() != category.toLowerCase()) return false;
      if (status != null && plot.status.toLowerCase() != status.toLowerCase()) return false;
      if (sector != null && plot.sector.toLowerCase() != sector.toLowerCase()) return false;
      if (size != null && plot.catArea.toLowerCase() != size.toLowerCase()) return false;
      return true;
    }).toList();
  }
  
  /// Apply price filters (medium operations)
  static List<PlotModel> _applyPriceFilters(
    List<PlotModel> plots, {
    double? minPrice,
    double? maxPrice,
    double? minTokenAmount,
    double? maxTokenAmount,
  }) {
    return plots.where((plot) {
      // Price range filter
      if (minPrice != null || maxPrice != null) {
        final price = double.tryParse(plot.basePrice) ?? 0;
        if (minPrice != null && price < minPrice) return false;
        if (maxPrice != null && price > maxPrice) return false;
      }
      
      // Token amount filter
      if (minTokenAmount != null || maxTokenAmount != null) {
        final tokenAmount = double.tryParse(plot.tokenAmount) ?? 0;
        if (minTokenAmount != null && tokenAmount < minTokenAmount) return false;
        if (maxTokenAmount != null && tokenAmount > maxTokenAmount) return false;
      }
      
      return true;
    }).toList();
  }
  
  /// Apply complex filters (slower operations)
  static List<PlotModel> _applyComplexFilters(
    List<PlotModel> plots, {
    bool? hasInstallmentPlans,
    bool? isAvailableOnly,
    bool? hasRemarks,
  }) {
    return plots.where((plot) {
      // Installment plans filter
      if (hasInstallmentPlans == true) {
        final hasPlans = (double.tryParse(plot.oneYrPlan) ?? 0) > 0 ||
                        (double.tryParse(plot.twoYrsPlan) ?? 0) > 0 ||
                        (double.tryParse(plot.twoFiveYrsPlan) ?? 0) > 0 ||
                        (double.tryParse(plot.threeYrsPlan) ?? 0) > 0;
        if (!hasPlans) return false;
      }
      
      // Availability filter
      if (isAvailableOnly == true) {
        final isAvailable = plot.status.toLowerCase() == 'unsold' && plot.holdBy == null;
        if (!isAvailable) return false;
      }
      
      // Remarks filter
      if (hasRemarks == true) {
        if (plot.remarks == null || plot.remarks!.isEmpty) return false;
      }
      
      return true;
    }).toList();
  }
  
  /// Apply search filter (text operations)
  static List<PlotModel> _applySearchFilter(List<PlotModel> plots, String query) {
    final lowercaseQuery = query.toLowerCase();
    
    return plots.where((plot) {
      return plot.plotNo.toLowerCase().contains(lowercaseQuery) ||
             plot.sector.toLowerCase().contains(lowercaseQuery) ||
             plot.streetNo.toLowerCase().contains(lowercaseQuery) ||
             plot.category.toLowerCase().contains(lowercaseQuery) ||
             plot.catArea.toLowerCase().contains(lowercaseQuery) ||
             plot.phase.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
  
  /// Create unique filter key for caching
  static String _createFilterKey({
    String? phase,
    String? category,
    String? status,
    String? sector,
    String? size,
    double? minPrice,
    double? maxPrice,
    double? minTokenAmount,
    double? maxTokenAmount,
    bool? hasInstallmentPlans,
    bool? isAvailableOnly,
    bool? hasRemarks,
    String? searchQuery,
  }) {
    final keyParts = <String>[];
    
    if (phase != null) keyParts.add('phase:$phase');
    if (category != null) keyParts.add('category:$category');
    if (status != null) keyParts.add('status:$status');
    if (sector != null) keyParts.add('sector:$sector');
    if (size != null) keyParts.add('size:$size');
    if (minPrice != null) keyParts.add('minPrice:$minPrice');
    if (maxPrice != null) keyParts.add('maxPrice:$maxPrice');
    if (minTokenAmount != null) keyParts.add('minToken:$minTokenAmount');
    if (maxTokenAmount != null) keyParts.add('maxToken:$maxTokenAmount');
    if (hasInstallmentPlans == true) keyParts.add('hasPlans:true');
    if (isAvailableOnly == true) keyParts.add('availableOnly:true');
    if (hasRemarks == true) keyParts.add('hasRemarks:true');
    if (searchQuery != null && searchQuery.isNotEmpty) keyParts.add('search:$searchQuery');
    
    return keyParts.join('|');
  }
  
  /// Filter cache management
  static void _storeInFilterCache(String key, List<PlotModel> data) {
    _filterCache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
    
    // Persist to disk for app restarts
    _persistFilterCache(key, data);
  }
  
  static List<PlotModel> _getFromFilterCache(String key) {
    return _filterCache[key] ?? [];
  }
  
  static bool _isFilterCacheValid(String key) {
    if (!_filterCache.containsKey(key)) return false;
    
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _cacheValidity;
  }
  
  /// Persist filter cache to disk
  static Future<void> _persistFilterCache(String key, List<PlotModel> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'key': key,
        'data': data.map((plot) => plot.toJson()).toList(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await prefs.setString('${_filterCacheKey}_$key', jsonEncode(cacheData));
    } catch (e) {
      print('Error persisting filter cache: $e');
    }
  }
  
  /// Load filter cache from disk
  static Future<List<PlotModel>> _loadFilterCacheFromDisk(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheString = prefs.getString('${_filterCacheKey}_$key');
      
      if (cacheString != null) {
        final cacheData = jsonDecode(cacheString) as Map<String, dynamic>;
        final timestamp = DateTime.parse(cacheData['timestamp'] as String);
        
        // Check if cache is still valid
        if (DateTime.now().difference(timestamp) < _cacheValidity) {
          final plotsJson = cacheData['data'] as List<dynamic>;
          return plotsJson.map((json) => PlotModel.fromJson(json as Map<String, dynamic>)).toList();
        }
      }
    } catch (e) {
      print('Error loading filter cache: $e');
    }
    
    return [];
  }
  
  /// Performance monitoring
  static void _recordPerformance(String metric, int value) {
    _performanceMetrics[metric] = (_performanceMetrics[metric] ?? 0) + value;
  }
  
  /// Get performance statistics
  static Map<String, dynamic> getPerformanceStats() {
    return {
      'filter_cache_hits': _performanceMetrics['filter_cache_hit'] ?? 0,
      'avg_filter_time': _performanceMetrics['filter_time_ms'] ?? 0,
      'cache_size': _filterCache.length,
    };
  }
  
  /// Clear filter cache
  static void clearFilterCache() {
    _filterCache.clear();
    _cacheTimestamps.clear();
    _performanceMetrics.clear();
  }
  
  /// Preload common filter combinations
  static Future<void> preloadCommonFilters(List<PlotModel> allPlots) async {
    try {
      // Preload common filter combinations
      final commonFilters = [
        {'status': 'unsold'},
        {'category': 'residential'},
        {'category': 'commercial'},
        {'phase': 'Phase1'},
        {'phase': 'Phase2'},
      ];
      
      for (final filter in commonFilters) {
        await applyFilters(
          allPlots: allPlots,
          status: filter['status'],
          category: filter['category'],
          phase: filter['phase'],
        );
      }
      
      print('SmartFilterManager: Preloaded common filters');
    } catch (e) {
      print('SmartFilterManager: Preload failed: $e');
    }
  }
}
