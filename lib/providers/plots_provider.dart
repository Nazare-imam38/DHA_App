import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/plot_model.dart';
import '../data/network/plots_api_service.dart';
import '../core/services/smart_filter_manager.dart';
import '../core/services/progressive_map_renderer.dart';
import '../core/services/coordinate_cache_manager.dart';
import 'polygon_state_provider.dart';
import '../core/utils/plots_debug_analyzer.dart';
import '../core/utils/simple_api_test.dart';

class PlotsProvider with ChangeNotifier {
  List<PlotModel> _plots = [];
  List<PlotModel> _filteredPlots = [];
  bool _isLoading = false;
  
  // Polygon state manager for efficient coordinate handling
  final PolygonStateProvider _polygonStateProvider = PolygonStateProvider();
  String? _error;
  
  // Performance optimization properties
  int _currentZoomLevel = 12;
  
  // Filter states
  String? _selectedPhase;
  String? _selectedCategory;
  String? _selectedStatus;
  // Price range bounds in PKR (defaults per requirement: 5.475M – 565M)
  static const double kMinPriceBound = 5475000; // 5.475M
  static const double kMaxPriceBound = 565000000; // 565M
  RangeValues _priceRange = const RangeValues(kMinPriceBound, kMaxPriceBound);
  String? _selectedArea;
  String? _selectedSector;
  String? _selectedSize;
  
  // Search states
  String _searchQuery = '';
  int? _searchPlotId;
  PlotModel? _searchedPlot;
  
  // New filter states
  RangeValues _tokenAmountRange = const RangeValues(0, 1000000);
  bool _hasInstallmentPlans = false;
  bool _isAvailableOnly = false;
  bool _hasRemarks = false;

  // Getters
  List<PlotModel> get plots => _plots;
  List<PlotModel> get filteredPlots => _filteredPlots;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  String? get selectedPhase => _selectedPhase;
  String? get selectedCategory => _selectedCategory;
  String? get selectedStatus => _selectedStatus;
  RangeValues get priceRange => _priceRange;
  double get minPriceBound => kMinPriceBound;
  double get maxPriceBound => kMaxPriceBound;
  String? get selectedArea => _selectedArea;
  String? get selectedSector => _selectedSector;
  String? get selectedSize => _selectedSize;
  
  // Search getters
  String get searchQuery => _searchQuery;
  int? get searchPlotId => _searchPlotId;
  PlotModel? get searchedPlot => _searchedPlot;
  
  // New filter getters
  RangeValues get tokenAmountRange => _tokenAmountRange;
  bool get hasInstallmentPlans => _hasInstallmentPlans;
  bool get isAvailableOnly => _isAvailableOnly;
  bool get hasRemarks => _hasRemarks;
  
  // Performance optimization getters
  int get currentZoomLevel => _currentZoomLevel;

