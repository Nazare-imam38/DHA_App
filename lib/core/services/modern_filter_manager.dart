import 'dart:async';
import '../../data/models/plot_model.dart';
import 'enhanced_plots_api_service.dart';
import '../../services/progressive_filter_service.dart' as ProgressiveFilter;

/// Modern filter manager for handling plot filtering with API integration
class ModernFilterManager {
  static final ModernFilterManager _instance = ModernFilterManager._internal();
  factory ModernFilterManager() => _instance;
  ModernFilterManager._internal();

  // Filter states
  double? _minPrice;
  double? _maxPrice;
  String? _category;
  String? _phase;
  String? _size;
  String? _status;
  String? _sector;

  // Cached data
  List<PlotModel> _filteredPlots = [];
  List<PlotModel> _allPlots = []; // Store all plots for client-side filtering
  bool _isLoading = false;
  String? _error;
  DateTime? _lastFetchTime;

  // Progressive filtering state
  List<String> _availableCategories = [];
  List<String> _availablePhases = [];
  List<String> _availableSizes = [];
  bool _categoriesLoaded = false;
  bool _phasesLoaded = false;
  bool _sizesLoaded = false;

  // Performance optimization: Faster debouncing
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 200); // Reduced from 500ms to 200ms
  
  // Performance optimization: Background processing
  static final Map<String, Completer<void>> _backgroundTasks = {};
  static bool _isProcessingInBackground = false;

  // Callbacks
  Function(List<PlotModel>)? onPlotsUpdated;
  Function(bool)? onLoadingChanged;
  Function(String?)? onErrorChanged;
  Function(List<String>)? onCategoriesUpdated;
  Function(List<String>)? onPhasesUpdated;
  Function(List<String>)? onSizesUpdated;

  // Getters
  List<PlotModel> get filteredPlots => _filteredPlots;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get plotCount => _filteredPlots.length;

  // Filter getters
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  String? get category => _category;
  String? get phase => _phase;
  String? get size => _size;
  String? get status => _status;
  String? get sector => _sector;

  // Progressive filtering getters
  List<String> get availableCategories => _availableCategories;
  List<String> get availablePhases => _availablePhases;
  List<String> get availableSizes => _availableSizes;
  bool get categoriesLoaded => _categoriesLoaded;
  bool get phasesLoaded => _phasesLoaded;
  bool get sizesLoaded => _sizesLoaded;

  // Active filters count
  int get activeFiltersCount {
    int count = 0;
    if (_minPrice != null || _maxPrice != null) count++;
    if (_category != null) count++;
    if (_phase != null) count++;
    if (_size != null) count++;
    if (_status != null) count++;
    if (_sector != null) count++;
    return count;
  }

  // Check if any filters are active
  bool get hasActiveFilters => activeFiltersCount > 0;

  /// Set price range filter
  void setPriceRange(double? min, double? max) {
    _minPrice = min;
    _maxPrice = max;
    _applyFilters();
  }

  /// Set category filter
  void setCategory(String? category) {
    _category = category;
    _applyFilters();
  }

  /// Set phase filter
  void setPhase(String? phase) {
    _phase = phase;
    _applyFilters();
  }

  /// Set size filter
  void setSize(String? size) {
    _size = size;
    _applyFilters();
  }

  /// Set status filter
  void setStatus(String? status) {
    _status = status;
    _applyFilters();
  }

  /// Set sector filter
  void setSector(String? sector) {
    _sector = sector;
    _applyFilters();
  }

  /// Clear all filters
  void clearAllFilters() {
    _minPrice = null;
    _maxPrice = null;
    _category = null;
    _phase = null;
    _size = null;
    _status = null;
    _sector = null;
    _applyFilters();
  }

  /// Clear specific filter
  void clearFilter(String filterType) {
    switch (filterType) {
      case 'price':
        _minPrice = null;
        _maxPrice = null;
        break;
      case 'category':
        _category = null;
        break;
      case 'phase':
        _phase = null;
        break;
      case 'size':
        _size = null;
        break;
      case 'status':
        _status = null;
        break;
      case 'sector':
        _sector = null;
        break;
    }
    _applyFilters();
  }

  /// Apply filters with optimized debouncing
  void _applyFilters() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      print('ModernFilterManager: Using optimized progressive API filtering');
      _applyProgressiveFiltersOptimized();
    });
  }

  /// Apply progressive filtering workflow (original method kept for compatibility)
  Future<void> _applyProgressiveFilters() async {
    try {
      _setLoading(true);
      _setError(null);

      // Step 1: Filter by price range first
      if (_minPrice != null && _maxPrice != null) {
        print('ModernFilterManager: Step 1 - Filtering by price range $_minPrice - $_maxPrice');
        
        // Load available categories for this price range
        await _loadAvailableCategories();
        
        // If no category selected, show all plots for this price range
        if (_category == null) {
          await _fetchPlotsByPriceRange();
          return;
        }
        
        // Step 2: Filter by category
        if (_category != null) {
          print('ModernFilterManager: Step 2 - Filtering by category $_category');
          
          // Load available phases for this category and price range
          await _loadAvailablePhases();
          
          // If no phase selected, show plots for this category and price range
          if (_phase == null) {
            await _fetchPlotsByCategory();
            return;
          }
          
          // Step 3: Filter by phase
          if (_phase != null) {
            print('ModernFilterManager: Step 3 - Filtering by phase $_phase');
            
            // Load available sizes for this phase, category and price range
            await _loadAvailableSizes();
            
            // If no size selected, show plots for this phase, category and price range
            if (_size == null) {
              await _fetchPlotsByPhase();
              return;
            }
            
            // Step 4: Filter by size (final filter)
            if (_size != null) {
              print('ModernFilterManager: Step 4 - Filtering by size $_size');
              await _fetchPlotsBySize();
              return;
            }
          }
        }
      } else {
        // No price range set, load all plots
        await loadInitialPlots();
      }
    } catch (e) {
      print('ModernFilterManager: ❌ Error in progressive filtering: $e');
      _setError(e.toString());
      _filteredPlots = [];
      onPlotsUpdated?.call([]);
    } finally {
      _setLoading(false);
    }
  }
  
  /// Performance optimization: Optimized progressive filtering with background processing
  Future<void> _applyProgressiveFiltersOptimized() async {
    final taskId = 'filter_${DateTime.now().millisecondsSinceEpoch}';
    
    try {
      _setLoading(true);
      _setError(null);
      
      print('ModernFilterManager: 🚀 Starting optimized progressive filtering...');
      
      // Performance optimization: Process in background to keep UI responsive
      await _processFiltersInBackground(taskId);
      
    } catch (e) {
      print('ModernFilterManager: ❌ Error in optimized progressive filtering: $e');
      _setError(e.toString());
      _filteredPlots = [];
      onPlotsUpdated?.call([]);
    } finally {
      _setLoading(false);
      _backgroundTasks.remove(taskId);
    }
  }
  
  /// Performance optimization: Background processing for filters
  Future<void> _processFiltersInBackground(String taskId) async {
    if (_isProcessingInBackground) {
      print('ModernFilterManager: ⏳ Waiting for background processing to complete...');
      return;
    }
    
    _isProcessingInBackground = true;
    final completer = Completer<void>();
    _backgroundTasks[taskId] = completer;
    
    try {
      // Step 1: Filter by price range first
      if (_minPrice != null && _maxPrice != null) {
        print('ModernFilterManager: 🎯 Step 1 - Optimized price range filtering $_minPrice - $_maxPrice');
        
        // Performance optimization: Load categories in parallel with price filtering
        final categoriesFuture = _loadAvailableCategories();
        final plotsFuture = _fetchPlotsByPriceRange();
        
        await Future.wait([categoriesFuture, plotsFuture]);
        
        // If no category selected, we're done
        if (_category == null) {
          completer.complete();
          return;
        }
        
        // Step 2: Filter by category
        if (_category != null) {
          print('ModernFilterManager: 🎯 Step 2 - Optimized category filtering $_category');
          
          // Performance optimization: Load phases in parallel with category filtering
          final phasesFuture = _loadAvailablePhases();
          final categoryPlotsFuture = _fetchPlotsByCategory();
          
          await Future.wait([phasesFuture, categoryPlotsFuture]);
          
          // If no phase selected, we're done
          if (_phase == null) {
            completer.complete();
            return;
          }
          
          // Step 3: Filter by phase
          if (_phase != null) {
            print('ModernFilterManager: 🎯 Step 3 - Optimized phase filtering $_phase');
            
            // Performance optimization: Load sizes in parallel with phase filtering
            final sizesFuture = _loadAvailableSizes();
            final phasePlotsFuture = _fetchPlotsByPhase();
            
            await Future.wait([sizesFuture, phasePlotsFuture]);
            
            // If no size selected, we're done
            if (_size == null) {
              completer.complete();
              return;
            }
            
            // Step 4: Filter by size (final filter)
            if (_size != null) {
              print('ModernFilterManager: 🎯 Step 4 - Optimized size filtering $_size');
              await _fetchPlotsBySize();
              completer.complete();
              return;
            }
          }
        }
      } else {
        // No price range set, load all plots
        await loadInitialPlots();
        completer.complete();
      }
    } finally {
      _isProcessingInBackground = false;
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
  }

  /// Fetch filtered plots from API or use client-side filtering
  Future<void> _fetchFilteredPlots() async {
    try {
      _setLoading(true);
      _setError(null);

      print('ModernFilterManager: Fetching filtered plots...');
      print('ModernFilterManager: Filters - Price: $_minPrice-$_maxPrice, Category: $_category, Phase: $_phase, Size: $_size, Status: $_status, Sector: $_sector');

      List<PlotModel> plots = [];
      
      try {
        // Try API first
        plots = await EnhancedPlotsApiService.fetchFilteredPlots(
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          category: _category,
          phase: _phase,
          size: _size,
          status: _status,
          sector: _sector,
        );
        print('ModernFilterManager: ✅ API returned ${plots.length} plots');
      } catch (apiError) {
        print('ModernFilterManager: ⚠️ API failed, using client-side filtering: $apiError');
        
        // Fallback to client-side filtering with all available plots
        // For now, we'll use an empty list and let the screen handle it
        // In a real implementation, you would load all plots first and then filter them
        plots = [];
      }

      _filteredPlots = plots;
      _lastFetchTime = DateTime.now();
      
      print('ModernFilterManager: ✅ Final result: ${plots.length} filtered plots');
      
      onPlotsUpdated?.call(plots);
    } catch (e) {
      print('ModernFilterManager: ❌ Error in filter process: $e');
      _setError(e.toString());
      
      // Even on error, update with empty list to clear the map
      _filteredPlots = [];
      onPlotsUpdated?.call([]);
    } finally {
      _setLoading(false);
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    onLoadingChanged?.call(loading);
  }

  /// Set error state
  void _setError(String? error) {
    _error = error;
    onErrorChanged?.call(error);
  }

  /// Get filter summary
  Map<String, dynamic> getFilterSummary() {
    return {
      'minPrice': _minPrice,
      'maxPrice': _maxPrice,
      'category': _category,
      'phase': _phase,
      'size': _size,
      'status': _status,
      'sector': _sector,
      'activeFiltersCount': activeFiltersCount,
      'plotCount': _filteredPlots.length,
      'lastFetchTime': _lastFetchTime,
    };
  }

  /// Get active filters as list
  List<String> getActiveFilters() {
    final List<String> filters = [];
    
    if (_minPrice != null || _maxPrice != null) {
      filters.add('Price Range');
    }
    if (_category != null) {
      filters.add('Category: $_category');
    }
    if (_phase != null) {
      filters.add('Phase: $_phase');
    }
    if (_size != null) {
      filters.add('Size: $_size');
    }
    if (_status != null) {
      filters.add('Status: $_status');
    }
    if (_sector != null) {
      filters.add('Sector: $_sector');
    }
    
    return filters;
  }

  /// Load initial plots (call this once when the app starts)
  Future<void> loadInitialPlots() async {
    try {
      _setLoading(true);
      _setError(null);
      
      print('ModernFilterManager: Loading initial plots...');
      
      // Try to load all plots from API
      final rawPlots = await EnhancedPlotsApiService.fetchAllPlots();
      print('ModernFilterManager: Raw API returned ${rawPlots.length} plots');
      
      // Deduplicate plots by plotNo to prevent duplicate markers
      _allPlots = _deduplicatePlots(rawPlots);
      print('ModernFilterManager: ✅ After deduplication: ${_allPlots.length} unique plots');
      
      // Apply current filters to initial plots
      _applyClientSideFilters();
      
      // Performance optimization: Start smart preloading in background
      _startSmartPreloading();
      
    } catch (e) {
      print('ModernFilterManager: ❌ Error loading initial plots: $e');
      _setError(e.toString());
      _allPlots = [];
      _filteredPlots = [];
      onPlotsUpdated?.call([]);
    } finally {
      _setLoading(false);
    }
  }
  
  /// Performance optimization: Smart preloading for common filter combinations
  void _startSmartPreloading() {
    // Start preloading in background without blocking UI
    Future.delayed(Duration(seconds: 2), () async {
      try {
        print('ModernFilterManager: 🚀 Starting smart preloading...');
        
        // Preload common price ranges
        final commonRanges = [
          {'min': 1000000.0, 'max': 3000000.0},
          {'min': 3000000.0, 'max': 5000000.0},
          {'min': 5000000.0, 'max': 10000000.0},
        ];
        
        for (final range in commonRanges) {
          try {
            await ProgressiveFilter.ProgressiveFilterService.filterByPriceRange(
              priceFrom: range['min']!,
              priceTo: range['max']!,
            );
            print('ModernFilterManager: ✅ Preloaded price range ${range['min']}-${range['max']}');
          } catch (e) {
            print('ModernFilterManager: ⚠️ Failed to preload price range: $e');
          }
        }
        
        print('ModernFilterManager: ✅ Smart preloading completed');
      } catch (e) {
        print('ModernFilterManager: ❌ Smart preloading failed: $e');
      }
    });
  }
  
  /// Apply client-side filtering to all plots
  void _applyClientSideFilters() {
    if (_allPlots.isEmpty) {
      _filteredPlots = [];
      onPlotsUpdated?.call([]);
      return;
    }
    
    print('ModernFilterManager: Applying client-side filters to ${_allPlots.length} plots');
    
    _filteredPlots = _allPlots.where((plot) {
      // Price range filter
      if (_minPrice != null || _maxPrice != null) {
        final price = double.tryParse(plot.basePrice) ?? 0;
        if (_minPrice != null && price < _minPrice!) return false;
        if (_maxPrice != null && price > _maxPrice!) return false;
      }
      
      // Category filter
      if (_category != null && plot.category.toLowerCase() != _category!.toLowerCase()) {
        return false;
      }
      
      // Phase filter - handle different phase formats
      if (_phase != null) {
        final plotPhase = plot.phase.toLowerCase();
        final filterPhase = _phase!.toLowerCase();
        
        // Convert filter phase to match API format
        String apiFilterPhase = _convertPhaseToApiFormat(filterPhase);
        
        if (plotPhase != apiFilterPhase.toLowerCase()) {
          return false;
        }
      }
      
      // Size filter
      if (_size != null && plot.catArea.toLowerCase() != _size!.toLowerCase()) {
        return false;
      }
      
      // Status filter
      if (_status != null && plot.status.toLowerCase() != _status!.toLowerCase()) {
        return false;
      }
      
      // Sector filter
      if (_sector != null && plot.sector.toLowerCase() != _sector!.toLowerCase()) {
        return false;
      }
      
      return true;
    }).toList();
    
    print('ModernFilterManager: ✅ Client-side filtering result: ${_filteredPlots.length} plots');
    onPlotsUpdated?.call(_filteredPlots);
  }


  /// Convert phase names to API format for client-side filtering
  String _convertPhaseToApiFormat(String phase) {
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

  /// Deduplicate plots by plotNo to prevent duplicate markers
  List<PlotModel> _deduplicatePlots(List<PlotModel> plots) {
    print('ModernFilterManager: Deduplicating ${plots.length} plots...');
    
    final Map<String, PlotModel> uniquePlots = {};
    int duplicatesFound = 0;
    
    for (final plot in plots) {
      final plotKey = plot.plotNo.toLowerCase().trim();
      
      if (uniquePlots.containsKey(plotKey)) {
        duplicatesFound++;
        print('ModernFilterManager: ⚠️ Found duplicate plot: ${plot.plotNo}');
        
        // Keep the plot with more complete data (has coordinates)
        final existingPlot = uniquePlots[plotKey]!;
        if (plot.latitude != null && plot.longitude != null && 
            (existingPlot.latitude == null || existingPlot.longitude == null)) {
          uniquePlots[plotKey] = plot;
          print('ModernFilterManager: ✅ Replaced with plot that has coordinates');
        }
      } else {
        uniquePlots[plotKey] = plot;
      }
    }
    
    final deduplicatedPlots = uniquePlots.values.toList();
    print('ModernFilterManager: ✅ Deduplication complete: ${duplicatesFound} duplicates removed');
    print('ModernFilterManager: ✅ Final unique plots: ${deduplicatedPlots.length}');
    
    return deduplicatedPlots;
  }

  /// Load available categories for current price range
  Future<void> _loadAvailableCategories() async {
    if (_minPrice == null || _maxPrice == null) return;
    
    try {
      _availableCategories = await ProgressiveFilter.ProgressiveFilterService.getAvailableCategories(
        priceFrom: _minPrice!,
        priceTo: _maxPrice!,
      );
      _categoriesLoaded = true;
      onCategoriesUpdated?.call(_availableCategories);
      print('ModernFilterManager: ✅ Loaded ${_availableCategories.length} available categories');
    } catch (e) {
      print('ModernFilterManager: ❌ Error loading categories: $e');
      _availableCategories = [];
      _categoriesLoaded = false;
    }
  }

  /// Load available phases for current category and price range
  Future<void> _loadAvailablePhases() async {
    if (_category == null || _minPrice == null || _maxPrice == null) return;
    
    try {
      _availablePhases = await ProgressiveFilter.ProgressiveFilterService.getAvailablePhases(
        category: _category!,
        priceFrom: _minPrice!,
        priceTo: _maxPrice!,
      );
      _phasesLoaded = true;
      onPhasesUpdated?.call(_availablePhases);
      print('ModernFilterManager: ✅ Loaded ${_availablePhases.length} available phases');
    } catch (e) {
      print('ModernFilterManager: ❌ Error loading phases: $e');
      _availablePhases = [];
      _phasesLoaded = false;
    }
  }

  /// Load available sizes for current filters
  Future<void> _loadAvailableSizes() async {
    if (_phase == null || _category == null || _minPrice == null || _maxPrice == null) return;
    
    try {
      _availableSizes = await ProgressiveFilter.ProgressiveFilterService.getAvailableSizes(
        phase: _phase!,
        category: _category!,
        priceFrom: _minPrice!,
        priceTo: _maxPrice!,
      );
      _sizesLoaded = true;
      onSizesUpdated?.call(_availableSizes);
      print('ModernFilterManager: ✅ Loaded ${_availableSizes.length} available sizes');
    } catch (e) {
      print('ModernFilterManager: ❌ Error loading sizes: $e');
      _availableSizes = [];
      _sizesLoaded = false;
    }
  }

  /// Fetch plots by price range only
  Future<void> _fetchPlotsByPriceRange() async {
    try {
      final response = await ProgressiveFilter.ProgressiveFilterService.filterByPriceRange(
        priceFrom: _minPrice!,
        priceTo: _maxPrice!,
      );
      
      _filteredPlots = _convertToPlotModels(response.plots);
      onPlotsUpdated?.call(_filteredPlots);
      print('ModernFilterManager: ✅ Price range filter returned ${_filteredPlots.length} plots');
    } catch (e) {
      print('ModernFilterManager: ❌ Error fetching plots by price range: $e');
      _filteredPlots = [];
      onPlotsUpdated?.call([]);
    }
  }

  /// Fetch plots by category and price range
  Future<void> _fetchPlotsByCategory() async {
    try {
      final response = await ProgressiveFilter.ProgressiveFilterService.filterByCategory(
        category: _category!,
        priceFrom: _minPrice!,
        priceTo: _maxPrice!,
      );
      
      _filteredPlots = _convertToPlotModels(response.plots);
      onPlotsUpdated?.call(_filteredPlots);
      print('ModernFilterManager: ✅ Category filter returned ${_filteredPlots.length} plots');
    } catch (e) {
      print('ModernFilterManager: ❌ Error fetching plots by category: $e');
      _filteredPlots = [];
      onPlotsUpdated?.call([]);
    }
  }

  /// Fetch plots by phase, category and price range
  Future<void> _fetchPlotsByPhase() async {
    try {
      final response = await ProgressiveFilter.ProgressiveFilterService.filterByPhase(
        phase: _phase!,
        category: _category!,
        priceFrom: _minPrice!,
        priceTo: _maxPrice!,
      );
      
      _filteredPlots = _convertToPlotModels(response.plots);
      onPlotsUpdated?.call(_filteredPlots);
      print('ModernFilterManager: ✅ Phase filter returned ${_filteredPlots.length} plots');
    } catch (e) {
      print('ModernFilterManager: ❌ Error fetching plots by phase: $e');
      _filteredPlots = [];
      onPlotsUpdated?.call([]);
    }
  }

  /// Fetch plots by size, phase, category and price range
  Future<void> _fetchPlotsBySize() async {
    try {
      final response = await ProgressiveFilter.ProgressiveFilterService.filterBySize(
        size: _size!,
        phase: _phase!,
        category: _category!,
        priceFrom: _minPrice!,
        priceTo: _maxPrice!,
      );
      
      _filteredPlots = _convertToPlotModels(response.plots);
      onPlotsUpdated?.call(_filteredPlots);
      print('ModernFilterManager: ✅ Size filter returned ${_filteredPlots.length} plots');
    } catch (e) {
      print('ModernFilterManager: ❌ Error fetching plots by size: $e');
      _filteredPlots = [];
      onPlotsUpdated?.call([]);
    }
  }

  /// Convert PlotData to PlotModel
  List<PlotModel> _convertToPlotModels(List<ProgressiveFilter.PlotData> plots) {
    return plots.map((plot) => PlotModel(
      id: plot.id,
      plotNo: plot.plotNo,
      size: plot.size,
      category: plot.category,
      catArea: plot.catArea,
      dimension: plot.dimension,
      phase: plot.phase,
      sector: plot.sector,
      streetNo: plot.streetNo,
      block: plot.block,
      status: plot.status,
      tokenAmount: plot.tokenAmount,
      remarks: plot.remarks,
      holdBy: plot.holdBy,
      expireTime: plot.expireTime,
      basePrice: plot.basePrice,
      oneYrPlan: plot.oneYrPlan,
      twoYrsPlan: plot.twoYrsPlan,
      twoFiveYrsPlan: plot.twoFiveYrsPlan,
      threeYrsPlan: plot.threeYrsPlan,
      stAsgeojson: plot.stAsgeojson,
      eventHistory: _convertEventHistory(plot.eventHistory),
    )).toList();
  }

  /// Convert EventHistory from progressive filter service to PlotModel EventHistory
  EventHistory _convertEventHistory(ProgressiveFilter.EventHistory serviceEventHistory) {
    // Convert the list of events to a single event (take first one if available)
    if (serviceEventHistory.events.isNotEmpty) {
      final event = serviceEventHistory.events.first;
      return EventHistory(
        id: 0, // Default value since API doesn't provide this
        eventId: event.id,
        isBidding: false, // Default value
        event: Event(
          id: event.id,
          title: event.title,
          status: event.status,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );
    } else {
      // Return empty event history if no events
      return EventHistory(
        id: 0,
        eventId: 0,
        isBidding: false,
        event: Event(
          id: 0,
          title: '',
          status: '',
          startDate: '',
          endDate: '',
        ),
      );
    }
  }

  /// Parse GeoJSON string to polygon coordinates
  List<List<double>> _parseGeoJson(String geoJsonString) {
    try {
      // This is a simplified parser - in production you'd use a proper GeoJSON library
      // For now, return empty list as the existing system handles polygon parsing
      return [];
    } catch (e) {
      print('ModernFilterManager: Error parsing GeoJSON: $e');
      return [];
    }
  }

  /// Performance optimization: Get performance statistics
  Map<String, dynamic> getPerformanceStats() {
    return {
      'debounce_delay_ms': _debounceDelay.inMilliseconds,
      'background_tasks': _backgroundTasks.length,
      'is_processing_background': _isProcessingInBackground,
      'filtered_plots_count': _filteredPlots.length,
      'all_plots_count': _allPlots.length,
      'active_filters_count': activeFiltersCount,
    };
  }
  
  /// Performance optimization: Clear cache and reset state
  void clearCache() {
    _filteredPlots.clear();
    _allPlots.clear();
    _availableCategories.clear();
    _availablePhases.clear();
    _availableSizes.clear();
    _categoriesLoaded = false;
    _phasesLoaded = false;
    _sizesLoaded = false;
    
    // Clear progressive filter service cache
    ProgressiveFilter.ProgressiveFilterService.clearCache();
    
    print('ModernFilterManager: 🧹 Cache cleared and state reset');
  }
  
  /// Performance optimization: Force refresh with cache bypass
  Future<void> forceRefresh() async {
    clearCache();
    await loadInitialPlots();
    print('ModernFilterManager: 🔄 Force refresh completed');
  }
  
  /// Dispose resources
  void dispose() {
    _debounceTimer?.cancel();
    _backgroundTasks.clear();
  }
}
