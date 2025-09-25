import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/language_service.dart';
import '../providers/plots_provider.dart';
import '../data/models/plot_model.dart';
import '../data/monuments_data.dart';
import '../core/services/polygon_renderer_service.dart';
import '../core/services/enhanced_polygon_service.dart';
import '../ui/widgets/enhanced_plot_info_card.dart';
import '../core/services/instant_boundary_service.dart';
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
import '../data/models/plot_details_model.dart';
import '../core/services/plot_details_service.dart';

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
  double _zoom = 12.0;
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
  List<BoundaryPolygon> _boundaryPolygons = [];
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
  
  // Performance optimization
  Timer? _debounceTimer;
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
      
      if (plot.latitude != null && plot.longitude != null) {
        final plotLocation = LatLng(plot.latitude!, plot.longitude!);
        
        // Animate to plot location using flutter_map API
        _mapController.move(plotLocation, 16.0);
        
        // Select the plot
        setState(() {
          _selectedPlot = plot;
          _showProjectDetails = true;
          _selectedAmenity = null;
        });
        
        print('✅ Navigated to plot ${plot.plotNo} at ${plot.latitude}, ${plot.longitude}');
      } else {
        print('❌ Plot ${plot.plotNo} has no coordinates, cannot navigate');
      }
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
      // Load boundaries instantly (from assets)
      await _loadBoundaryPolygons();
      
      // Load basic plot data (fast API call)
      await _loadBasicPlots();
      
      print('Essential data loaded - map ready for interaction');
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
      // Try to get boundaries instantly from cache first
      final instantBoundaries = InstantBoundaryService.getBoundariesInstantly();
      if (instantBoundaries.isNotEmpty) {
        setState(() {
          _boundaryPolygons = instantBoundaries;
          _isLoadingBoundaries = false;
        });
        print('Instant loading: Loaded ${instantBoundaries.length} boundaries from cache');
        return;
      }
      
      // If not cached, load with optimization
      final boundaries = await InstantBoundaryService.loadAllBoundaries();
      setState(() {
        _boundaryPolygons = boundaries;
        _isLoadingBoundaries = false;
      });
      print('Instant loading: Loaded ${boundaries.length} boundaries with optimization');
    } catch (e) {
      print('Error loading boundary polygons: $e');
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
    print('=== AMENITIES FILTERING DEBUG ===');
    print('_showAmenities: $_showAmenities');
    print('zoomLevel: $zoomLevel');
    print('amenityMarkers.length: ${amenityMarkers.length}');
    
    // Null safety check
    if (amenityMarkers.isEmpty) {
      print('No amenity markers available');
      return [];
    }
    
    // Lazy loading: Only show amenities at zoom level 12 and above
    if (zoomLevel < 12.0) {
      print('Zoom level too low: $zoomLevel < 12.0 - No amenities shown');
      return [];
    }
    
    // Progressive loading: Show fewer amenities at lower zoom levels
    List<AmenityMarker> filteredMarkers = amenityMarkers;
    if (zoomLevel < 14.0) {
      // Show only 30% of amenities at zoom levels 12-13
      final maxAmenities = (amenityMarkers.length * 0.3).round();
      // Use sampling instead of .take() to ensure all phases are represented
      filteredMarkers = _sampleAmenitiesEvenly(amenityMarkers, maxAmenities);
      print('Limited to $maxAmenities amenities for zoom level $zoomLevel (evenly sampled)');
    } else if (zoomLevel < 16.0) {
      // Show 60% of amenities at zoom levels 14-15
      final maxAmenities = (amenityMarkers.length * 0.6).round();
      // Use sampling instead of .take() to ensure all phases are represented
      filteredMarkers = _sampleAmenitiesEvenly(amenityMarkers, maxAmenities);
      print('Limited to $maxAmenities amenities for zoom level $zoomLevel (evenly sampled)');
    }
    
    print('Rendering ${filteredMarkers.length} amenity MARKERS with dynamic sizing');
    
    // Create markers with null safety
    final markers = <Marker>[];
    for (final amenityMarker in filteredMarkers) {
      try {
        final marker = _createDynamicAmenityMarker(amenityMarker, zoomLevel);
        markers.add(marker);
      } catch (e) {
        print('Error creating dynamic amenity marker: $e');
        continue;
      }
    }
    
    return markers;
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

  /// Get amenity color based on type
  Color _getAmenityColor(String amenityType) {
    try {
      if (amenityType.isEmpty) {
        return Colors.grey;
      }
      
      switch (amenityType.toLowerCase()) {
        case 'park':
          return Colors.green;
        case 'masjid':
          return Colors.blue;
        case 'school':
          return Colors.orange;
        case 'play ground':
          return Colors.lightGreen;
        case 'graveyard':
          return Colors.brown;
        case 'health facility':
          return Colors.red;
        default:
          return Colors.purple;
      }
    } catch (e) {
      print('Error getting amenity color for $amenityType: $e');
      return Colors.grey;
    }
  }

  /// Get amenity icon based on type
  IconData _getAmenityIcon(String amenityType) {
    try {
      if (amenityType.isEmpty) {
        return Icons.place;
      }
      
      switch (amenityType.toLowerCase()) {
        case 'park':
          return Icons.park;
        case 'masjid':
          return Icons.mosque;
        case 'school':
          return Icons.school;
        case 'play ground':
          return Icons.sports_soccer;
        case 'graveyard':
          return Icons.place;
        case 'health facility':
          return Icons.local_hospital;
        default:
          return Icons.place;
      }
    } catch (e) {
      print('Error getting amenity icon for $amenityType: $e');
      return Icons.place;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _debounceTimer?.cancel();
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
              // Boundary polygons
              PolygonLayer(
                polygons: _getBoundaryPolygons(),
              ),
              // Plot polygons - showing filtered plots
              if (_showPlotPolygons)
              PolygonLayer(
                polygons: _getFilteredPlotPolygons(),
              ),
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
          
          // Small loading indicator in top-right corner (non-blocking)
          if (_isDataLoading)
            Positioned(
              top: 100,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF20B2AA)),
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Loading data...',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
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
                              fontSize: 20,
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
                // Apply filters using modern filter manager
                _debounceTimer?.cancel();
                _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                  setState(() {
                    _selectedPlotType = filters['plotType'];
                    _selectedDhaPhase = filters['dhaPhase'];
                    _selectedPlotSize = filters['plotSize'];
                    _priceRange = filters['priceRange'] ?? const RangeValues(5475000, 565000000);
                    _activeFilters = List<String>.from(filters['activeFilters'] ?? []);
                  });
                  
                  // Apply filters to modern filter manager
                  _applyFiltersToManager(filters);
                  
                  // Update bottom sheet visibility
                  _updateBottomSheetVisibility();
                });
              },
              initialFilters: {
                'plotType': _selectedPlotType,
                'dhaPhase': _selectedDhaPhase,
                'plotSize': _selectedPlotSize,
                'priceRange': _priceRange,
              },
              // Plots API removed - no longer using plot filters
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
    if (!_showBoundaries) return [];
    
    final polygons = <Polygon>[];
    
    for (final boundary in _boundaryPolygons) {
      for (final polygonCoords in boundary.polygons) {
        if (polygonCoords.length >= 3) {
          polygons.add(
            Polygon(
              points: polygonCoords,
              color: boundary.color.withOpacity(0.2),
              borderColor: boundary.color,
              borderStrokeWidth: 2.0,
              label: boundary.phaseName,
              labelStyle: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                shadows: const [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 2,
                  ),
                ],
              ),
              labelPlacement: PolygonLabelPlacement.polylabel,
            ),
          );
        }
      }
    }
    
    return polygons;
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
      
      if (_plots.isEmpty) {
        print('❌ No filtered plots to render (plots count: ${_plots.length})');
        return [];
      }

      // Create simple rectangular polygons for each plot if no complex polygons exist
      final polygons = <Polygon>[];
      
      for (final plot in _plots.take(50)) { // Limit to 50 for performance
        if (plot.latitude != null && plot.longitude != null) {
          // Create a simple rectangular polygon around the plot center
          final center = LatLng(plot.latitude!, plot.longitude!);
          final offset = 0.0001; // Small offset to create a rectangle
          
          final plotPolygon = [
            LatLng(center.latitude - offset, center.longitude - offset),
            LatLng(center.latitude + offset, center.longitude - offset),
            LatLng(center.latitude + offset, center.longitude + offset),
            LatLng(center.latitude - offset, center.longitude + offset),
            LatLng(center.latitude - offset, center.longitude - offset), // Close polygon
          ];
          
          final isSelected = _selectedPlot != null && _selectedPlot!.plotNo == plot.plotNo;
          
          polygons.add(
            Polygon(
              points: plotPolygon,
              color: isSelected 
                ? const Color(0xFF1E3C90).withOpacity(0.4) // Blue for selected
                : const Color(0xFFFF9800).withOpacity(0.3), // Orange for others (like in image)
              borderColor: isSelected 
                ? const Color(0xFF1E3C90) 
                : const Color(0xFFFF9800),
              borderStrokeWidth: isSelected ? 3.0 : 2.0,
              label: plot.plotNo,
              labelStyle: TextStyle(
                color: Colors.white,
                fontSize: isSelected ? 14 : 12,
                fontWeight: FontWeight.bold,
                shadows: const [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 2,
                  ),
                ],
              ),
              labelPlacement: PolygonLabelPlacement.polylabel,
            ),
          );
        }
      }
      
      print('✅ Created ${polygons.length} plot polygons');
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
      
      setState(() {
        _isLoadingPlotDetails = true;
        _showSelectedPlotDetails = true;
        _selectedPlot = plot; // Set selected plot immediately
        _showPlotPolygons = true; // Ensure polygons are visible
      });

      // Navigate to plot location on map first
      if (plot.latitude != null && plot.longitude != null) {
        final plotLocation = LatLng(plot.latitude!, plot.longitude!);
        _mapController.move(plotLocation, 16.0);
        print('🗺️ Navigating to plot location: ${plot.latitude}, ${plot.longitude}');
      }

      // Fetch detailed plot information
      final plotDetails = await PlotDetailsService.fetchPlotDetails(plot.plotNo);
      
      if (plotDetails != null) {
        setState(() {
          _selectedPlotDetails = plotDetails;
          _isLoadingPlotDetails = false;
        });

        // Expand bottom sheet to show selected plot details
        _safeAnimateBottomSheet(0.7);

        print('✅ Plot selected successfully: ${plot.plotNo}');
        print('✅ Plot polygon should be highlighted in blue');
        print('✅ Plot info card should be visible on map');
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
    if (plot.latitude != null && plot.longitude != null) {
      final plotLocation = LatLng(plot.latitude!, plot.longitude!);
      _mapController.move(plotLocation, 16.0);
      
      setState(() {
        _selectedPlot = plot;
        _showProjectDetails = true;
        _selectedAmenity = null;
      });
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
    // Only show bottom sheet if filters are applied
    if (!_isBottomSheetVisible) {
      return const SizedBox.shrink();
    }

    return DraggableScrollableSheet(
      controller: _bottomSheetController,
      initialChildSize: _showSelectedPlotDetails ? 0.4 : 0.15, // Show more space when plot is selected
      minChildSize: 0.15, // Minimum 15% of screen height
      maxChildSize: _showSelectedPlotDetails ? 0.7 : 0.85, // Less coverage when plot is selected
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
                            _safeAnimateBottomSheet(0.7);
                        } else {
                          _safeAnimateBottomSheet(0.85);
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
                              _safeAnimateBottomSheet(0.85);
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
                                _safeAnimateBottomSheet(0.7);
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
                            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                        // View button
                        Container(
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
                            'View',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1E3C90),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
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

  /// Build plot details popup positioned on the plot location
  Widget _buildPlotDetailsPopup() {
    if (_selectedPlot == null || _selectedPlotDetails == null) {
      return const SizedBox.shrink();
    }

    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final popupWidth = 220.0; // Smaller width for compact display
    final popupHeight = 120.0; // Smaller height for compact display
    
    // Calculate position to be attached to the plot polygon
    // Position the card to appear to be "attached" to the plot
    double left, top;
    
    if (_selectedPlot!.latitude != null && _selectedPlot!.longitude != null) {
      // Position the card to appear attached to the plot polygon
      // Position it in the upper portion of the screen, not covering the whole screen
      left = screenSize.width * 0.1; // 10% from left edge
      top = screenSize.height * 0.08; // 8% from top (higher up)
    } else {
      // Fallback to center positioning
      left = (screenSize.width - popupWidth) / 2;
      top = screenSize.height * 0.2;
    }
    
    // Ensure popup stays within screen bounds
    left = left.clamp(10.0, screenSize.width - popupWidth - 10);
    top = top.clamp(60.0, screenSize.height - popupHeight - 60);
    
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: popupWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with close button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF1E3C90),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    'Plot ${_selectedPlot!.plotNo}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPlot = null;
                        _selectedPlotDetails = null;
                        _showProjectDetails = false;
                      });
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Status badges
                  Row(
                    children: [
                      _buildStatusBadge('Residential', Colors.red),
                      const SizedBox(width: 6),
                      _buildStatusBadge('Selected', Colors.blue),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Plot details - compact version
                  _buildCompactPopupDetailRow('Phase', _selectedPlotDetails!.phase),
                  _buildCompactPopupDetailRow('Street', _selectedPlotDetails!.street),
                  _buildCompactPopupDetailRow('Size', _selectedPlotDetails!.size),
                  _buildCompactPopupDetailRow('Price', 'PKR ${_formatPrice(_selectedPlotDetails!.lumpSumPrice)}'),
                  
                  const SizedBox(height: 8),
                  
                  // View Details Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showSelectedPlotDetails = true;
                        });
                        _safeAnimateBottomSheet(0.85);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3C90),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPopupDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Build compact detail row for popup
  Widget _buildCompactPopupDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 50,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
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

    if (_selectedPlotDetails == null) {
      return const Center(
        child: Text(
          'No plot details available',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SelectedPlotDetailsWidget(
        plotDetails: _selectedPlotDetails!,
        onClearSelection: _clearPlotSelection,
      ),
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
