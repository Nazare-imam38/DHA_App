import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../l10n/app_localizations.dart';
import '../services/language_service.dart';
import '../providers/plots_provider.dart';
import '../data/models/plot_model.dart';
import '../data/monuments_data.dart';
import '../core/services/polygon_renderer_service.dart';
import '../core/services/enhanced_polygon_service.dart';
import '../ui/widgets/enhanced_plot_info_card.dart';
import '../ui/widgets/small_plot_info_card.dart';
import '../ui/widgets/selected_plot_details_widget.dart';
import '../ui/widgets/plot_details_modal.dart';
import '../ui/screens/auth/login_screen.dart';
import '../core/services/instant_boundary_service.dart' as boundary;
import '../core/services/optimized_boundary_service.dart';
import '../core/services/optimized_plots_cache.dart';
import '../core/services/optimized_tile_cache.dart';
// import '../core/services/enhanced_startup_preloader.dart';
import '../core/services/unified_cache_manager.dart';
import '../core/services/plots_api_service.dart';
import '../core/services/enhanced_plots_api_service.dart';
import '../core/services/modern_filter_manager.dart';
import '../core/services/amenities_geojson_service.dart' as geojson;
import '../core/services/app_initialization_service.dart';
import '../core/services/plot_selection_handler.dart';
import 'sidebar_drawer.dart';
import '../ui/widgets/modern_filters_panel.dart';
import '../ui/widgets/rectangular_toggle_button.dart';
import '../ui/widgets/selected_plot_details_widget.dart';
import '../ui/widgets/plot_details_popup.dart';
import '../ui/widgets/dha_loading_widget.dart';
import '../data/models/plot_details_model.dart';
import '../core/services/plot_details_service.dart';
import '../core/services/optimized_map_renderer.dart' as renderer;

/// Model class for amenity markers
class AmenityMarker {
  final Marker marker;
  final String amenityType;
  final String phase;
  final LatLng point;

  AmenityMarker({
    required this.marker,
    required this.amenityType,
    required this.phase,
    required this.point,
  });
}

/// Instant loading version of ProjectsScreen that shows map and UI immediately
/// while data loads in the background to eliminate white screen flash
class ProjectsScreenInstant extends StatefulWidget {
  const ProjectsScreenInstant({super.key});

  @override
  State<ProjectsScreenInstant> createState() => _ProjectsScreenInstantState();
}