  // Initialize and fetch plots
  Future<void> fetchPlots({bool forceRefresh = false, int? zoomLevel}) async {
    _isLoading = true;
    _error = null;
    _currentZoomLevel = zoomLevel ?? _currentZoomLevel;
    notifyListeners();

    try {
      print('Loading plots from API...');
      
      // Run simple API test first
      print('🔍 Running simple API test...');
      await SimpleApiTest.testPlotsApi();
      
      // Run comprehensive debug analysis
      print('🔍 Running comprehensive plots API analysis...');
      await PlotsDebugAnalyzer.runCompleteAnalysis();
      
      _plots = await PlotsApiService.fetchPlots();
      _filteredPlots = List.from(_plots);
      _error = null;
      
      print('Plots loaded from API: ${_plots.length}');
      print('Plots with polygons: ${_plots.where((plot) => _polygonStateProvider.hasValidPolygons(plot)).length}');
      
      // Pre-cache polygon coordinates using coordinate cache manager
      print('Pre-caching polygon coordinates using coordinate cache manager...');
      final cacheManager = CoordinateCacheManager();
      cacheManager.preCacheCoordinates(_plots);
      print('Polygon pre-caching completed');
      
      // Debug first plot
      if (_plots.isNotEmpty) {
        final firstPlot = _plots.first;
        print('First plot debug:');
        print('- Plot No: ${firstPlot.plotNo}');
        print('- GeoJSON length: ${firstPlot.stAsgeojson.length}');
        print('- GeoJSON preview: ${firstPlot.stAsgeojson.substring(0, min(100, firstPlot.stAsgeojson.length))}...');
        print('- Polygon coordinates count: ${firstPlot.polygonCoordinates.length}');
      }
      
      if (_plots.isNotEmpty) {
        print('First plot: ${_plots.first.plotNo}, polygons: ${_plots.first.polygonCoordinates.length}');
      }
    } catch (e) {
      _error = e.toString();
      _plots = [];
      _filteredPlots = [];
      print('Error fetching plots: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter methods
  void filterByPhase(String? phase) {
    _selectedPhase = phase;
    _applyFilters();
  }

  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void filterByStatus(String? status) {
    _selectedStatus = status;
    _applyFilters();
  }

  void filterByPriceRange(RangeValues range) {
    _priceRange = range;
    _applyFilters();
  }

  void filterByArea(String? area) {
    _selectedArea = area;
    _applyFilters();
  }

  void filterBySector(String? sector) {
    _selectedSector = sector;
    _applyFilters();
  }

  void filterBySize(String? size) {
    _selectedSize = size;
    _applyFilters();
  }

  // Search methods
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  Future<void> searchPlotById(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _searchedPlot = await PlotsApiService.fetchPlotById(id);
      _searchPlotId = id;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _searchedPlot = null;
      _searchPlotId = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _searchPlotId = null;
    _searchedPlot = null;
    _applyFilters();
  }

  void clearFilters() {
    _selectedPhase = null;
    _selectedCategory = null;
    _selectedStatus = null;
    _priceRange = const RangeValues(kMinPriceBound, kMaxPriceBound);
    _selectedArea = null;
    _selectedSector = null;
    _selectedSize = null;
    _tokenAmountRange = const RangeValues(0, 1000000);
    _hasInstallmentPlans = false;
    _isAvailableOnly = false;
    _hasRemarks = false;
    _applyFilters();
  }

  void clearAllFilters() {
    clearFilters();
    clearSearch();
  }

  // New filter methods
  void filterByTokenAmountRange(RangeValues range) {
    _tokenAmountRange = range;
    _applyFilters();
  }

  void filterByInstallmentPlans(bool hasPlans) {
    _hasInstallmentPlans = hasPlans;
    _applyFilters();
  }

  void filterByAvailability(bool availableOnly) {
    _isAvailableOnly = availableOnly;
    _applyFilters();
  }

  void filterByRemarks(bool hasRemarks) {
    _hasRemarks = hasRemarks;
    _applyFilters();
  }

  void _applyFilters() async {
    // Use smart filter manager for enterprise-grade performance
    try {
      _filteredPlots = await SmartFilterManager.applyFilters(
        allPlots: _plots,
        phase: _selectedPhase,
        category: _selectedCategory,
        status: _selectedStatus,
        sector: _selectedSector,
        size: _selectedSize,
        minPrice: _priceRange.start,
        maxPrice: _priceRange.end,
        minTokenAmount: _tokenAmountRange.start,
        maxTokenAmount: _tokenAmountRange.end,
        hasInstallmentPlans: _hasInstallmentPlans,
        isAvailableOnly: _isAvailableOnly,
        hasRemarks: _hasRemarks,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      
      // Handle searched plot
      if (_searchedPlot != null) {
        _filteredPlots = [_searchedPlot!];
      }
      
      notifyListeners();
    } catch (e) {
      print('Error applying filters: $e');
      // Fallback to basic filtering
      _applyBasicFilters();
    }
  }
  
  /// Fallback to basic filtering if smart filter fails
  void _applyBasicFilters() {
    List<PlotModel> plotsToFilter = _plots;
    
    // If searching by plot ID, show only the searched plot
    if (_searchedPlot != null) {
      plotsToFilter = [_searchedPlot!];
    } else {
      // Apply text search if query exists
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        plotsToFilter = _plots.where((plot) {
          return plot.plotNo.toLowerCase().contains(query) ||
                 plot.sector.toLowerCase().contains(query) ||
                 plot.streetNo.toLowerCase().contains(query) ||
                 plot.category.toLowerCase().contains(query) ||
                 plot.catArea.toLowerCase().contains(query) ||
                 plot.phase.toLowerCase().contains(query);
        }).toList();
      }
    }

    // Apply other filters
    _filteredPlots = plotsToFilter.where((plot) {
      // Price range filter
      final price = double.tryParse(plot.basePrice) ?? 0;
      if (price < _priceRange.start || price > _priceRange.end) {
        return false;
      }
      // Phase filter
      if (_selectedPhase != null && plot.phase != _selectedPhase) {
        return false;
      }

      // Category filter
      if (_selectedCategory != null && plot.category.toLowerCase() != _selectedCategory!.toLowerCase()) {
        return false;
      }

      // Status filter
      if (_selectedStatus != null && plot.status.toLowerCase() != _selectedStatus!.toLowerCase()) {
        return false;
      }

      // Sector filter
      if (_selectedSector != null && plot.sector.toLowerCase() != _selectedSector!.toLowerCase()) {
        return false;
      }

      // Size filter
      if (_selectedSize != null && plot.catArea.toLowerCase() != _selectedSize!.toLowerCase()) {
        return false;
      }

      // Area filter (legacy)
      if (_selectedArea != null && plot.catArea.toLowerCase() != _selectedArea!.toLowerCase()) {
        return false;
      }

      // Token amount filter
      final tokenAmount = double.tryParse(plot.tokenAmount) ?? 0;
      if (tokenAmount < _tokenAmountRange.start || tokenAmount > _tokenAmountRange.end) {
        return false;
      }

      // Installment plans filter
      if (_hasInstallmentPlans && !plot.hasInstallmentPlans) {
        return false;
      }

      // Availability filter
      if (_isAvailableOnly && !plot.isAvailable) {
        return false;
      }

      // Remarks filter
      if (_hasRemarks && (plot.remarks == null || plot.remarks!.isEmpty)) {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  // Dynamic enabled lists based on current filters
  List<String> get enabledPhasesForCurrentFilters {
    final phases = <String>{};
    for (final plot in _plots) {
      final price = double.tryParse(plot.basePrice) ?? 0;
      final matchesPrice = price >= _priceRange.start && price <= _priceRange.end;
      final matchesType = _selectedCategory == null ||
          plot.category.toLowerCase() == _selectedCategory!.toLowerCase();
      if (matchesPrice && matchesType) {
        phases.add(plot.phase);
      }
    }
    final list = phases.toList();
    list.sort();
    return list;
  }

  List<String> get enabledSizesForCurrentFilters {
    final sizes = <String>{};
    for (final plot in _plots) {
      final price = double.tryParse(plot.basePrice) ?? 0;
      final matchesPrice = price >= _priceRange.start && price <= _priceRange.end;
      final matchesType = _selectedCategory == null ||
          plot.category.toLowerCase() == _selectedCategory!.toLowerCase();
      final matchesPhase = _selectedPhase == null || plot.phase == _selectedPhase;
      if (matchesPrice && matchesType && matchesPhase) {
        sizes.add(plot.catArea);
      }
    }
    final list = sizes.toList();
    list.sort();
    return list;
  }

  // Public setters for the four primary filters
  void setPriceRange(RangeValues range) {
    _priceRange = range;
    // Invalidate dependent selections if necessary
    if (_selectedPhase != null && !enabledPhasesForCurrentFilters.contains(_selectedPhase)) {
      _selectedPhase = null;
    }
    if (_selectedSize != null && !enabledSizesForCurrentFilters.contains(_selectedSize)) {
      _selectedSize = null;
    }
    _applyFilters();
  }

  void setPlotType(String? type) {
    _selectedCategory = type;
    if (_selectedPhase != null && !enabledPhasesForCurrentFilters.contains(_selectedPhase)) {
      _selectedPhase = null;
    }
    if (_selectedSize != null && !enabledSizesForCurrentFilters.contains(_selectedSize)) {
      _selectedSize = null;
    }
    _applyFilters();
  }

  void setPhase(String? phase) {
    _selectedPhase = phase;
    if (_selectedSize != null && !enabledSizesForCurrentFilters.contains(_selectedSize)) {
      _selectedSize = null;
    }
    _applyFilters();
  }

  void setPlotSize(String? size) {
    _selectedSize = size;
    _applyFilters();
  }

  // Get plots by coordinates (for map markers)
  List<PlotModel> getPlotsWithCoordinates() {
    return _filteredPlots.where((plot) => 
      plot.latitude != null && plot.longitude != null
    ).toList();
  }

  // Get unique phases for filter dropdown
  List<String> get availablePhases {
    final phases = _plots.map((plot) => plot.phase).toSet().toList();
    phases.sort();
    return phases;
  }

  // Get unique categories for filter dropdown
  List<String> get availableCategories {
    final categories = _plots.map((plot) => plot.category).toSet().toList();
    categories.sort();
    return categories;
  }

  // Get unique statuses for filter dropdown
  List<String> get availableStatuses {
    final statuses = _plots.map((plot) => plot.status).toSet().toList();
    statuses.sort();
    return statuses;
  }

  // Get unique areas for filter dropdown
  List<String> get availableAreas {
    final areas = _plots.map((plot) => plot.catArea).toSet().toList();
    areas.sort();
    return areas;
  }

  // Get unique sectors for filter dropdown
  List<String> get availableSectors {
    final sectors = _plots.map((plot) => plot.sector).toSet().toList();
    sectors.sort();
    return sectors;
  }

  // Get unique sizes for filter dropdown
  List<String> get availableSizes {
    final sizes = _plots.map((plot) => plot.catArea).toSet().toList();
    sizes.sort();
    return sizes;
  }

  // Get price range for slider
  RangeValues get priceRangeBounds {
    if (_plots.isEmpty) return const RangeValues(0, 100000000);
    
    final prices = _plots.map((plot) => double.tryParse(plot.basePrice) ?? 0).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    
    return RangeValues(minPrice, maxPrice);
  }

  // Get plot statistics
  Map<String, int> get plotStatistics {
    final stats = <String, int>{};
    
    for (final plot in _filteredPlots) {
      stats[plot.status] = (stats[plot.status] ?? 0) + 1;
    }
    
    return stats;
  }

  // Search plots
  List<PlotModel> searchPlots(String query) {
    if (query.isEmpty) return _filteredPlots;
    
    final lowercaseQuery = query.toLowerCase();
    return _filteredPlots.where((plot) {
      return plot.plotNo.toLowerCase().contains(lowercaseQuery) ||
             plot.sector.toLowerCase().contains(lowercaseQuery) ||
             plot.streetNo.toLowerCase().contains(lowercaseQuery) ||
             plot.category.toLowerCase().contains(lowercaseQuery) ||
             plot.catArea.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Performance optimization methods
  Future<void> refreshPlots({int? zoomLevel}) async {
    await fetchPlots(forceRefresh: true, zoomLevel: zoomLevel);
  }

  Future<void> updateZoomLevel(int zoomLevel) async {
    if (zoomLevel != _currentZoomLevel) {
      _currentZoomLevel = zoomLevel;
      // Reload plots with new zoom level for polygon optimization
      await fetchPlots(zoomLevel: zoomLevel);
    }
  }

  // These methods are now implemented below using SharedPreferences

  // Get optimized plots for map rendering (limit polygons for performance)
  List<PlotModel> getOptimizedPlotsForMap({int maxPlots = 100}) {
    final plotsWithPolygons = _filteredPlots.where((plot) => 
      plot.polygonCoordinates.isNotEmpty
    ).toList();
    
    // Limit plots for performance
    return plotsWithPolygons.take(maxPlots).toList();
  }

  // Get plots count for performance monitoring
  Map<String, int> getPerformanceStats() {
    return {
      'total_plots': _plots.length,
      'filtered_plots': _filteredPlots.length,
      'plots_with_polygons': _filteredPlots.where((plot) => plot.polygonCoordinates.isNotEmpty).length,
      'cache_hit': 0,
    };
  }

  
  
  /// Pre-cache polygon coordinates for all plots (useful for performance optimization)
  void preCacheAllPolygonCoordinates() {
    print('Pre-caching polygon coordinates for all ${_plots.length} plots...');
    _polygonStateProvider.preCachePolygonCoordinates(_plots);
    print('Pre-caching completed for all plots');
  }
  
  /// Get polygon state provider for advanced polygon management
  PolygonStateProvider get polygonStateProvider => _polygonStateProvider;
  
  /// Get plots with valid polygon coordinates using state manager
  List<PlotModel> getPlotsWithPolygons() {
    return _polygonStateProvider.getPlotsWithPolygons(_filteredPlots);
  }
  
  /// Get polygon statistics
  Map<String, dynamic> getPolygonStats() {
    return _polygonStateProvider.getPolygonStats(_plots);
  }
  
  /// Set plots directly (for optimized loading)
  void setPlotsFromCache(List<PlotModel> plots) {
    _plots = plots;
    _filteredPlots = List.from(_plots);
    _error = null;
    notifyListeners();
  }
  
  /// Clear coordinate cache to free memory
  void clearCoordinateCache() {
    final cacheManager = CoordinateCacheManager();
    cacheManager.clearAllCache();
    print('PlotsProvider: Cleared all coordinate caches');
  }
  
  /// Get coordinate cache statistics
  Map<String, dynamic> getCoordinateCacheStats() {
    final cacheManager = CoordinateCacheManager();
    return cacheManager.getCacheStats();
  }
  
  /// Pre-cache coordinates for all plots
  void preCacheAllCoordinates() {
    final cacheManager = CoordinateCacheManager();
    cacheManager.preCacheCoordinates(_plots);
    print('PlotsProvider: Pre-cached coordinates for all ${_plots.length} plots');
  }
}