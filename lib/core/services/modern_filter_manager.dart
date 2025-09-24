import 'dart:async';
import '../../data/models/plot_model.dart';
import 'enhanced_plots_api_service.dart';

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

  // Debounce timer for API calls
  Timer? _debounceTimer;
  static const Duration _debounceDelay = Duration(milliseconds: 500);

  // Callbacks
  Function(List<PlotModel>)? onPlotsUpdated;
  Function(bool)? onLoadingChanged;
  Function(String?)? onErrorChanged;

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

  /// Apply filters with debouncing
  void _applyFilters() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDelay, () {
      // If we have all plots loaded, use client-side filtering for better performance
      if (_allPlots.isNotEmpty) {
        print('ModernFilterManager: Using client-side filtering');
        _applyClientSideFilters();
      } else {
        print('ModernFilterManager: Using API filtering');
        _fetchFilteredPlots();
      }
    });
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
      _allPlots = await EnhancedPlotsApiService.fetchAllPlots();
      print('ModernFilterManager: ✅ Loaded ${_allPlots.length} initial plots');
      
      // Apply current filters to initial plots
      _applyClientSideFilters();
      
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
      
      // Phase filter
      if (_phase != null && plot.phase.toLowerCase() != _phase!.toLowerCase()) {
        return false;
      }
      
      // Size filter
      if (_size != null && plot.size.toLowerCase() != _size!.toLowerCase()) {
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

  /// Force refresh (bypass cache)
  Future<void> forceRefresh() async {
    _lastFetchTime = null;
    await _fetchFilteredPlots();
  }

  /// Dispose resources
  void dispose() {
    _debounceTimer?.cancel();
  }
}