class _ProjectsScreenInstantState extends State<ProjectsScreenInstant>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _selectedFilter = 'All';
  String _selectedPhase = 'All Phases';
  String _selectedView = 'Satellite'; // Satellite, Street, Hybrid
  bool _showFilters = false;
  bool _showProjectDetails = false;
  bool _isDataLoading = false; // Changed from _isLoading to be more specific
  
  // Bottom sheet state
  bool _isBottomSheetExpanded = false;
  bool _isBottomSheetVisible = false; // Controls visibility based on filters
  final DraggableScrollableController _bottomSheetController = DraggableScrollableController();
  bool _isBottomSheetInitialized = false;
  
  // Plot polygon visibility
  bool _showPlotPolygons = true; // Always show plot polygons
  
  // Filter states
  String? _selectedEvent;
  RangeValues _priceRange = const RangeValues(0, 10000000);
  String? _selectedPlotType;
  String? _selectedDhaPhase;
  String? _selectedPlotSize;
  String? _selectedSector;
  String? _selectedStatus;
  RangeValues _tokenAmountRange = const RangeValues(0, 1000000);
  bool _hasInstallmentPlans = false;
  bool _isAvailableOnly = false;
  bool _hasRemarks = false;
  
  // Search states
  final TextEditingController _plotIdController = TextEditingController();
  
  // Active filters list
  List<String> _activeFilters = [];
  
  // Expanded sections
  bool _isEventExpanded = false;
  bool _isPriceRangeExpanded = false;
  bool _isPlotTypeExpanded = false;
  bool _isDhaPhaseExpanded = false;
  bool _isPlotSizeExpanded = true; // Plot Size is expanded by default
  
  final List<String> _filters = ['All', 'Available', 'Reserved', 'Unsold', 'Sold'];
  final List<String> _viewTypes = ['Satellite', 'Street', 'Hybrid'];
  
  // Filter options
  final List<String> _events = ['Event 1', 'Event 2', 'Event 3'];
  final List<String> _plotTypes = ['Residential', 'Commercial', 'Agricultural'];
  final List<String> _dhaPhases = ['RVS', 'Phase 1', 'Phase 2', 'Phase 3', 'Phase 4'];
  final List<String> _plotSizes = ['3 Marla', '5 Marla', '7 Marla', '10 Marla', '1 Kanal'];
  
  // Map related variables
  LatLng _mapCenter = const LatLng(33.6844, 73.0479); // Islamabad/Rawalpindi coordinates
  double _zoom = 14.0; // Increased zoom for better satellite view
  MapController _mapController = MapController();
  
  // Selected plot for details
  PlotModel? _selectedPlot;
  
  // Selected plot details
  PlotDetailsModel? _selectedPlotDetails;
  bool _showSelectedPlotDetails = false;
  bool _isLoadingPlotDetails = false;
  
  // Plot data
  List<PlotModel> _plots = [];
  
  // Modern filter manager
  final ModernFilterManager _filterManager = ModernFilterManager();
  
  // Boundary polygons
  List<boundary.BoundaryPolygon> _boundaryPolygons = [];
  bool _isLoadingBoundaries = true;
  bool _showBoundaries = true;
  
  // Amenities markers
  List<AmenityMarker> _amenitiesMarkers = [];
  List<geojson.AmenityFeature> _amenitiesFeatures = [];
  bool _isLoadingAmenities = false; // Changed to false - will load on demand
  bool _showAmenities = true;
  bool _amenitiesLoaded = false; // Track if amenities have been loaded
  bool _showMapControls = false; // Controls the expanded state of map controls
  AmenityMarker? _selectedAmenity;
  
  // Legend visibility states
  bool _showAmenitiesLegend = true;
  bool _showPhaseBoundariesLegend = true;
  bool _showTownPlanLegend = true;
  
  // Town plan overlay
  bool _showTownPlan = false;
  String _selectedTownPlanLayer = 'phase1'; // Default to Phase 1
  
  // Performance optimization
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeLocation();
    _updateActiveFilters();
    _initializeFilterManager();
    // Start data loading in background without blocking UI
    _initializeDataLoadingAsync();
    // Center map on phase boundaries after initialization
    _centerMapOnPhaseBoundaries();
  }

  /// Initialize modern filter manager
  void _initializeFilterManager() {
    _filterManager.onPlotsUpdated = (plots) {
      setState(() {
        _plots = plots;
        print('✅ Filter Manager: Updated plots count to ${plots.length}');
        
        // Debug: Check if plots have polygon coordinates
        if (plots.isNotEmpty) {
          final plotsWithPolygons = plots.where((plot) => plot.polygonCoordinates.isNotEmpty).toList();
          print('📊 Plots with valid polygons: ${plotsWithPolygons.length}/${plots.length}');
          
          if (plotsWithPolygons.isNotEmpty) {
            print('📍 First plot with polygons: ${plotsWithPolygons.first.plotNo}');
            print('📍 Polygon count: ${plotsWithPolygons.first.polygonCoordinates.length}');
          }
        }
      });
    };
    
    _filterManager.onLoadingChanged = (isLoading) {
      setState(() {
        _isDataLoading = isLoading;
      });
    };
    
    _filterManager.onErrorChanged = (error) {
      if (error != null) {
        print('Filter Manager Error: $error');
      }
    };

    // Progressive filtering callbacks
    _filterManager.onCategoriesUpdated = (categories) {
      print('✅ Filter Manager: Available categories updated: $categories');
      // Update the filter panel with available categories
      _updateFilterPanelCategories(categories);
    };

    _filterManager.onPhasesUpdated = (phases) {
      print('✅ Filter Manager: Available phases updated: $phases');
      // Update the filter panel with available phases
      _updateFilterPanelPhases(phases);
    };

    _filterManager.onSizesUpdated = (sizes) {
      print('✅ Filter Manager: Available sizes updated: $sizes');
      // Update the filter panel with available sizes
      _updateFilterPanelSizes(sizes);
    };
    
    // Load initial plots
    _loadInitialPlots();
  }
  
  /// Load initial plots for filtering
  Future<void> _loadInitialPlots() async {
    try {
      print('Loading initial plots for filtering...');
      await _filterManager.loadInitialPlots();
      print('✅ Initial plots loaded successfully');
    } catch (e) {
      print('❌ Error loading initial plots: $e');
    }
  }

  /// Update filter panel with available categories
  void _updateFilterPanelCategories(List<String> categories) {
    // This will be called when the filter panel is created
    // The actual update will happen in the filter panel widget
    print('📊 Available categories for filter panel: $categories');
  }

  /// Update filter panel with available phases
  void _updateFilterPanelPhases(List<String> phases) {
    // This will be called when the filter panel is created
    // The actual update will happen in the filter panel widget
    print('📊 Available phases for filter panel: $phases');
  }

  /// Update filter panel with available sizes
  void _updateFilterPanelSizes(List<String> sizes) {
    // This will be called when the filter panel is created
    // The actual update will happen in the filter panel widget
    print('📊 Available sizes for filter panel: $sizes');
  }

  /// Apply filters to modern filter manager
  void _applyFiltersToManager(Map<String, dynamic> filters) {
    // Apply price range
    final priceRange = filters['priceRange'] as RangeValues?;
    if (priceRange != null) {
      _filterManager.setPriceRange(priceRange.start, priceRange.end);
    }

    // Apply plot type
    final plotType = filters['plotType'] as String?;
    _filterManager.setCategory(plotType);

    // Apply DHA phase
    final dhaPhase = filters['dhaPhase'] as String?;
    _filterManager.setPhase(dhaPhase);

    // Apply plot size
    final plotSize = filters['plotSize'] as String?;
    _filterManager.setSize(plotSize);

    print('Modern Filter Manager: Applied filters - Price: ${priceRange?.start}-${priceRange?.end}, Type: $plotType, Phase: $dhaPhase, Size: $plotSize');
    
    // Update bottom sheet visibility based on active filters
    _updateBottomSheetVisibility();
    
    // The filter manager will automatically update _plots through the callback
    // No need to navigate immediately - let the polygons update first
    print('✅ Filters applied - Plot polygons will update automatically');
  }

  /// Update bottom sheet visibility based on active filters
  void _updateBottomSheetVisibility() {
    final hasActiveFilters = _activeFilters.isNotEmpty && 
                            _activeFilters.first != 'All Plots' &&
                            (_selectedPlotType != null || 
                             _selectedDhaPhase != null || 
                             _selectedPlotSize != null ||
                             _priceRange.start > 0 || 
                             _priceRange.end < 10000000);
    
    setState(() {
      _isBottomSheetVisible = hasActiveFilters;
      _showPlotPolygons = true; // Always show plot polygons when filters are applied
    });
    
    print('Bottom sheet visibility: $_isBottomSheetVisible (Active filters: ${_activeFilters.length})');
    print('Plot polygons visibility: $_showPlotPolygons');
  }

  /// Navigate to a specific plot on the map
  void _navigateToPlot(PlotModel plot) {
    try {
      print('🧭 Navigating to plot ${plot.plotNo}');
      
      // Use polygon coordinates for accurate navigation if available
      if (plot.polygonCoordinates.isNotEmpty) {
        print('🧭 Using polygon coordinates for navigation to plot ${plot.plotNo}');
        _centerOnPlotPolygon(plot);
      } else if (plot.latitude != null && plot.longitude != null) {
        final plotLocation = LatLng(plot.latitude!, plot.longitude!);
        
        // Animate to plot location using flutter_map API
        _mapController.move(plotLocation, 13.0);
        
        print('✅ Navigated to plot ${plot.plotNo} at ${plot.latitude}, ${plot.longitude}');
      } else {
        print('❌ Plot ${plot.plotNo} has no coordinates, cannot navigate');
        return;
      }
      
      // Select the plot
      setState(() {
        _selectedPlot = plot;
        _showProjectDetails = true;
        _selectedAmenity = null;
        _showPlotPolygons = true; // Ensure polygons are visible
      });
      
    } catch (e) {
      print('❌ Error navigating to plot: $e');
    }
  }

  /// Navigate map to show filtered plots
  void _navigateToFilteredPlots() {
    if (_plots.isEmpty) return;
    
    try {
      // Calculate bounds of filtered plots
      double minLat = double.infinity;
      double maxLat = -double.infinity;
      double minLng = double.infinity;
      double maxLng = -double.infinity;
      
      for (final plot in _plots) {
        if (plot.latitude != null && plot.longitude != null) {
          minLat = minLat < plot.latitude! ? minLat : plot.latitude!;
          maxLat = maxLat > plot.latitude! ? maxLat : plot.latitude!;
          minLng = minLng < plot.longitude! ? minLng : plot.longitude!;
          maxLng = maxLng > plot.longitude! ? maxLng : plot.longitude!;
        }
      }
      
      if (minLat != double.infinity && maxLat != -double.infinity) {
        // Calculate center point
        final centerLat = (minLat + maxLat) / 2;
        final centerLng = (minLng + maxLng) / 2;
        final center = LatLng(centerLat, centerLng);
        
        // Calculate appropriate zoom level
        final latDiff = maxLat - minLat;
        final lngDiff = maxLng - minLng;
        final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
        
        double zoom = 12.0;
        if (maxDiff > 0) {
          zoom = 15.0 - (maxDiff * 10);
          zoom = zoom.clamp(8.0, 18.0);
        }
        
        print('Navigating to filtered plots: Center: $center, Zoom: $zoom');
        
        // Animate to the new position
        _mapController.move(center, zoom);
      }
    } catch (e) {
      print('Error navigating to filtered plots: $e');
    }
  }

  /// Initialize data loading asynchronously without blocking UI
  void _initializeDataLoadingAsync() async {
    // Don't show loading state - let UI render immediately
    setState(() {
      _isDataLoading = true;
    });

    // Enterprise-grade progressive loading
    // Stage 1: Load essential data (instant)
    await _loadEssentialData();
    
    // Stage 2: Load detailed data (background)
    _loadDetailedDataInBackground();
    
    // Stage 3: Preload for smooth experience
    _preloadForSmoothExperience();
  }
  
  /// Load essential data for instant map display
  Future<void> _loadEssentialData() async {
    try {
      // Always use the existing boundary loading method for now
      print('🔄 Loading boundaries using existing method...');
      
      // Initialize optimized services
      await OptimizedPlotsCache.initialize();
      await OptimizedTileCache.instance.initialize();
      
      // Load boundaries using existing method
      await _loadBoundaryPolygons();
      
      // Load plots using existing method
      await _loadBasicPlots();
      
      print('✅ Essential data loaded using existing methods');
    } catch (e) {
      print('Error loading essential data: $e');
    }
  }
  
  /// Load detailed data in background
  void _loadDetailedDataInBackground() {
    Future.microtask(() async {
      try {
        // Load detailed plot data with GeoJSON parsing
        await _loadDetailedPlots();
        
        // Load amenities on demand
        await _loadAmenitiesMarkers();
        
        setState(() {
          _isDataLoading = false;
          _isInitialized = true;
        });
        
        print('Detailed data loaded in background');
      } catch (e) {
        print('Error loading detailed data: $e');
        setState(() {
          _isDataLoading = false;
          _isInitialized = true;
        });
      }
    });
  }
  
  /// Preload data for smooth user experience
  void _preloadForSmoothExperience() {
    Future.microtask(() async {
      try {
        // Preload common filter combinations
        if (_plots.isNotEmpty) {
          // TODO: Implement filter preloading
        }
        
        // Preload adjacent areas
        await _preloadAdjacentAreas();
        
        print('Preload completed for smooth experience');
      } catch (e) {
        print('Error in preload: $e');
      }
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start monitoring zoom level for lazy loading
    _startZoomMonitoring();
  }
  
  /// Start monitoring zoom level for lazy loading
  void _startZoomMonitoring() {
    Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      // Check if we need to load amenities based on current zoom
      if (_zoom >= 12.0 && _showAmenities && !_amenitiesLoaded && !_isLoadingAmenities) {
        print('Auto-loading amenities based on zoom level: $_zoom');
        _loadAmenitiesMarkers();
        timer.cancel(); // Stop monitoring once loaded
      }
    });
  }

  void _initializeLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _mapCenter = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print('Error getting location: $e');
      // Keep default coordinates if location fails
    }
  }

  /// Load basic plot data (fast, no GeoJSON parsing)
  Future<void> _loadBasicPlots() async {
    // Plots API removed - no longer loading plots on map screen
    print('Plots API removed - skipping plot loading');
  }
  
  /// Load detailed plot data (background, with GeoJSON parsing)
  Future<void> _loadDetailedPlots() async {
    // Plots API removed - no longer loading detailed plots on map screen
    print('Plots API removed - skipping detailed plot loading');
  }
  
  /// Preload adjacent areas for smooth exploration
  Future<void> _preloadAdjacentAreas() async {
    try {
      // Preload data for adjacent areas
      final adjacentCenters = [
        LatLng(_mapCenter.latitude + 0.1, _mapCenter.longitude),
        LatLng(_mapCenter.latitude - 0.1, _mapCenter.longitude),
        LatLng(_mapCenter.latitude, _mapCenter.longitude + 0.1),
        LatLng(_mapCenter.latitude, _mapCenter.longitude - 0.1),
      ];
      
      // Plots API removed - no longer preloading plots
      
      print('Adjacent areas preloaded for smooth exploration');
    } catch (e) {
      print('Error preloading adjacent areas: $e');
    }
  }

  /// Simple progressive plot rendering
  Future<List<PlotModel>> _renderPlotsProgressive({
    required List<PlotModel> allPlots,
    required double zoomLevel,
    required LatLng center,
    required double radiusKm,
    required bool forceRerender,
  }) async {
    // Simple implementation - just return the plots
    return allPlots;
  }

  Future<void> _loadBoundaryPolygons() async {
    try {
      print('🔄 Loading boundary polygons...');
      
      // Try to get boundaries instantly from cache first
      final instantBoundaries = boundary.InstantBoundaryService.getBoundariesInstantly();
      if (instantBoundaries.isNotEmpty) {
        setState(() {
          _boundaryPolygons = instantBoundaries;
          _isLoadingBoundaries = false;
        });
        print('✅ Instant loading: Loaded ${instantBoundaries.length} boundaries from cache');
        return;
      }
      
      print('⚠️ No cached boundaries found, loading from files...');
      
      // If not cached, load with optimization
      final boundaries = await boundary.InstantBoundaryService.loadAllBoundaries();
      setState(() {
        _boundaryPolygons = boundaries;
        _isLoadingBoundaries = false;
      });
      print('✅ Optimized loading: Loaded ${boundaries.length} boundaries with memory cache optimization');
    } catch (e) {
      print('❌ Error loading boundary polygons: $e');
      setState(() {
        _isLoadingBoundaries = false;
      });
    }
  }

  Future<void> _loadAmenitiesMarkers() async {
    try {
      print('=== AMENITIES LOADING DEBUG ===');
      print('Loading amenities markers...');
      
      // Load amenities from GeoJSON file
      final amenitiesFeatures = await geojson.AmenitiesGeoJsonService.loadAmenitiesWithContext(context);
      print('Loaded ${amenitiesFeatures.length} amenity features from GeoJSON');
      
      if (amenitiesFeatures.isEmpty) {
        print('ERROR: No amenities features loaded from GeoJSON!');
        setState(() {
          _isLoadingAmenities = false;
        });
        return;
      }
      
      // Convert to markers for compatibility
      final amenityMarkers = <AmenityMarker>[];
      for (final feature in amenitiesFeatures) {
        try {
          // Null safety checks
          if (feature.type.isEmpty) {
            print('Skipping amenity with empty type');
            continue;
          }
          
          final icon = geojson.AmenitiesGeoJsonService.getAmenityIcon(feature.type);
          final color = geojson.AmenitiesGeoJsonService.getAmenityColor(feature.type);
          final point = feature.getMarkerCoordinates();
          
          // Additional null safety checks
          if (point.latitude.isNaN || point.longitude.isNaN) {
            print('Skipping amenity with invalid coordinates: ${point.latitude}, ${point.longitude}');
            continue;
          }
          
          print('Creating marker for ${feature.type} at ${point.latitude}, ${point.longitude}');
          
          final marker = Marker(
            point: point,
            width: 32,
            height: 32,
            child: GestureDetector(
              onTap: () {
                print('Tapped on ${feature.type} at ${feature.phase}');
                _handleAmenityTap(feature);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
            ),
          );
          
          amenityMarkers.add(AmenityMarker(
            marker: marker,
            amenityType: feature.type,
            phase: feature.phase,
            point: point,
          ));
        } catch (e) {
          print('Error creating amenity marker for ${feature.type}: $e');
          continue;
        }
      }
      
      setState(() {
        _amenitiesMarkers = amenityMarkers;
        _isLoadingAmenities = false;
        _amenitiesLoaded = true; // Mark as loaded
      });
      
      print('Successfully loaded ${amenityMarkers.length} amenity markers');
      print('=== AMENITIES LOADING COMPLETE ===');
    } catch (e) {
      print('ERROR loading amenities from GeoJSON: $e');
      print('Stack trace: ${StackTrace.current}');
      setState(() {
        _isLoadingAmenities = false;
      });
    }
  }


  /// Get filtered amenities markers based on zoom level with lazy loading and dynamic sizing
  List<Marker> _getFilteredAmenitiesMarkers(List<AmenityMarker> amenityMarkers, double zoomLevel) {
    print('=== AMENITIES FILTERING DEBUG (OPTIMIZED) ===');
    print('_showAmenities: $_showAmenities');
    print('zoomLevel: $zoomLevel');
    print('amenityMarkers.length: ${amenityMarkers.length}');
    
    // Convert to optimized format and use optimized renderer
    final List<renderer.AmenityMarker> optimizedAmenities = amenityMarkers.map((amenity) => 
        renderer.AmenityMarker(
          point: amenity.point,
          phase: amenity.phase,
          color: _getAmenityColor(amenity.amenityType),
          icon: _getAmenityIcon(amenity.amenityType),
        )
    ).toList();
    
    return renderer.OptimizedMapRenderer.getFilteredAmenitiesMarkers(
      optimizedAmenities,
      zoomLevel,
      _showAmenities,
    );
  }
  
  /// Get amenity color based on type
  Color _getAmenityColor(String amenityType) {
    switch (amenityType.toLowerCase()) {
      case 'masjid':
        return Colors.green;
      case 'park':
        return Colors.lightGreen;
      case 'school':
        return Colors.blue;
      case 'play ground':
        return Colors.orange;
      case 'graveyard':
        return Colors.grey;
      case 'health facility':
        return Colors.red;
      case 'petrol pump':
        return Colors.amber;
      default:
        return Colors.purple;
    }
  }
  
  /// Get amenity icon based on type
  IconData _getAmenityIcon(String amenityType) {
    switch (amenityType.toLowerCase()) {
      case 'masjid':
        return Icons.mosque;
      case 'park':
        return Icons.park;
      case 'school':
        return Icons.school;
      case 'play ground':
        return Icons.sports_soccer;
      case 'graveyard':
        return Icons.place;
      case 'health facility':
        return Icons.local_hospital;
      case 'petrol pump':
        return Icons.local_gas_station;
      default:
        return Icons.place;
    }
  }

  /// Sample amenities evenly across all phases to ensure fair representation
  List<AmenityMarker> _sampleAmenitiesEvenly(List<AmenityMarker> amenityMarkers, int maxAmenities) {
    if (maxAmenities >= amenityMarkers.length) {
      return amenityMarkers;
    }
    
    // Group amenities by phase
    final Map<String, List<AmenityMarker>> amenitiesByPhase = {};
    for (final amenity in amenityMarkers) {
      amenitiesByPhase.putIfAbsent(amenity.phase, () => []).add(amenity);
    }
    
    print('Amenities by phase: ${amenitiesByPhase.keys.map((phase) => '$phase: ${amenitiesByPhase[phase]!.length}').join(', ')}');
    
    // Calculate how many amenities to take from each phase
    final phases = amenitiesByPhase.keys.toList();
    final amenitiesPerPhase = (maxAmenities / phases.length).round();
    
    final List<AmenityMarker> sampledAmenities = [];
    
    for (final phase in phases) {
      final phaseAmenities = amenitiesByPhase[phase]!;
      final takeCount = amenitiesPerPhase.clamp(0, phaseAmenities.length);
      
      // Use random sampling to avoid always taking the first amenities
      final shuffled = List<AmenityMarker>.from(phaseAmenities)..shuffle();
      sampledAmenities.addAll(shuffled.take(takeCount));
      
      print('Phase $phase: taking $takeCount out of ${phaseAmenities.length} amenities');
    }
    
    // If we still need more amenities, fill from remaining
    if (sampledAmenities.length < maxAmenities) {
      final remaining = amenityMarkers.where((a) => !sampledAmenities.contains(a)).toList();
      final needed = maxAmenities - sampledAmenities.length;
      sampledAmenities.addAll(remaining.take(needed));
    }
    
    print('Sampled ${sampledAmenities.length} amenities evenly across phases');
    return sampledAmenities;
  }

  /// Create amenity marker with dynamic sizing based on zoom level
  Marker _createDynamicAmenityMarker(AmenityMarker amenityMarker, double zoomLevel) {
    // Comprehensive null safety checks
    if (amenityMarker.amenityType.isEmpty) {
      print('Warning: Amenity marker has empty type');
      return Marker(
        point: amenityMarker.point,
        width: 20,
        height: 20,
        child: const Icon(Icons.place, color: Colors.grey),
      );
    }
    
    // Check for valid coordinates
    if (amenityMarker.point.latitude.isNaN || amenityMarker.point.longitude.isNaN) {
      print('Warning: Amenity marker has invalid coordinates');
      return Marker(
        point: const LatLng(0, 0),
        width: 20,
        height: 20,
        child: const Icon(Icons.place, color: Colors.grey),
      );
    }
    
    // Dynamic icon sizing based on zoom level
    double iconSize;
    if (zoomLevel >= 16.0) {
      iconSize = 28.0; // Large at high zoom
    } else if (zoomLevel >= 14.0) {
      iconSize = 20.0; // Medium at medium zoom
    } else {
      iconSize = 14.0; // Small at low zoom
    }
    
    return Marker(
      point: amenityMarker.point,
      width: iconSize,
      height: iconSize,
      child: GestureDetector(
        onTap: () {
          print('Tapped on ${amenityMarker.amenityType}');
          _handleAmenityMarkerTap(amenityMarker);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(iconSize / 2),
            border: Border.all(color: _getAmenityColor(amenityMarker.amenityType), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 1,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            _getAmenityIcon(amenityMarker.amenityType),
            color: _getAmenityColor(amenityMarker.amenityType),
            size: iconSize * 0.5, // Icon is 50% of container size for better visibility
          ),
        ),
      ),
    );
  }


  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      drawer: const SidebarDrawer(),
      body: Stack(
        children: [
          // Map - Always visible, no loading overlay
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _mapCenter,
              initialZoom: _zoom,
              minZoom: 8.0,
              maxZoom: 20.0,
              onTap: (tapPosition, point) {
                _handleMapTap(point);
              },
              // onPositionChanged callback removed due to API changes in flutter_map 8.2.2
              // TODO: Implement proper position change handling
            ),
            children: [
              // Use optimized tile layer for better web performance
              TileLayer(
                urlTemplate: _getTileLayerUrl(),
                userAgentPackageName: 'com.dha.marketplace',
                maxZoom: 18,
                tileProvider: NetworkTileProvider(),
                errorTileCallback: (tile, error, stackTrace) {
                  print('Tile error: $error');
                },
              ),
              // Town plan overlay layer
              if (_showTownPlan && _selectedTownPlanLayer != null)
                TileLayer(
                  urlTemplate: 'https://tiles.dhamarketplace.com/data/${_selectedTownPlanLayer}/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.dha.marketplace',
                  maxZoom: 18,
                  minZoom: renderer.OptimizedMapRenderer.TOWN_PLAN_MIN_ZOOM, // Sync with amenities zoom level
                  tileProvider: NetworkTileProvider(),
                  errorTileCallback: (tile, error, stackTrace) {
                    print('🚫 Town plan tile error: $error');
                    print('🚫 Failed tile coordinates: ${tile.coordinates}');
                  },
                  tileBuilder: (context, tileWidget, tile) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.blue.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      child: tileWidget,
                    );
                  },
                ),
              // Boundary polygons with hollow fill and dotted borders
              PolygonLayer(
                polygons: _getBoundaryPolygons(),
              ),
              // Dotted boundary lines
              PolylineLayer(
                polylines: _getDottedBoundaryLines(),
              ),
              // Plot polygons - showing filtered plots
              if (_showPlotPolygons) ...[
                PolygonLayer(
                  polygons: _getFilteredPlotPolygons(),
                ),
                // Debug: Add a test polygon to verify rendering
                if (_plots.isNotEmpty)
                  PolygonLayer(
                    polygons: [
                      Polygon(
                        points: [
                          LatLng(33.6844, 73.0479), // Islamabad center
                          LatLng(33.6854, 73.0479),
                          LatLng(33.6854, 73.0489),
                          LatLng(33.6844, 73.0489),
                          LatLng(33.6844, 73.0479),
                        ],
                        color: Colors.red.withOpacity(0.5),
                        borderColor: Colors.red,
                        borderStrokeWidth: 2.0,
                        label: 'Test Polygon',
                        labelStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
              ],
              // Plot markers - showing home icons for each plot
              MarkerLayer(
                markers: _getPlotMarkers(),
              ),
               // Amenities markers (only show when toggle is on and at zoom level 12+)
               // NOTE: We only want MARKERS, not polygons for amenities
               if (_showAmenities)
                 MarkerLayer(
                   markers: _getFilteredAmenitiesMarkers(_amenitiesMarkers, _zoom),
                 ),
            ],
          ),
          
          // DHA Loading indicator centered on screen (no background)
          if (_isDataLoading)
            Positioned.fill(
              child: Center(
                child: DHALoadingWidget(
                  size: 120,
                  message: 'Loading data...',
                  showMessage: true,
                ),
              ),
            ),
          
          
          // Top Header - Always visible
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E3C90), Color(0xFF20B2AA)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
                child: Padding(
                padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Scaffold.of(context).openDrawer();
                            },
                            child: Container(
                            padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                              Icons.menu,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                          Expanded(
                          child: Text(
                                  l10n.dhaProjectsMap,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                    fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                                    color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _showViewTypeSelector,
                          icon: const Icon(Icons.layers, color: Colors.white),
                                ),
                              ],
                            ),
                    const SizedBox(height: 12),
                    // View controls and indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getTranslatedViewType(_selectedView, l10n),
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                            // Filtered plot count indicator
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_plots.length} Plots',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        const SizedBox(width: 8),
                        // Status indicator
                            Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isInitialized ? Colors.green.withOpacity(0.8) : Colors.orange.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isInitialized ? Icons.check_circle : Icons.sync,
                              color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _isInitialized ? 'Ready' : 'Loading',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ],
                ),
              ),
            ),
          ),
          
          // Map Controls (Top Left of Map)
          Positioned(
            top: 140,
            left: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Amenities Button
                RectangularToggleButton(
                  text: 'Amenities',
                  icon: Icons.location_on,
                  isSelected: _showAmenities,
                  onPressed: () {
                    setState(() {
                      _showAmenities = !_showAmenities;
                    });
                    
                    // Load amenities when toggled on and not already loaded
                    if (_showAmenities && !_amenitiesLoaded && !_isLoadingAmenities) {
                      print('Loading amenities on toggle...');
                      _loadAmenitiesMarkers();
                    }
                  },
                ),
                const SizedBox(height: 8),
                // Boundaries Button
                RectangularToggleButton(
                  text: 'Boundaries',
                  icon: Icons.layers,
                  isSelected: _showBoundaries,
                  onPressed: () {
                    setState(() {
                      _showBoundaries = !_showBoundaries;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Filters Button (Top Right of Map)
          Positioned(
            top: 140,
            right: 20,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3C90), Color(0xFF20B2AA)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.filter_list,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Filters',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E3C90),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_activeFilters.isNotEmpty && _activeFilters.first != 'All Plots')
                    Positioned(
                      right: -4,
                      top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF1E3C90), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E3C90).withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          '${_activeFilters.length}',
                          style: const TextStyle(
                            color: Color(0xFF1E3C90),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Modern Filters Panel - Fixed positioning with proper constraints
          Positioned(
            top: 120,
            right: 8,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
            child: ModernFiltersPanel(
              isVisible: _showFilters,
              onClose: () {
                setState(() {
                  _showFilters = false;
                });
              },
              onFiltersChanged: (filters) {
                // Apply filters immediately without debouncer
                setState(() {
                  _selectedPlotType = filters['plotType'];
                  _selectedDhaPhase = filters['dhaPhase'];
                  _selectedPlotSize = filters['plotSize'];
                  _priceRange = filters['priceRange'] ?? const RangeValues(5475000, 565000000);
                  _activeFilters = List<String>.from(filters['activeFilters'] ?? []);
                  // Ensure filter panel stays open after applying filters
                  _showFilters = true;
                });
                
                // Apply filters to modern filter manager immediately
                _applyFiltersToManager(filters);
                
                // Update bottom sheet visibility
                _updateBottomSheetVisibility();
                
                print('🔍 Filter panel state after filter change: _showFilters = $_showFilters');
              },
              initialFilters: {
                'plotType': _selectedPlotType,
                'dhaPhase': _selectedDhaPhase,
                'plotSize': _selectedPlotSize,
                'priceRange': _priceRange,
              },
              // Pass dynamic filter options from the filter manager
              enabledPhases: _filterManager.availablePhases,
              enabledSizes: _filterManager.availableSizes,
            ),
            ),
          ),

          // Collapsible Map Controls (Bottom Right) - Always visible above bottom sheet
          Positioned(
            bottom: _isBottomSheetVisible && _isBottomSheetExpanded ? 250 : 20, // Higher when bottom sheet is expanded
            right: 20,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Expanded Controls (shown when _showMapControls is true)
                  AnimatedOpacity(
                    opacity: _showMapControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _showMapControls ? null : 0,
                      child: _showMapControls ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // All Phases Button
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: FloatingActionButton(
                              onPressed: _showAllPhases,
                              backgroundColor: const Color(0xFF20B2AA),
                              child: const Icon(Icons.home_work, color: Colors.white),
                              tooltip: 'Show All Phases',
                            ),
                          ),
                          // Zoom In Button
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: FloatingActionButton(
                              onPressed: _zoomIn,
                              backgroundColor: const Color(0xFF20B2AA),
                              mini: true,
                              child: const Icon(Icons.add, color: Colors.white),
                              tooltip: 'Zoom In',
                            ),
                          ),
                          // Zoom Out Button
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: FloatingActionButton(
                              onPressed: _zoomOut,
                              backgroundColor: const Color(0xFF20B2AA),
                              mini: true,
                              child: const Icon(Icons.remove, color: Colors.white),
                              tooltip: 'Zoom Out',
                            ),
                          ),
                          // Layer Toggle Button
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: FloatingActionButton(
                              onPressed: _showViewTypeSelector,
                              backgroundColor: const Color(0xFF20B2AA),
                              mini: true,
                              child: const Icon(Icons.layers, color: Colors.white),
                              tooltip: 'Change Map View',
                            ),
                          ),
                          // Town Plan Toggle Button
                          Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: FloatingActionButton(
                              onPressed: _toggleTownPlan,
                              backgroundColor: _showTownPlan ? const Color(0xFF4CAF50) : const Color(0xFF20B2AA),
                              mini: true,
                              child: Icon(
                                _showTownPlan ? Icons.map : Icons.map_outlined,
                                color: Colors.white,
                              ),
                              tooltip: _showTownPlan ? 'Hide Town Plan' : 'Show Town Plan',
                            ),
                          ),
                        ],
                      ) : const SizedBox.shrink(),
                    ),
                  ),
                  // Main Toggle Button (always visible)
                  FloatingActionButton(
                    onPressed: () {
                      setState(() {
                        _showMapControls = !_showMapControls;
                      });
                    },
                    backgroundColor: const Color(0xFF20B2AA),
                    child: AnimatedRotation(
                      turns: _showMapControls ? 0.125 : 0.0, // 45 degree rotation
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        _showMapControls ? Icons.close : Icons.menu,
                        color: Colors.white,
                      ),
                    ),
                    tooltip: _showMapControls ? 'Close Controls' : 'Open Controls',
                  ),
                ],
              ),
            ),
          ),

          // Clean UI with only rectangular toggle buttons

          // Town Plan Legend (Top Left)
          if (_showTownPlan)
            Positioned(
              top: 140,
              left: 20,
              child: _buildTownPlanLegend(),
            ),

          // Bottom Sheet for Filtered Plots (matches web app design)
          _buildBottomSheet(),

          // Plot Details Popup - Show when a plot is selected on map
          if (_selectedPlot != null && _selectedPlotDetails != null)
            _buildPlotDetailsPopup(),
        ],
      ),
    );
  }

  String _getTileLayerUrl() {
    switch (_selectedView) {
      case 'Satellite':
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      case 'Street':
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      case 'Hybrid':
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
      default:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
    }
  }

  List<Polygon> _getBoundaryPolygons() {
    // Use optimized renderer for better performance
    // Convert boundary.BoundaryPolygon to renderer.BoundaryPolygon
    final rendererBoundaries = _boundaryPolygons.map((boundary) => 
      renderer.BoundaryPolygon(
        phaseName: boundary.phaseName,
        polygons: boundary.polygons,
        color: boundary.color,
        icon: boundary.icon,
      )
    ).toList();
    
    return renderer.OptimizedMapRenderer.getOptimizedBoundaryPolygons(
      rendererBoundaries,
      _zoom,
      _showBoundaries,
    );
  }

  List<Polyline> _getDottedBoundaryLines() {
    // Use optimized renderer for better performance
    // Convert boundary.BoundaryPolygon to renderer.BoundaryPolygon
    final rendererBoundaries = _boundaryPolygons.map((boundary) => 
      renderer.BoundaryPolygon(
        phaseName: boundary.phaseName,
        polygons: boundary.polygons,
        color: boundary.color,
        icon: boundary.icon,
      )
    ).toList();
    
    return renderer.OptimizedMapRenderer.getOptimizedBoundaryLines(
      rendererBoundaries,
      _zoom,
      _showBoundaries,
    );
  }

  List<LatLng> _createDottedLine(LatLng start, LatLng end, int segments) {
    final points = <LatLng>[];
    
    for (int i = 0; i <= segments; i++) {
      final ratio = i / segments;
      final lat = start.latitude + (end.latitude - start.latitude) * ratio;
      final lng = start.longitude + (end.longitude - start.longitude) * ratio;
      points.add(LatLng(lat, lng));
    }
    
    return points;
  }

  /// Check if boundaries should be optimized for performance
  bool _shouldOptimizeBoundaries() {
    return _zoom < renderer.OptimizedMapRenderer.BOUNDARY_OPTIMIZATION_ZOOM;
  }
  
  /// Get plot markers (home icons) for rendering
  List<Marker> _getPlotMarkers() {
    try {
      print('🏠 Creating plot markers for ${_plots.length} plots');
      
      if (_plots.isEmpty) {
        print('❌ No plots to create markers for');
        return [];
      }

      final markers = <Marker>[];
      
      for (final plot in _plots) {
        // Only create markers for plots with valid coordinates
        if (plot.latitude != null && plot.longitude != null) {
          final marker = Marker(
            point: LatLng(plot.latitude!, plot.longitude!),
            width: 32,
            height: 32,
            child: GestureDetector(
              onTap: () {
                print('🏠 Plot marker tapped: ${plot.plotNo}');
                setState(() {
                  _selectedPlot = plot;
                  _showProjectDetails = true;
                  _selectedAmenity = null;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _getPlotMarkerColor(plot),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          );
          
          markers.add(marker);
          print('🏠 Added marker for plot ${plot.plotNo} at ${plot.latitude}, ${plot.longitude}');
        } else {
          print('⚠️ Plot ${plot.plotNo} has no coordinates, skipping marker');
        }
      }
      
      print('✅ Created ${markers.length} plot markers');
      return markers;
    } catch (e) {
      print('❌ Error creating plot markers: $e');
      return [];
    }
  }

  /// Get plot marker color based on status
  Color _getPlotMarkerColor(PlotModel plot) {
    switch (plot.status.toLowerCase()) {
      case 'available':
        return const Color(0xFF4CAF50); // Green
      case 'sold':
        return Colors.red;
      case 'reserved':
        return Colors.orange;
      case 'unsold':
        return const Color(0xFF1E3C90); // Blue
      default:
        return Colors.grey;
    }
  }

  /// Get filtered plot polygons for rendering
  List<Polygon> _getFilteredPlotPolygons() {
    try {
      print('🔍 _getFilteredPlotPolygons called - _plots count: ${_plots.length}');
      print('🔍 _showPlotPolygons: $_showPlotPolygons');
      
      if (_plots.isEmpty) {
        print('❌ No filtered plots to render (plots count: ${_plots.length})');
        return [];
      }

      // Debug: Check plots with valid polygon coordinates
      final plotsWithPolygons = _plots.where((plot) {
        try {
          final polygons = plot.polygonCoordinates;
          final hasValidPolygons = polygons.isNotEmpty && polygons.first.isNotEmpty;
          if (hasValidPolygons) {
            print('✅ Plot ${plot.plotNo} has ${polygons.length} polygons with ${polygons.first.length} points');
            // Log first few coordinates for debugging
            if (polygons.first.isNotEmpty) {
              print('   First point: ${polygons.first.first}');
              print('   Last point: ${polygons.first.last}');
            }
          } else {
            print('❌ Plot ${plot.plotNo} has no valid polygon coordinates');
          }
          return hasValidPolygons;
        } catch (e) {
          print('❌ Error checking polygon coordinates for plot ${plot.plotNo}: $e');
          return false;
        }
      }).toList();
      
      print('📊 Plots with valid polygon coordinates: ${plotsWithPolygons.length}/${_plots.length}');
      
      if (plotsWithPolygons.isEmpty) {
        print('❌ No plots have valid polygon coordinates');
        return [];
      }

      // Use EnhancedPolygonService with selected plot highlighting
      final polygons = EnhancedPolygonService.createPlotPolygons(plotsWithPolygons, selectedPlot: _selectedPlot);
      
      print('✅ Created ${polygons.length} plot polygons using EnhancedPolygonService');
      
      // Debug: Log first few polygon coordinates
      if (polygons.isNotEmpty) {
        final firstPolygon = polygons.first;
        print('📍 First polygon has ${firstPolygon.points.length} points');
        if (firstPolygon.points.isNotEmpty) {
          print('📍 First point: ${firstPolygon.points.first}');
          print('📍 Last point: ${firstPolygon.points.last}');
        }
      }
      
      return polygons;
    } catch (e) {
      print('❌ Error creating filtered plot polygons: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  void _handleMapTap(LatLng point) {
    try {
      print('Map tapped at: $point');
      print('Available plots for tap detection: ${_plots.length}');
      
      // PRIORITY 1: Check for filtered plot polygons first
      final tappedPlot = EnhancedPolygonService.findPlotAtPoint(point, _plots);
      
      if (tappedPlot != null) {
        print('✅ Filtered plot tapped: ${tappedPlot.plotNo} - Showing plot information');
        
        // Validate plot data before proceeding
        if (tappedPlot.plotNo.isNotEmpty) {
          // Use the enhanced plot selection handler
          PlotSelectionHandler.selectPlot(tappedPlot);
          
          setState(() {
            _selectedPlot = tappedPlot;
            _showProjectDetails = true;
            _selectedAmenity = null;
            _isBottomSheetVisible = true; // Show bottom sheet when plot is selected
          });
          print('✅ Plot info card should now be visible for plot ${tappedPlot.plotNo}');
          return;
        } else {
          print('❌ Plot tapped but plot number is empty, skipping');
        }
      }
      
      // PRIORITY 2: Check for amenities only if no plot was found
      if (_showAmenities && _zoom >= 12.0) {
        // Find amenity at tapped point
        final tappedAmenity = _findAmenityAtPoint(point);
        if (tappedAmenity != null) {
          print('Amenity tapped: ${tappedAmenity.amenityType} - Showing amenity information');
          
          setState(() {
            _selectedAmenity = tappedAmenity;
            _showProjectDetails = false;
            _selectedPlot = null;
          });
          _showAmenityInfo(tappedAmenity);
          return;
        }
      }
      
      // Clear selection if no plot or amenity was tapped
      print('No plot or amenity found at tap point - Clearing selection');
      PlotSelectionHandler.handleMapTap();
      
      setState(() {
        _showProjectDetails = false;
        _selectedPlot = null;
        _selectedAmenity = null;
        _isBottomSheetVisible = false; // Hide bottom sheet when no plot is selected
      });
    } catch (e) {
      print('Error in map tap handler: $e');
      // Clear any existing selections on error
      setState(() {
        _showProjectDetails = false;
        _selectedPlot = null;
        _selectedAmenity = null;
      });
    }
  }

  /// Find amenity at a specific point
  AmenityMarker? _findAmenityAtPoint(LatLng point) {
    const double tolerance = 0.0001; // Small tolerance for click detection
    
    print('Finding amenity at point: $point');
    print('Available amenities: ${_amenitiesMarkers.length}');
    
    for (final amenity in _amenitiesMarkers) {
      final distance = _calculateDistance(point, amenity.point);
      print('Distance to ${amenity.amenityType}: $distance (tolerance: $tolerance)');
      
      if (distance <= tolerance) {
        print('Found amenity: ${amenity.amenityType}');
        return amenity;
      }
    }
    
    print('No amenity found at point');
    return null;
  }

  /// Calculate distance between two points
  double _calculateDistance(LatLng point1, LatLng point2) {
    final latDiff = point1.latitude - point2.latitude;
    final lngDiff = point1.longitude - point2.longitude;
    return (latDiff * latDiff + lngDiff * lngDiff);
  }

  /// Handle amenity tap
  void _handleAmenityTap(geojson.AmenityFeature feature) {
    setState(() {
      _selectedAmenity = AmenityMarker(
        marker: Marker(
          point: feature.center,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: Icon(
              geojson.AmenitiesGeoJsonService.getAmenityIcon(feature.type),
              color: geojson.AmenitiesGeoJsonService.getAmenityColor(feature.type),
              size: 18,
            ),
          ),
        ),
        amenityType: feature.type,
        phase: feature.phase,
        point: feature.center,
      );
      _showProjectDetails = false;
      _selectedPlot = null;
    });
    _showAmenityInfo(_selectedAmenity!);
  }

  /// Handle amenity marker tap (overloaded method for AmenityMarker)
  void _handleAmenityMarkerTap(AmenityMarker amenityMarker) {
    setState(() {
      _selectedAmenity = amenityMarker;
      _showProjectDetails = false;
      _selectedPlot = null;
    });
    _showAmenityInfo(_selectedAmenity!);
  }

  /// Show amenity information dialog
  void _showAmenityInfo(AmenityMarker amenity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              geojson.AmenitiesGeoJsonService.getAmenityIcon(amenity.amenityType),
              color: geojson.AmenitiesGeoJsonService.getAmenityColor(amenity.amenityType),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                amenity.amenityType,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Phase', 'Phase ${amenity.phase}'),
            const SizedBox(height: 8),
            _buildInfoRow('Type', amenity.amenityType),
            const SizedBox(height: 8),
            _buildInfoRow('Location', '${amenity.point.latitude.toStringAsFixed(6)}, ${amenity.point.longitude.toStringAsFixed(6)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Close',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build info row for amenity dialog
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: Color(0xFF666666),
            ),
          ),
        ),
      ],
    );
  }

  LinearGradient _getPlotGradient(PlotModel plot) {
    switch (plot.status.toLowerCase()) {
      case 'available':
        return const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case 'sold':
        return const LinearGradient(
          colors: [Color(0xFFF44336), Color(0xFFD32F2F)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case 'reserved':
        return const LinearGradient(
          colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      case 'unsold':
        return const LinearGradient(
          colors: [Color(0xFF1E3C90), Color(0xFF20B2AA)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFF9E9E9E), Color(0xFF757575)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );
    }
  }

  IconData _getPlotIcon(PlotModel plot) {
    switch (plot.category.toLowerCase()) {
      case 'residential':
        return Icons.home;
      case 'commercial':
        return Icons.business;
      case 'industrial':
        return Icons.factory;
      default:
        return Icons.location_on;
    }
  }

  String _getTranslatedViewType(String viewType, AppLocalizations l10n) {
    switch (viewType) {
      case 'Satellite':
        return 'Satellite';
      case 'Street':
        return 'Street';
      case 'Hybrid':
        return 'Hybrid';
      default:
        return 'Satellite';
    }
  }

  void _showViewTypeSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: _viewTypes.map((viewType) => ListTile(
                  title: Text(viewType),
                  trailing: _selectedView == viewType ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(() {
                      _selectedView = viewType;
                    });
                    Navigator.pop(context);
                  },
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.grey[300]!, width: 0.5),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  Widget _buildAmenityLegendItem(String label, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: color,
            size: 12,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ],
    );
  }

  void _showPlotIdSearch() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Search by Plot ID',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _plotIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Enter Plot ID',
                hintText: 'e.g., 5, 12, 25',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _plotIdController.clear();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final id = int.tryParse(_plotIdController.text);
                    if (id != null) {
                      // Plots API removed - no longer searching plots by ID
                      Navigator.pop(context);
                      _plotIdController.clear();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid Plot ID'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF20B2AA),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Search'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _centerMapOnBoundaries() {
    if (_boundaryPolygons.isEmpty) return;
    
    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLng = double.infinity;
    double maxLng = -double.infinity;
    
    for (final boundary in _boundaryPolygons) {
      for (final polygon in boundary.polygons) {
        for (final point in polygon) {
          minLat = minLat < point.latitude ? minLat : point.latitude;
          maxLat = maxLat > point.latitude ? maxLat : point.latitude;
          minLng = minLng < point.longitude ? minLng : point.longitude;
          maxLng = maxLng > point.longitude ? maxLng : point.longitude;
        }
      }
    }
    
    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;
    final center = LatLng(centerLat, centerLng);
    
    // Calculate appropriate zoom level
    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final maxDiff = latDiff > lngDiff ? latDiff : lngDiff;
    
    double zoom = 12.0;
    if (maxDiff > 0.1) zoom = 10.0;
    else if (maxDiff > 0.05) zoom = 11.0;
    else if (maxDiff > 0.02) zoom = 12.0;
    else if (maxDiff > 0.01) zoom = 13.0;
    else zoom = 14.0;
    
    _mapController.move(center, zoom);
  }

  /// Center map on phase boundaries when app loads
  void _centerMapOnPhaseBoundaries() {
    // Delay to ensure boundaries are loaded
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (_boundaryPolygons.isNotEmpty) {
        print('🎯 Centering map on phase boundaries');
        _centerMapOnBoundaries();
        setState(() {
          _showBoundaries = true; // Ensure boundaries are visible
        });
      } else {
        print('⚠️ No boundary polygons available for centering');
        // Fallback to default center with appropriate zoom for phase boundaries
        _mapController.move(const LatLng(33.6844, 73.0479), 12.0);
      }
    });
  }

  /// Zoom in on the map
  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    final newZoom = (currentZoom + 1).clamp(8.0, 20.0);
    _mapController.move(_mapController.camera.center, newZoom);
    setState(() {
      _zoom = newZoom;
    });
  }

  /// Zoom out on the map
  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    final newZoom = (currentZoom - 1).clamp(8.0, 20.0);
    _mapController.move(_mapController.camera.center, newZoom);
    setState(() {
      _zoom = newZoom;
    });
  }

  /// Toggle town plan overlay
  void _toggleTownPlan() {
    setState(() {
      _showTownPlan = !_showTownPlan;
    });
    
    if (_showTownPlan) {
      // Set default layer if none selected
      if (_selectedTownPlanLayer == null) {
        _selectedTownPlanLayer = 'phase2'; // Default to Phase 2
        print('🗺️ Default town plan layer set to: $_selectedTownPlanLayer');
      }
      _testTownPlanTileUrl();
      _showTownPlanLayerSelector();
    } else {
      print('🗺️ Town plan overlay disabled');
    }
  }

  /// Test town plan tile URL format
  void _testTownPlanTileUrl() {
    if (_selectedTownPlanLayer == null) {
      print('❌ No town plan layer selected');
      return;
    }
    
    final testUrl = 'https://tiles.dhamarketplace.com/data/${_selectedTownPlanLayer}/14/12345/67890.png';
    print('🔍 Testing town plan tile URL: $testUrl');
    print('🔍 Selected layer: $_selectedTownPlanLayer');
    print('🔍 Current zoom: $_zoom');
    print('🔍 Current center: $_mapCenter');
    
    // Test different URL formats for TileServer GL
    final alternativeUrls = [
      'https://tiles.dhamarketplace.com/data/${_selectedTownPlanLayer}/{z}/{x}/{y}.png', // Correct format
      'https://tiles.dhamarketplace.com/data/${_selectedTownPlanLayer}/tiles/{z}/{x}/{y}.png', // Incorrect
      'https://tiles.dhamarketplace.com/${_selectedTownPlanLayer}/{z}/{x}/{y}.png', // Alternative
    ];
    
    for (int i = 0; i < alternativeUrls.length; i++) {
      print('🔍 Alternative URL ${i + 1}: ${alternativeUrls[i]}');
    }
    
    // Test actual tile server response
    _testTileServerResponse();
  }

  /// Test tile server response
  Future<void> _testTileServerResponse() async {
    // Import the test service
    try {
      // Test server connectivity
      final isServerUp = await _testServerConnectivity();
      if (!isServerUp) {
        print('❌ Tile server is not accessible');
        _showTileServerError('Server not accessible. Check network connection.');
        return;
      }
      
      // Test specific tile
      final isTileAvailable = await _testSpecificTile();
      if (!isTileAvailable) {
        print('❌ Specific tile not available');
        _showTileServerError('Tile not available for current location/zoom.');
      } else {
        print('✅ Tile server test passed');
        _showTileServerSuccess('Town plan tiles are loading correctly!');
      }
    } catch (e) {
      print('❌ Tile server test failed: $e');
      _showTileServerError('Test failed: $e');
    }
  }
  
  /// Test server connectivity
  Future<bool> _testServerConnectivity() async {
    try {
      final response = await http.get(
        Uri.parse('https://tiles.dhamarketplace.com/data/'),
        headers: {
          'User-Agent': 'DHA Marketplace Mobile App',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('🌐 Server response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Server connectivity failed: $e');
      return false;
    }
  }
  
  /// Test specific tile
  Future<bool> _testSpecificTile() async {
    if (_selectedTownPlanLayer == null) return false;
    
    try {
      // Convert current map center to tile coordinates
      final tileX = _lngToTileX(_mapCenter.longitude, _zoom.round());
      final tileY = _latToTileY(_mapCenter.latitude, _zoom.round());
      
      final url = 'https://tiles.dhamarketplace.com/data/${_selectedTownPlanLayer}/$_zoom/$tileX/$tileY.png';
      print('🔍 Testing tile: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'DHA Marketplace Mobile App',
          'Accept': 'image/png',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('🔍 Tile response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Tile test failed: $e');
      return false;
    }
  }
  
  /// Convert longitude to tile X coordinate
  int _lngToTileX(double lng, int zoom) {
    return ((lng + 180) / 360 * (1 << zoom)).floor();
  }
  
  /// Convert latitude to tile Y coordinate
  int _latToTileY(double lat, int zoom) {
    final latRad = lat * pi / 180;
    final n = 1 << zoom;
    return ((1 - (log(tan(pi / 4 + latRad / 2)) / pi)) / 2 * n).floor();
  }
  
  /// Show tile server error
  void _showTileServerError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ $message'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }
  
  /// Show tile server success
  void _showTileServerSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ $message'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show town plan layer selector
  void _showTownPlanLayerSelector() {
    final townPlanLayers = [
      {'id': 'phase1', 'name': 'Phase 1', 'description': 'DHA Phase 1 Development', 'coordinates': '33.5348, 73.0951'},
      {'id': 'phase2', 'name': 'Phase 2', 'description': 'DHA Phase 2 Development', 'coordinates': '33.52844, 73.15383'},
      {'id': 'phase3', 'name': 'Phase 3', 'description': 'DHA Phase 3 Development', 'coordinates': '33.49562, 73.15650'},
      {'id': 'phase4', 'name': 'Phase 4', 'description': 'DHA Phase 4 Development', 'coordinates': '33.52165, 73.07213'},
      {'id': 'phase4_gv', 'name': 'Phase 4 GV', 'description': 'DHA Phase 4 Garden View', 'coordinates': '33.50073, 73.04962'},
      {'id': 'phase4_rvs-updated', 'name': 'Phase 4 RVS', 'description': 'DHA Phase 4 RVS Development', 'coordinates': '33.48358, 72.99944'},
      {'id': 'phase5', 'name': 'Phase 5', 'description': 'DHA Phase 5 Development', 'coordinates': '33.52335, 73.20746'},
      {'id': 'phase6', 'name': 'Phase 6', 'description': 'DHA Phase 6 Development', 'coordinates': '33.55784, 73.28214'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Town Plan Layer',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ),
            Container(
              height: 400,
              child: ListView.builder(
                itemCount: townPlanLayers.length,
                itemBuilder: (context, index) {
                  final layer = townPlanLayers[index];
                  final isSelected = _selectedTownPlanLayer == layer['id'];
                  
                  return ListTile(
                    leading: Icon(
                      isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                      color: isSelected ? const Color(0xFF20B2AA) : Colors.grey,
                    ),
                    title: Text(
                      layer['name']!,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFF20B2AA) : const Color(0xFF1A1A2E),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          layer['description']!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Coordinates: ${layer['coordinates']}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                      onTap: () {
                        setState(() {
                          _selectedTownPlanLayer = layer['id']!;
                        });
                        Navigator.pop(context);
                        _centerMapOnTownPlanLayer(layer['id']!);
                      },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show all phases with optimal zoom
  void _showAllPhases() {
    setState(() {
      _selectedPhase = 'All Phases';
    });
    _centerMapOnBoundaries();
  }

  /// Select a plot and show its details
  Future<void> _selectPlot(PlotModel plot) async {
    try {
      print('🎯 Selecting plot: ${plot.plotNo}');
      print('🎯 Plot category: ${plot.category}, status: ${plot.status}');
      
      setState(() {
        _isLoadingPlotDetails = true;
        _showSelectedPlotDetails = true;
        _selectedPlot = plot; // Set selected plot immediately
        _showPlotPolygons = true; // Ensure polygons are visible
        _showProjectDetails = true; // Show plot details popup
        _isBottomSheetVisible = true; // Show bottom sheet when plot is selected
      });

      // Navigate to plot using polygon coordinates for accurate positioning
      print('🎯 Plot has ${plot.polygonCoordinates.length} polygon coordinate sets');
      
      if (plot.polygonCoordinates.isNotEmpty) {
        // Use polygon coordinates for accurate centering
        print('🎬 Using polygon coordinates for navigation to plot ${plot.plotNo}');
        
        // Debug: Log polygon coordinates
        final firstPolygon = plot.polygonCoordinates.first;
        print('🎯 First polygon has ${firstPolygon.length} points');
        if (firstPolygon.isNotEmpty) {
          print('🎯 First point: ${firstPolygon.first}');
          print('🎯 Last point: ${firstPolygon.last}');
        }
        
        _centerOnPlotPolygon(plot);
      } else if (plot.latitude != null && plot.longitude != null) {
        // Fallback to center coordinates if no polygon available
        final plotLocation = LatLng(plot.latitude!, plot.longitude!);
        
        print('🎯 Using center coordinates: ${plot.latitude}, ${plot.longitude}');
        print('🎯 Plot location: $plotLocation');
        
        // Ensure plot polygons are visible first
        setState(() {
          _showPlotPolygons = true;
        });
        
        // Force map to navigate to plot location
        print('🎬 Starting map navigation to plot ${plot.plotNo}');
        print('🎬 Current map center: ${_mapController.camera.center}');
        print('🎬 Target location: $plotLocation');
        
        // Use moveAndRotate for better control with optimal zoom for satellite imagery
        _mapController.moveAndRotate(plotLocation, 14.0, 0.0);
        
        print('🗺️ Map navigation completed for plot ${plot.plotNo}');
        print('🗺️ New map center: ${_mapController.camera.center}');
      } else {
        print('❌ Plot ${plot.plotNo} has no coordinates: lat=${plot.latitude}, lng=${plot.longitude}');
        print('❌ Plot GeoJSON: ${plot.stAsgeojson.substring(0, 100)}...');
      }

      // Try to fetch detailed plot information from API first
      PlotDetailsModel? plotDetails = await PlotDetailsService.fetchPlotDetails(plot.plotNo);
      
      // If API fails, use existing plot data as fallback
      if (plotDetails == null) {
        print('⚠️ API failed, using existing plot data as fallback');
        plotDetails = PlotDetailsService.createFromPlotModel(plot);
      }
      
      if (plotDetails != null) {
        setState(() {
          _selectedPlotDetails = plotDetails;
          _isLoadingPlotDetails = false;
        });

        // Expand bottom sheet to show selected plot details
        _safeAnimateBottomSheet(0.6);

        // Add a delay to ensure map animation completes and polygon renders before showing info card
        await Future.delayed(const Duration(milliseconds: 1500));

        print('✅ Plot selected successfully: ${plot.plotNo}');
        print('✅ Plot polygon should be highlighted in blue');
        print('✅ Plot info card should be visible on map');
        print('✅ Selected tab should show real plot data');
        print('✅ Map should be centered on plot polygon boundary');
      } else {
        setState(() {
          _isLoadingPlotDetails = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load plot details'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('❌ Error selecting plot: $e');
      setState(() {
        _isLoadingPlotDetails = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Clear plot selection
  void _clearPlotSelection() {
    setState(() {
      _selectedPlotDetails = null;
      _selectedPlot = null;
      _showSelectedPlotDetails = false;
      _isLoadingPlotDetails = false;
      // Also hide the bottom sheet when clearing selection
      _isBottomSheetVisible = false;
    });
    print('🗑️ Plot selection cleared');
  }

  /// Safely animate bottom sheet
  void _safeAnimateBottomSheet(double size) {
    if (_isBottomSheetInitialized && _bottomSheetController.isAttached) {
      try {
        _bottomSheetController.animateTo(
          size,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        print('📱 Animating bottom sheet to: ${(size * 100).toInt()}%');
      } catch (e) {
        print('Error animating bottom sheet: $e');
      }
    } else {
      // If not initialized, wait a bit and try again
      Future.delayed(const Duration(milliseconds: 200), () {
        if (_isBottomSheetInitialized && _bottomSheetController.isAttached) {
          try {
            _bottomSheetController.animateTo(
              size,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
            print('📱 Animating bottom sheet to: ${(size * 100).toInt()}% (delayed)');
          } catch (e) {
            print('Error animating bottom sheet (delayed): $e');
          }
        }
      });
    }
  }

  /// Navigate to plot on map
  void _navigateToPlotOnMap(PlotModel plot) {
    try {
      print('🎯 Navigating to plot on map: ${plot.plotNo}');
      
      // Use polygon coordinates for accurate navigation if available
      if (plot.polygonCoordinates.isNotEmpty) {
        print('🎯 Using polygon coordinates for navigation to plot ${plot.plotNo}');
        _centerOnPlotPolygon(plot);
      } else if (plot.latitude != null && plot.longitude != null) {
        final plotLocation = LatLng(plot.latitude!, plot.longitude!);
        
        print('🎯 Plot location: $plotLocation');
        print('🎯 Current map center: ${_mapController.camera.center}');
        
        // Navigate to plot location with higher zoom
        _mapController.moveAndRotate(plotLocation, 13.0, 0.0);
        
        print('🎯 Map navigation completed');
        print('🎯 New map center: ${_mapController.camera.center}');
      } else {
        print('❌ Plot ${plot.plotNo} has no coordinates for navigation');
        return;
      }
      
      setState(() {
        _selectedPlot = plot;
        _showProjectDetails = true;
        _selectedAmenity = null;
        _showPlotPolygons = true; // Ensure polygons are visible
      });
    } catch (e) {
      print('❌ Error navigating to plot on map: $e');
    }
  }

  /// Calculate the plot's screen position based on polygon coordinates
  Offset? _calculatePlotScreenPosition() {
    if (_selectedPlot == null) return null;
    
    try {
      // Get polygon coordinates
      final polygonCoordinates = _selectedPlot!.polygonCoordinates;
      if (polygonCoordinates.isEmpty) return null;

      final coordinates = polygonCoordinates.first;
      if (coordinates.length < 3) return null;

      // Calculate simple centroid (average of vertices)
      double sumLat = 0;
      double sumLng = 0;
      int count = 0;
      for (final coord in coordinates) {
        sumLat += coord.latitude;
        sumLng += coord.longitude;
        count++;
      }
      if (count == 0) return null;

      final centroid = LatLng(sumLat / count, sumLng / count);
      print('📍 Plot polygon centroid: ${centroid.latitude}, ${centroid.longitude}');

      // Fallback approach for web: position relative to screen center
      final size = MediaQuery.of(context).size;
      return Offset(size.width * 0.5, size.height * 0.5);
    } catch (e) {
      print('❌ Error calculating plot screen position: $e');
      return null;
    }
  }

  /// Update plot info card position when map changes
  void _updatePlotInfoCardPosition() {
    if (_selectedPlot != null && _showProjectDetails) {
      // Trigger a rebuild to recalculate the position
      setState(() {
        // This will cause the _buildPlotDetailsPopup to recalculate position
      });
    }
  }

  /// Center map on plot polygon bounds
  void _centerOnPlotPolygon(PlotModel plot) {
    try {
      print('🎯 Attempting to center on polygon for plot ${plot.plotNo}');
      print('🎯 Plot has ${plot.polygonCoordinates.length} polygon coordinate sets');
      
      // Get polygon coordinates from the plot
      if (plot.polygonCoordinates.isNotEmpty) {
        final coordinates = plot.polygonCoordinates.first;
        print('🎯 First polygon has ${coordinates.length} coordinate points');
        
        if (coordinates.length >= 3) {
          // Calculate bounds of the polygon
          double minLat = coordinates.first.latitude;
          double maxLat = coordinates.first.latitude;
          double minLng = coordinates.first.longitude;
          double maxLng = coordinates.first.longitude;
          
          for (final coord in coordinates) {
            minLat = minLat < coord.latitude ? minLat : coord.latitude;
            maxLat = maxLat > coord.latitude ? maxLat : coord.latitude;
            minLng = minLng < coord.longitude ? minLng : coord.longitude;
            maxLng = maxLng > coord.longitude ? maxLng : coord.longitude;
          }
          
          // Calculate center of the polygon
          final centerLat = (minLat + maxLat) / 2;
          final centerLng = (minLng + maxLng) / 2;
          final center = LatLng(centerLat, centerLng);
          
          print('🎯 Polygon bounds: lat($minLat-$maxLat), lng($minLng-$maxLng)');
          print('🎯 Polygon center: $center');
          print('🎯 Current map center: ${_mapController.camera.center}');
          
          // Calculate appropriate zoom level based on polygon size
          final latRange = maxLat - minLat;
          final lngRange = maxLng - minLng;
          final maxRange = latRange > lngRange ? latRange : lngRange;
          
          // Determine zoom level based on polygon size - optimized for satellite imagery visualization
          double zoomLevel = 14.0; // Default zoom - optimal for satellite imagery
          if (maxRange > 0.01) {
            zoomLevel = 13.0; // Large polygon - show more context
          } else if (maxRange > 0.005) {
            zoomLevel = 14.0; // Medium polygon - optimal for satellite imagery
          } else if (maxRange > 0.001) {
            zoomLevel = 15.0; // Small polygon - still readable
          } else {
            zoomLevel = 16.0; // Very small polygon - detailed view
          }
          
          print('🎯 Calculated zoom level: $zoomLevel (polygon range: $maxRange)');
          
          // Navigate to center of polygon with appropriate zoom
          print('🎬 Navigating to polygon center: $center with zoom $zoomLevel');
          _mapController.moveAndRotate(center, zoomLevel, 0.0);
          
          // Verify the move worked
          Future.delayed(const Duration(milliseconds: 100), () {
            print('🎯 Final map center: ${_mapController.camera.center}');
            print('🎯 Map zoom: ${_mapController.camera.zoom}');
          });
          
          print('✅ Polygon centering completed for plot ${plot.plotNo}');
        } else {
          print('⚠️ Polygon has insufficient points (${coordinates.length}) for plot ${plot.plotNo}');
          // Fallback to plot coordinates if polygon is invalid
          if (plot.latitude != null && plot.longitude != null) {
            final plotLocation = LatLng(plot.latitude!, plot.longitude!);
            _mapController.moveAndRotate(plotLocation, 14.0, 0.0);
            print('🎯 Fallback navigation to plot coordinates: $plotLocation');
          }
        }
      } else {
        print('⚠️ No polygon coordinates available for plot ${plot.plotNo}');
        print('⚠️ Falling back to plot coordinates: ${plot.latitude}, ${plot.longitude}');
        
        // Fallback to plot coordinates if no polygon
        if (plot.latitude != null && plot.longitude != null) {
          final plotLocation = LatLng(plot.latitude!, plot.longitude!);
          _mapController.moveAndRotate(plotLocation, 14.0, 0.0);
          print('🎯 Fallback navigation to plot coordinates: $plotLocation');
        }
      }
    } catch (e) {
      print('❌ Error centering on plot polygon: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      
      // Final fallback to plot coordinates
      if (plot.latitude != null && plot.longitude != null) {
        final plotLocation = LatLng(plot.latitude!, plot.longitude!);
        _mapController.moveAndRotate(plotLocation, 13.0, 0.0);
        print('🎯 Emergency fallback navigation to plot coordinates: $plotLocation');
      }
    }
  }

  void _updateActiveFilters() {
    _activeFilters.clear();
    
    if (_selectedEvent != null) {
      _activeFilters.add(_selectedEvent!);
    }
    if (_selectedDhaPhase != null) {
      _activeFilters.add(_selectedDhaPhase!);
    }
    if (_selectedPlotType != null) {
      _activeFilters.add(_selectedPlotType!);
    }
    if (_selectedPlotSize != null) {
      _activeFilters.add(_selectedPlotSize!);
    }
    if (_selectedSector != null) {
      _activeFilters.add('Sector ${_selectedSector}');
    }
    if (_selectedStatus != null) {
      _activeFilters.add(_selectedStatus!);
    }
    if (_priceRange.start > 0 || _priceRange.end < 10000000) {
      _activeFilters.add('Price Range');
    }
    if (_tokenAmountRange.start > 0 || _tokenAmountRange.end < 1000000) {
      _activeFilters.add('Token Range');
    }
    if (_hasInstallmentPlans) {
      _activeFilters.add('Has Installments');
    }
    if (_isAvailableOnly) {
      _activeFilters.add('Available Only');
    }
    if (_hasRemarks) {
      _activeFilters.add('Has Remarks');
    }
    
    if (_activeFilters.isEmpty) {
      _activeFilters.add('All Plots');
    }
    
    // Update bottom sheet visibility after updating filters
    _updateBottomSheetVisibility();
  }

  // Performance optimization: Handle zoom level changes
  void _handleZoomChange(int newZoomLevel) {
    // Update zoom level
    setState(() {
      _zoom = newZoomLevel.toDouble();
    });
    
    // Load amenities when zoom level is appropriate and not already loaded
    if (newZoomLevel >= 12 && _showAmenities && !_amenitiesLoaded && !_isLoadingAmenities) {
      print('Loading amenities on zoom change to level: $newZoomLevel');
      _loadAmenitiesMarkers();
    }
    
    // Plots API removed - no longer handling zoom level changes for plots
  }

  /// Build town plan legend
  Widget _buildTownPlanLegend() {
    return SizedBox(
      width: 200,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with toggle
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showTownPlanLegend = !_showTownPlanLegend;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF20B2AA).withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.map,
                        color: const Color(0xFF20B2AA),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Town Plan',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A2E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        _showTownPlanLegend ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Legend content (collapsible)
              if (_showTownPlanLegend) ...[
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Current layer info
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF20B2AA).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF20B2AA).withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.layers, color: const Color(0xFF20B2AA), size: 14),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getTownPlanLayerName(_selectedTownPlanLayer),
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: const Color(0xFF20B2AA),
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Legend items
                      _buildTownPlanLegendItem('Planned Area', const Color(0xFF20B2AA), Icons.location_city),
                      const SizedBox(height: 4),
                      _buildTownPlanLegendItem('Development Zone', const Color(0xFF4CAF50), Icons.home_work),
                      const SizedBox(height: 4),
                      _buildTownPlanLegendItem('Infrastructure', const Color(0xFF2196F3), Icons.construction),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build town plan legend item
  Widget _buildTownPlanLegendItem(String label, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: const Color(0xFF1A1A2E),
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Get town plan layer display name
  String _getTownPlanLayerName(String layerId) {
    final layerNames = {
      'phase1': 'Phase 1',
      'phase2': 'Phase 2',
      'phase3': 'Phase 3',
      'phase4': 'Phase 4',
      'phase4_gv': 'Phase 4 GV',
      'phase4_rvs-updated': 'Phase 4 RVS',
      'phase5': 'Phase 5',
      'phase6': 'Phase 6',
    };
    return layerNames[layerId] ?? layerId;
  }

  /// Validate plot against town plan
  bool _validatePlotAgainstTownPlan(PlotModel plot) {
    if (!_showTownPlan) return true; // No validation if town plan is not shown
    
    // Get the plot's phase and compare with selected town plan layer
    final plotPhase = plot.phase?.toLowerCase().replaceAll(' ', '');
    final selectedLayer = _selectedTownPlanLayer.toLowerCase();
    
    // Check if plot phase matches the selected town plan layer
    if (plotPhase != null && selectedLayer.isNotEmpty) {
      // Direct match
      if (plotPhase == selectedLayer) return true;
      
      // Handle special cases for the 8 available layers
      if (selectedLayer == 'phase4_rvs-updated' && plotPhase == 'rvs') return true;
      if (selectedLayer == 'phase4_gv' && plotPhase == 'phase4gv') return true;
      if (selectedLayer == 'phase4_rvs-updated' && plotPhase == 'phase4rvs') return true;
    }
    
    return false; // Plot doesn't align with town plan
  }

  /// Get plot validation status
  String _getPlotValidationStatus(PlotModel plot) {
    if (!_showTownPlan) return 'No validation';
    
    final isValid = _validatePlotAgainstTownPlan(plot);
    return isValid ? 'Aligned with town plan' : 'Not aligned with town plan';
  }

  /// Get plot validation color
  Color _getPlotValidationColor(PlotModel plot) {
    if (!_showTownPlan) return Colors.grey;
    
    final isValid = _validatePlotAgainstTownPlan(plot);
    return isValid ? Colors.green : Colors.red;
  }

  /// Center map on selected town plan layer coordinates
  void _centerMapOnTownPlanLayer(String layerId) {
    final layerCoordinates = {
      'phase1': LatLng(33.5348, 73.0951),
      'phase2': LatLng(33.52844, 73.15383),
      'phase3': LatLng(33.49562, 73.15650),
      'phase4': LatLng(33.52165, 73.07213),
      'phase4_gv': LatLng(33.50073, 73.04962),
      'phase4_rvs-updated': LatLng(33.48358, 72.99944),
      'phase5': LatLng(33.52335, 73.20746),
      'phase6': LatLng(33.55784, 73.28214),
    };

    final coordinates = layerCoordinates[layerId];
    if (coordinates != null) {
      _mapController.move(coordinates, 16.0); // Zoom level 16 for detailed view
      setState(() {
        _mapCenter = coordinates;
        _zoom = 16.0;
      });
    }
  }

  /// Build dynamic amenities legend with toggle functionality
  Widget _buildAmenitiesLegend() {
    return SizedBox(
      width: 200, // Increased width for better readability
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with toggle button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showAmenitiesLegend = !_showAmenitiesLegend;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _showAmenities ? const Color(0xFF20B2AA).withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: _showAmenities ? const Color(0xFF20B2AA) : Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Amenities',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _showAmenities ? const Color(0xFF20B2AA) : Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Toggle button for amenities visibility
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showAmenities = !_showAmenities;
                          });
                          
                          // Load amenities when toggled on and not already loaded
                          if (_showAmenities && !_amenitiesLoaded && !_isLoadingAmenities) {
                            print('Loading amenities on toggle...');
                            _loadAmenitiesMarkers();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _showAmenities ? const Color(0xFF20B2AA) : Colors.grey,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            _showAmenities ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Collapse/expand button
                      Icon(
                        _showAmenitiesLegend ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Legend content (collapsible)
              if (_showAmenitiesLegend) ...[
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_zoom < 12.0) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.zoom_in, color: Colors.orange, size: 14),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Zoom in to see amenities',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: Colors.orange[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        _buildAmenityLegendItem('Park', Colors.green, Icons.park),
                        const SizedBox(height: 6),
                        _buildAmenityLegendItem('Masjid', Colors.blue, Icons.mosque),
                        const SizedBox(height: 6),
                        _buildAmenityLegendItem('School', Colors.orange, Icons.school),
                        const SizedBox(height: 6),
                        _buildAmenityLegendItem('Health Facility', Colors.red, Icons.local_hospital),
                        const SizedBox(height: 6),
                        _buildAmenityLegendItem('Graveyard', Colors.brown, Icons.place),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build bottom sheet for filtered plots (matches web app design)
  Widget _buildBottomSheet() {
    // Show bottom sheet if filters are applied OR if a plot is selected
    if (!_isBottomSheetVisible && _selectedPlot == null) {
      return const SizedBox.shrink();
    }

    return DraggableScrollableSheet(
      controller: _bottomSheetController,
      initialChildSize: _showSelectedPlotDetails ? 0.4 : 0.2, // Show more space when plot is selected
      minChildSize: 0.15, // Minimum 15% of screen height
      maxChildSize: _showSelectedPlotDetails ? 0.7 : 0.75, // Reduced to account for bottom navigation bar
      builder: (context, scrollController) {
        // Initialize the bottom sheet controller
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isBottomSheetInitialized) {
            setState(() {
              _isBottomSheetInitialized = true;
            });
          }
        });
        return Container(
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar with expand/collapse controls
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Handle bar (moved to left)
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Expand/Collapse button (moved to extreme right, no background)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isBottomSheetExpanded = !_isBottomSheetExpanded;
                        });
                        
                        if (_isBottomSheetExpanded) {
                          // Expand to appropriate size based on content
                          if (_showSelectedPlotDetails) {
                            _safeAnimateBottomSheet(0.6);
                        } else {
                          _safeAnimateBottomSheet(0.75);
                        }
                        } else {
                          // Collapse to minimum size
                          _safeAnimateBottomSheet(0.15);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.transparent, // Remove background color
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          _isBottomSheetExpanded ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                          color: Colors.grey[600], // Change to grey color
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Header with plot count and tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Plot count badge and title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3C90),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_plots.length} plots',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Filtered Results',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        // Close button for bottom sheet
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isBottomSheetVisible = false;
                              _isBottomSheetExpanded = false;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Tabs (List View / Selected)
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isBottomSheetExpanded = true;
                                _showSelectedPlotDetails = false;
                              });
                              _safeAnimateBottomSheet(0.75);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: _showSelectedPlotDetails ? Colors.grey[300]! : const Color(0xFF1E3C90),
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Text(
                                'List View',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _showSelectedPlotDetails ? Colors.grey[600] : const Color(0xFF1E3C90),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (_selectedPlotDetails != null) {
                                setState(() {
                                  _showSelectedPlotDetails = true;
                                  _isBottomSheetExpanded = true;
                                });
                                _safeAnimateBottomSheet(0.6);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: _showSelectedPlotDetails ? const Color(0xFF1E3C90) : Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                'Selected',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: _showSelectedPlotDetails ? const Color(0xFF1E3C90) : Colors.grey[600],
                                    ),
                                  ),
                                  if (_selectedPlotDetails != null) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1E3C90),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '1',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                                  ],
                      ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search By Plot Number, Sector...',
                      hintStyle: TextStyle(color: Colors.grey[500]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Plot list or selected plot details
              Expanded(
                child: _showSelectedPlotDetails && _selectedPlotDetails != null
                    ? _buildSelectedPlotContent()
                    : _plots.isEmpty
                        ? Center(
                            child: Text(
                              'No plots found matching your filters',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom: 20, // Add bottom padding to prevent content from being cut off
                            ),
                            itemCount: _plots.length,
                            itemBuilder: (context, index) {
                              final plot = _plots[index];
                              return _buildPlotCard(plot);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build individual plot card
  Widget _buildPlotCard(PlotModel plot) {
    return GestureDetector(
      onTap: () {
        print('🏠 Plot card tapped: ${plot.plotNo}');
        _selectPlot(plot);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
          child: Stack(
            children: [
              // Red vertical bar on the left
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 4,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
              ),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with logo and plot info
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // DHA Logo with text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E3C90),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.home,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'DHA',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3C90),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text(
                                 'Plot ${plot.plotNo}',
                                 style: const TextStyle(
                                   fontSize: 16,
                                   fontWeight: FontWeight.w700,
                                   color: Colors.black,
                                   letterSpacing: 0.3,
                                 ),
                               ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.green[600],
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'Available',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // View Details button
                        GestureDetector(
                          onTap: () {
                            _selectPlot(plot);
                            setState(() {
                              _showSelectedPlotDetails = true;
                            });
                            _safeAnimateBottomSheet(0.6);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF1E3C90).withOpacity(0.3)),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1E3C90).withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'View Details',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1E3C90),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Plot details chips with icons in 2x2 grid with colors
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildDetailChipWithIcon(
                            Icons.location_on,
                            'Sector ${plot.sector}',
                            backgroundColor: Colors.blue[50],
                            iconColor: Colors.blue[600],
                            textColor: Colors.blue[700],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDetailChipWithIcon(
                            Icons.home,
                            'St. ${plot.streetNo}',
                            backgroundColor: Colors.green[50],
                            iconColor: Colors.green[600],
                            textColor: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildDetailChipWithIcon(
                            Icons.straighten,
                            plot.size,
                            backgroundColor: Colors.orange[50],
                            iconColor: Colors.orange[600],
                            textColor: Colors.orange[700],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDetailChipWithIcon(
                            Icons.flag,
                            plot.phase,
                            backgroundColor: Colors.purple[50],
                            iconColor: Colors.purple[600],
                            textColor: Colors.purple[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // RVS ribbon in bottom-right corner
              if (plot.phase == 'RVS')
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 50,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'RVS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
      ),
    );
  }

  /// Build detail chip with icon and colors (enhanced visibility)
  Widget _buildDetailChipWithIcon(IconData icon, String text, {Color? backgroundColor, Color? iconColor, Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (iconColor ?? Colors.grey[600]!).withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (iconColor ?? Colors.grey[600]!).withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: iconColor ?? Colors.grey[600],
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: textColor ?? Colors.grey[600],
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// Build detail chip
  Widget _buildDetailChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  /// Build small plot info card positioned on the plot location (attached to plot boundary)
  Widget _buildPlotDetailsPopup() {
    if (_selectedPlot == null || _selectedPlotDetails == null) {
      return const SizedBox.shrink();
    }

    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final popupWidth = 240.0; // Slightly larger for better visibility
    final popupHeight = 180.0; // Slightly larger for better visibility
    
    // Calculate position to be attached to the plot polygon
    double left, top;
    
    // Try to get the plot's screen position from polygon coordinates
    final plotScreenPosition = _calculatePlotScreenPosition();
    
    if (plotScreenPosition != null) {
      // Position the card attached to the plot polygon center - like second image
      left = plotScreenPosition.dx - (popupWidth / 2); // Center horizontally on plot
      top = plotScreenPosition.dy - popupHeight - 20; // Position above plot with margin
      
      // If the card would be too close to the bottom sheet area, position it to the side
      final bottomSheetArea = screenSize.height * 0.25; // Bottom sheet takes 25% of screen
      if (top + popupHeight > screenSize.height - bottomSheetArea) {
        // Position to the right of the plot instead
        left = plotScreenPosition.dx + 15; // 15px to the right of plot
        top = plotScreenPosition.dy - (popupHeight / 2); // Center vertically on plot
        
        // If it would go off screen to the right, position to the left instead
        if (left + popupWidth > screenSize.width - 10) {
          left = plotScreenPosition.dx - popupWidth - 15; // 15px to the left of plot
        }
      }
      
      print('📍 Small plot info card positioned attached to plot at: left=$left, top=$top');
      print('📍 Plot screen position: $plotScreenPosition');
    } else if (_selectedPlot!.latitude != null && _selectedPlot!.longitude != null) {
      // Fallback: Use plot center coordinates for positioning
      print('📍 Using plot center coordinates: ${_selectedPlot!.latitude}, ${_selectedPlot!.longitude}');
      
      // Position attached to plot center coordinates - center of screen
      left = (screenSize.width - popupWidth) / 2;
      top = screenSize.height * 0.25; // Position in upper area, above bottom sheet
      
      print('📍 Small plot info card positioned using center coordinates: left=$left, top=$top');
    } else {
      // Final fallback: Position in upper area of screen
      left = (screenSize.width - popupWidth) / 2;
      top = screenSize.height * 0.25; // Position in upper area, above bottom sheet
      print('📍 Small plot info card positioned at screen center: left=$left, top=$top');
    }
    
    // Ensure popup stays within screen bounds and avoid app bar area
    left = left.clamp(10.0, screenSize.width - popupWidth - 10);
    top = top.clamp(80.0, screenSize.height - popupHeight - 150); // Keep away from bottom sheet area
    
    return Positioned(
      left: left,
      top: top,
      child: SmallPlotInfoCard(
        plot: _selectedPlot!,
        onClose: () {
          setState(() {
            _selectedPlot = null;
            _selectedPlotDetails = null;
            _showProjectDetails = false;
            _showSelectedPlotDetails = false;
            // Collapse bottom sheet when plot is deselected
            _safeAnimateBottomSheet(0.15);
          });
        },
        onViewDetails: () {
          // Show detailed information in the Selected tab and expand bottom sheet
          setState(() {
            _showSelectedPlotDetails = true;
          });
          _safeAnimateBottomSheet(0.6);
        },
      ),
    );
  }



  /// Show plot details modal
  void _showPlotDetailsModal() {
    if (_selectedPlot == null) return;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: PlotDetailsModal(
          plot: _selectedPlot!,
          onClose: () {
            Navigator.of(context).pop();
          },
          onBookNow: () {
            Navigator.of(context).pop();
            // Navigate to login screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ),
            );
          },
          onViewDetails: () {
            // Already showing details
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  /// Show plot details modal for a specific plot
  void _showPlotDetailsModalForPlot(PlotModel plot) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: PlotDetailsModal(
          plot: plot,
          onClose: () {
            Navigator.of(context).pop();
          },
          onBookNow: () {
            Navigator.of(context).pop();
            // Navigate to login screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginScreen(),
              ),
            );
          },
          onViewDetails: () {
            // Already showing details
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Build selected plot content
  Widget _buildSelectedPlotContent() {
    if (_isLoadingPlotDetails) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF20B2AA)),
            ),
            SizedBox(height: 16),
            Text(
              'Loading plot details...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    if (_selectedPlot == null) {
      return const Center(
        child: Text(
          'No plot selected',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      );
    }

    return SelectedPlotDetailsWidget(
      plot: _selectedPlot!,
      onBookNow: () {
        // Navigate to login screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      },
      onClearSelection: _clearPlotSelection,
    );
  }

  /// Build dynamic boundaries legend with toggle functionality
  Widget _buildBoundariesLegend() {
    return SizedBox(
      width: 200, // Same width as amenities legend
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with toggle button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showPhaseBoundariesLegend = !_showPhaseBoundariesLegend;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _showBoundaries ? const Color(0xFF1E3C90).withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.layers,
                        color: _showBoundaries ? const Color(0xFF1E3C90) : Colors.grey,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Boundaries',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _showBoundaries ? const Color(0xFF1E3C90) : Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Toggle button for boundaries visibility
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showBoundaries = !_showBoundaries;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _showBoundaries ? const Color(0xFF1E3C90) : Colors.grey,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            _showBoundaries ? Icons.visibility : Icons.visibility_off,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Collapse/expand button
                      Icon(
                        _showPhaseBoundariesLegend ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Legend content (collapsible)
              if (_showPhaseBoundariesLegend) ...[
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_boundaryPolygons.isEmpty) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.info_outline, color: Colors.grey[600], size: 14),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Loading boundaries...',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        ..._boundaryPolygons.take(4).map((boundary) => 
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: _buildLegendItem(boundary.phaseName, boundary.color),
                          ),
                        ),
                        if (_boundaryPolygons.length > 4)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              '+ ${_boundaryPolygons.length - 4} more',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

}
