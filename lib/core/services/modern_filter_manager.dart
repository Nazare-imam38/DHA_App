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
      _fetchFilteredPlots();
    });
  }

  /// Fetch filtered plots from API
  Future<void> _fetchFilteredPlots() async {
    try {
      _setLoading(true);
      _setError(null);

      print('ModernFilterManager: Fetching filtered plots...');
      print('ModernFilterManager: Filters - Price: $_minPrice-$_maxPrice, Category: $_category, Phase: $_phase, Size: $_size, Status: $_status, Sector: $_sector');

      final plots = await EnhancedPlotsApiService.fetchFilteredPlots(
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        category: _category,
        phase: _phase,
        size: _size,
        status: _status,
        sector: _sector,
      );

      _filteredPlots = plots;
      _lastFetchTime = DateTime.now();
      
      print('ModernFilterManager: ✅ Loaded ${plots.length} filtered plots');
      
      onPlotsUpdated?.call(plots);
    } catch (e) {
      print('ModernFilterManager: ❌ Error fetching filtered plots: $e');
      _setError(e.toString());
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
