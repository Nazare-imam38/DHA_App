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
import '../ui/widgets/dha_loading_widget.dart';
import 'polygon_state_provider.dart';
import '../core/utils/plots_debug_analyzer.dart';
import '../core/utils/simple_api_test.dart';

/// Optimized PlotsProvider with selective rebuilds and performance improvements
/// Preserves all existing functionality while reducing unnecessary rebuilds
class OptimizedPlotsProvider with ChangeNotifier {
  List<PlotModel> _plots = [];
  List<PlotModel> _filteredPlots = [];
  bool _isLoading = false;
  
  // Polygon state manager for efficient coordinate handling
  final PolygonStateProvider _polygonStateProvider = PolygonStateProvider();
  String? _error;
  
  // Performance optimization properties
  int _currentZoomLevel = 12;
  
  // Filter states - using private setters to control rebuilds
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

  // Performance optimization: Debounce timer for filters
  Timer? _filterDebounceTimer;
  
  // Performance optimization: Cache for expensive operations
  Map<String, dynamic> _computedCache = {};
  
  // Performance optimization: Track what needs rebuilding
  bool _needsFilterUpdate = false;
  bool _needsPlotUpdate = false;

  // Getters - all preserved for compatibility
  List<PlotModel> get plots => _plots;
  List<PlotModel> get filteredPlots => _filteredPlots;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Loading widget getter - preserved
  Widget get loadingWidget => DHALoadingWidget(
    size: 120,
    message: 'Loading plots...',
    showMessage: true,
  );
  
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

  /// Optimized fetch plots with selective updates
  Future<void> fetchPlots({bool forceRefresh = false, int? zoomLevel}) async {
    // Only update loading state if it's actually changing
    if (!_isLoading) {
      _isLoading = true;
      _error = null;
      _currentZoomLevel = zoomLevel ?? _currentZoomLevel;
      _needsPlotUpdate = true;
      _notifySelective();
    }

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
      
      // Debug phase values to help identify filtering issues
      _debugPhaseValues();
      
      // Clear computed cache when new data arrives
      _computedCache.clear();
      
    } catch (e) {
      _error = e.toString();
      _plots = [];
      _filteredPlots = [];
      print('Error fetching plots: $e');
    } finally {
      _isLoading = false;
      _needsPlotUpdate = true;
      _needsFilterUpdate = true;
      _notifySelective();
    }
  }

  /// Optimized filter methods with debouncing
  void filterByPhase(String? phase) {
    if (_selectedPhase != phase) {
      _selectedPhase = phase;
      _scheduleFilterUpdate();
    }
  }

  void filterByCategory(String? category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      _scheduleFilterUpdate();
    }
  }

  void filterByStatus(String? status) {
    if (_selectedStatus != status) {
      _selectedStatus = status;
      _scheduleFilterUpdate();
    }
  }

  void filterByPriceRange(RangeValues range) {
    if (_priceRange != range) {
      _priceRange = range;
      _scheduleFilterUpdate();
    }
  }

  void filterByArea(String? area) {
    if (_selectedArea != area) {
      _selectedArea = area;
      _scheduleFilterUpdate();
    }
  }

  void filterBySector(String? sector) {
    if (_selectedSector != sector) {
      _selectedSector = sector;
      _scheduleFilterUpdate();
    }
  }

  void filterBySize(String? size) {
    if (_selectedSize != size) {
      _selectedSize = size;
      _scheduleFilterUpdate();
    }
  }

  /// Optimized search methods
  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      _searchQuery = query;
      _scheduleFilterUpdate();
    }
  }

  Future<void> searchPlotById(int id) async {
    if (_searchPlotId == id) return; // Avoid duplicate searches
    
    _isLoading = true;
    _error = null;
    _needsPlotUpdate = true;
    _notifySelective();

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
      _needsFilterUpdate = true;
      _notifySelective();
    }
  }

  void clearSearch() {
    if (_searchQuery.isNotEmpty || _searchPlotId != null || _searchedPlot != null) {
      _searchQuery = '';
      _searchPlotId = null;
      _searchedPlot = null;
      _scheduleFilterUpdate();
    }
  }

  void clearFilters() {
    bool hasChanges = false;
    
    if (_selectedPhase != null) {
      _selectedPhase = null;
      hasChanges = true;
    }
    if (_selectedCategory != null) {
      _selectedCategory = null;
      hasChanges = true;
    }
    if (_selectedStatus != null) {
      _selectedStatus = null;
      hasChanges = true;
    }
    if (_priceRange != const RangeValues(kMinPriceBound, kMaxPriceBound)) {
      _priceRange = const RangeValues(kMinPriceBound, kMaxPriceBound);
      hasChanges = true;
    }
    if (_selectedArea != null) {
      _selectedArea = null;
      hasChanges = true;
    }
    if (_selectedSector != null) {
      _selectedSector = null;
      hasChanges = true;
    }
    if (_selectedSize != null) {
      _selectedSize = null;
      hasChanges = true;
    }
    if (_tokenAmountRange != const RangeValues(0, 1000000)) {
      _tokenAmountRange = const RangeValues(0, 1000000);
      hasChanges = true;
    }
    if (_hasInstallmentPlans) {
      _hasInstallmentPlans = false;
      hasChanges = true;
    }
    if (_isAvailableOnly) {
      _isAvailableOnly = false;
      hasChanges = true;
    }
    if (_hasRemarks) {
      _hasRemarks = false;
      hasChanges = true;
    }
    
    if (hasChanges) {
      _scheduleFilterUpdate();
    }
  }

  void clearAllFilters() {
    clearFilters();
    clearSearch();
  }

  // New filter methods with optimization
  void filterByTokenAmountRange(RangeValues range) {
    if (_tokenAmountRange != range) {
      _tokenAmountRange = range;
      _scheduleFilterUpdate();
    }
  }

  void filterByInstallmentPlans(bool hasPlans) {
    if (_hasInstallmentPlans != hasPlans) {
      _hasInstallmentPlans = hasPlans;
      _scheduleFilterUpdate();
    }
  }

  void filterByAvailability(bool availableOnly) {
    if (_isAvailableOnly != availableOnly) {
      _isAvailableOnly = availableOnly;
      _scheduleFilterUpdate();
    }
  }

  void filterByRemarks(bool hasRemarks) {
    if (_hasRemarks != hasRemarks) {
      _hasRemarks = hasRemarks;
      _scheduleFilterUpdate();
    }
  }

  /// Optimized filter application with debouncing
  void _scheduleFilterUpdate() {
    _filterDebounceTimer?.cancel();
    _filterDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      _applyFilters();
    });
  }

  /// Optimized filter application
  void _applyFilters() async {
    // Debug filtering process
    print('=== APPLYING FILTERS ===');
    print('Selected phase: $_selectedPhase');
    print('Selected category: $_selectedCategory');
    print('Total plots: ${_plots.length}');
    
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
      
      print('Filtered plots: ${_filteredPlots.length}');
      print('========================');
      
      _needsFilterUpdate = true;
      _notifySelective();
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
      // Phase filter - normalize phase values for comparison
      if (_selectedPhase != null) {
        final normalizedSelectedPhase = _normalizePhaseValue(_selectedPhase!);
        final normalizedPlotPhase = _normalizePhaseValue(plot.phase);
        if (normalizedPlotPhase != normalizedSelectedPhase) {
          return false;
        }
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

    _needsFilterUpdate = true;
    _notifySelective();
  }

  /// Optimized computed properties with caching
  List<String> get enabledPhasesForCurrentFilters {
    const cacheKey = 'enabled_phases';
    if (_computedCache.containsKey(cacheKey)) {
      return _computedCache[cacheKey];
    }
    
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
    
    _computedCache[cacheKey] = list;
    return list;
  }

  List<String> get enabledSizesForCurrentFilters {
    const cacheKey = 'enabled_sizes';
    if (_computedCache.containsKey(cacheKey)) {
      return _computedCache[cacheKey];
    }
    
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
    
    _computedCache[cacheKey] = list;
    return list;
  }

  // Public setters for the four primary filters - optimized
  void setPriceRange(RangeValues range) {
    if (_priceRange != range) {
      _priceRange = range;
      // Invalidate dependent selections if necessary
      if (_selectedPhase != null && !enabledPhasesForCurrentFilters.contains(_selectedPhase)) {
        _selectedPhase = null;
      }
      if (_selectedSize != null && !enabledSizesForCurrentFilters.contains(_selectedSize)) {
        _selectedSize = null;
      }
      _scheduleFilterUpdate();
    }
  }

  void setPlotType(String? type) {
    if (_selectedCategory != type) {
      _selectedCategory = type;
      if (_selectedPhase != null && !enabledPhasesForCurrentFilters.contains(_selectedPhase)) {
        _selectedPhase = null;
      }
      if (_selectedSize != null && !enabledSizesForCurrentFilters.contains(_selectedSize)) {
        _selectedSize = null;
      }
      _scheduleFilterUpdate();
    }
  }

  void setPhase(String? phase) {
    if (_selectedPhase != phase) {
      _selectedPhase = phase;
      if (_selectedSize != null && !enabledSizesForCurrentFilters.contains(_selectedSize)) {
        _selectedSize = null;
      }
      _scheduleFilterUpdate();
    }
  }

  void setPlotSize(String? size) {
    if (_selectedSize != size) {
      _selectedSize = size;
      _scheduleFilterUpdate();
    }
  }

  // Get plots by coordinates (for map markers)
  List<PlotModel> getPlotsWithCoordinates() {
    return _filteredPlots.where((plot) => 
      plot.latitude != null && plot.longitude != null
    ).toList();
  }

  // Get unique phases for filter dropdown - with caching
  List<String> get availablePhases {
    const cacheKey = 'available_phases';
    if (_computedCache.containsKey(cacheKey)) {
      return _computedCache[cacheKey];
    }
    
    final phases = _plots.map((plot) => plot.phase).toSet().toList();
    phases.sort();
    
    _computedCache[cacheKey] = phases;
    return phases;
  }

  // Get unique categories for filter dropdown - with caching
  List<String> get availableCategories {
    const cacheKey = 'available_categories';
    if (_computedCache.containsKey(cacheKey)) {
      return _computedCache[cacheKey];
    }
    
    final categories = _plots.map((plot) => plot.category).toSet().toList();
    categories.sort();
    
    _computedCache[cacheKey] = categories;
    return categories;
  }

  // Get unique statuses for filter dropdown - with caching
  List<String> get availableStatuses {
    const cacheKey = 'available_statuses';
    if (_computedCache.containsKey(cacheKey)) {
      return _computedCache[cacheKey];
    }
    
    final statuses = _plots.map((plot) => plot.status).toSet().toList();
    statuses.sort();
    
    _computedCache[cacheKey] = statuses;
    return statuses;
  }

  // Get unique areas for filter dropdown - with caching
  List<String> get availableAreas {
    const cacheKey = 'available_areas';
    if (_computedCache.containsKey(cacheKey)) {
      return _computedCache[cacheKey];
    }
    
    final areas = _plots.map((plot) => plot.catArea).toSet().toList();
    areas.sort();
    
    _computedCache[cacheKey] = areas;
    return areas;
  }

  // Get unique sectors for filter dropdown - with caching
  List<String> get availableSectors {
    const cacheKey = 'available_sectors';
    if (_computedCache.containsKey(cacheKey)) {
      return _computedCache[cacheKey];
    }
    
    final sectors = _plots.map((plot) => plot.sector).toSet().toList();
    sectors.sort();
    
    _computedCache[cacheKey] = sectors;
    return sectors;
  }

  // Get unique sizes for filter dropdown - with caching
  List<String> get availableSizes {
    const cacheKey = 'available_sizes';
    if (_computedCache.containsKey(cacheKey)) {
      return _computedCache[cacheKey];
    }
    
    final sizes = _plots.map((plot) => plot.catArea).toSet().toList();
    sizes.sort();
    
    _computedCache[cacheKey] = sizes;
    return sizes;
  }

  // Get price range for slider - with caching
  RangeValues get priceRangeBounds {
    const cacheKey = 'price_range_bounds';
    if (_computedCache.containsKey(cacheKey)) {
      return _computedCache[cacheKey];
    }
    
    if (_plots.isEmpty) {
      const result = RangeValues(0, 100000000);
      _computedCache[cacheKey] = result;
      return result;
    }
    
    final prices = _plots.map((plot) => double.tryParse(plot.basePrice) ?? 0).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final maxPrice = prices.reduce((a, b) => a > b ? a : b);
    
    final result = RangeValues(minPrice, maxPrice);
    _computedCache[cacheKey] = result;
    return result;
  }

  /// Normalize phase values for consistent comparison
  /// Handles variations like "Phase 1" vs "Phase1" vs "1"
  String _normalizePhaseValue(String phase) {
    if (phase.isEmpty) return phase;
    
    // Remove extra spaces and convert to lowercase for comparison
    final normalized = phase.trim().toLowerCase();
    
    // Handle common phase variations
    if (normalized.contains('phase')) {
      // Extract number from "Phase X" or "PhaseX"
      final match = RegExp(r'phase\s*(\d+)').firstMatch(normalized);
      if (match != null) {
        return 'phase${match.group(1)}';
      }
    }
    
    // Handle direct numbers like "1", "2"
    if (RegExp(r'^\d+$').hasMatch(normalized)) {
      return 'phase$normalized';
    }
    
    // Handle RVS variations
    if (normalized.contains('rvs')) {
      return 'rvs';
    }
    
    return normalized;
  }

  /// Debug method to log phase values from API
  void _debugPhaseValues() {
    if (_plots.isEmpty) return;
    
    final phaseValues = _plots.map((plot) => plot.phase).toSet().toList();
    phaseValues.sort();
    
    print('=== PHASE VALUES DEBUG ===');
    print('Available phases from API: $phaseValues');
    print('Selected phase: $_selectedPhase');
    if (_selectedPhase != null) {
      print('Normalized selected phase: ${_normalizePhaseValue(_selectedPhase!)}');
    }
    
    // Show sample plots for each phase
    for (final phase in phaseValues.take(5)) { // Show first 5 phases
      final plotsInPhase = _plots.where((plot) => plot.phase == phase).take(3);
      print('Phase "$phase" has ${_plots.where((plot) => plot.phase == phase).length} plots');
      for (final plot in plotsInPhase) {
        print('  - Plot ${plot.plotNo}: category=${plot.category}, status=${plot.status}');
      }
    }
    print('========================');
  }

  // Get plot statistics - with caching
  Map<String, int> get plotStatistics {
    const cacheKey = 'plot_statistics';
    if (_computedCache.containsKey(cacheKey)) {
      return _computedCache[cacheKey];
    }
    
    final stats = <String, int>{};
    
    for (final plot in _filteredPlots) {
      stats[plot.status] = (stats[plot.status] ?? 0) + 1;
    }
    
    _computedCache[cacheKey] = stats;
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
    _needsPlotUpdate = true;
    _needsFilterUpdate = true;
    _notifySelective();
  }
  
  /// Clear coordinate cache to free memory
  void clearCoordinateCache() {
    final cacheManager = CoordinateCacheManager();
    cacheManager.clearAllCache();
    print('OptimizedPlotsProvider: Cleared all coordinate caches');
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
    print('OptimizedPlotsProvider: Pre-cached coordinates for all ${_plots.length} plots');
  }

  /// Optimized selective notification
  void _notifySelective() {
    // Only notify if there are actual changes
    if (_needsPlotUpdate || _needsFilterUpdate) {
      notifyListeners();
      _needsPlotUpdate = false;
      _needsFilterUpdate = false;
    }
  }

  @override
  void dispose() {
    _filterDebounceTimer?.cancel();
    super.dispose();
  }
}
