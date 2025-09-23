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
import '../ui/widgets/plot_info_card.dart';
import '../core/services/instant_boundary_service.dart';
import '../core/services/enterprise_api_manager.dart';
import '../core/services/smart_filter_manager.dart';
import '../core/services/progressive_map_renderer.dart';
import '../core/services/amenities_geojson_service.dart' as geojson;
import 'sidebar_drawer.dart';
import '../ui/widgets/modern_filters_panel.dart';

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
  
  // Plot data
  List<PlotModel> _plots = [];
  
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
  
  // Performance optimization
  Timer? _debounceTimer;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeLocation();
    _updateActiveFilters();
    // Start data loading in background without blocking UI
    _initializeDataLoadingAsync();
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
          await SmartFilterManager.preloadCommonFilters(_plots);
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
    try {
      final plotsProvider = Provider.of<PlotsProvider>(context, listen: false);
      
      // Use enterprise API manager for fast loading
      final plots = await EnterpriseAPIManager.loadPlotsOptimized(
        center: _mapCenter,
        radius: 50.0, // 50km radius
        zoomLevel: _zoom.round(),
        useCache: true,
      );
      
      // Store plots for detailed loading
      _plots = plots;
      
      // Update provider with basic plots
      plotsProvider.setPlotsFromCache(plots);
      
      print('Basic plots loaded: ${plots.length} plots (fast loading)');
    } catch (e) {
      print('Error loading basic plots: $e');
    }
  }
  
  /// Load detailed plot data (background, with GeoJSON parsing)
  Future<void> _loadDetailedPlots() async {
    try {
      if (_plots.isEmpty) return;
      
      // Use progressive renderer for detailed data
      final detailedPlots = await ProgressiveMapRenderer.renderPlotsProgressive(
        allPlots: _plots,
        zoomLevel: _zoom,
        center: _mapCenter,
        radiusKm: 50.0,
        forceRerender: false,
      );
      
      // Update provider with detailed plots
      final plotsProvider = Provider.of<PlotsProvider>(context, listen: false);
      plotsProvider.setPlotsFromCache(detailedPlots);
      
      print('Detailed plots loaded: ${detailedPlots.length} plots (progressive rendering)');
    } catch (e) {
      print('Error loading detailed plots: $e');
    }
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
      
      for (final center in adjacentCenters) {
        await EnterpriseAPIManager.loadPlotsOptimized(
          center: center,
          radius: 25.0,
          zoomLevel: _zoom.round(),
          useCache: true,
        );
      }
      
      print('Adjacent areas preloaded for smooth exploration');
    } catch (e) {
      print('Error preloading adjacent areas: $e');
    }
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
        final icon = geojson.AmenitiesGeoJsonService.getAmenityIcon(feature.type);
        final color = geojson.AmenitiesGeoJsonService.getAmenityColor(feature.type);
        final point = feature.getMarkerCoordinates();
        
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
      filteredMarkers = amenityMarkers.take(maxAmenities).toList();
      print('Limited to $maxAmenities amenities for zoom level $zoomLevel');
    } else if (zoomLevel < 16.0) {
      // Show 60% of amenities at zoom levels 14-15
      final maxAmenities = (amenityMarkers.length * 0.6).round();
      filteredMarkers = amenityMarkers.take(maxAmenities).toList();
      print('Limited to $maxAmenities amenities for zoom level $zoomLevel');
    }
    
    print('Rendering ${filteredMarkers.length} amenity MARKERS with dynamic sizing');
    return filteredMarkers.map((amenityMarker) => _createDynamicAmenityMarker(amenityMarker, zoomLevel)).toList();
  }

  /// Create amenity marker with dynamic sizing based on zoom level
  Marker _createDynamicAmenityMarker(AmenityMarker amenityMarker, double zoomLevel) {
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
  }

  /// Get amenity icon based on type
  IconData _getAmenityIcon(String amenityType) {
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
              // Plot polygons
              Consumer<PlotsProvider>(
                builder: (context, plotsProvider, child) {
                  return PolygonLayer(
                    polygons: _getAllPolygons(plotsProvider),
                  );
                },
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
                        // Plot count indicator
                        Consumer<PlotsProvider>(
                          builder: (context, plotsProvider, child) {
                            final plotCount = plotsProvider.filteredPlots.where((plot) => 
                              plot.polygonCoordinates.isNotEmpty
                            ).length;
                            
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$plotCount Plots',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          },
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

          // Modern Filters Panel
          Positioned(
            top: 180,
            right: 8,
            child: ModernFiltersPanel(
              isVisible: _showFilters,
              onClose: () {
                setState(() {
                  _showFilters = false;
                });
              },
              onFiltersChanged: (filters) {
                // Debounce filter changes to prevent excessive updates
                _debounceTimer?.cancel();
                _debounceTimer = Timer(const Duration(milliseconds: 300), () {
                  setState(() {
                    _selectedPlotType = filters['plotType'];
                    _selectedDhaPhase = filters['dhaPhase'];
                    _selectedPlotSize = filters['plotSize'];
                    _priceRange = filters['priceRange'] ?? const RangeValues(5475000, 565000000);
                    _activeFilters = List<String>.from(filters['activeFilters'] ?? []);
                  });
                  
                  // Apply filters to the provider
                  final plotsProvider = Provider.of<PlotsProvider>(context, listen: false);
                  plotsProvider.setPriceRange(_priceRange);
                  plotsProvider.setPlotType(_selectedPlotType);
                  plotsProvider.setPhase(_selectedDhaPhase);
                  plotsProvider.setPlotSize(_selectedPlotSize);
                });
              },
              initialFilters: {
                'plotType': _selectedPlotType,
                'dhaPhase': _selectedDhaPhase,
                'plotSize': _selectedPlotSize,
                'priceRange': _priceRange,
              },
              enabledPhases: Provider.of<PlotsProvider>(context).enabledPhasesForCurrentFilters,
              enabledSizes: Provider.of<PlotsProvider>(context).enabledSizesForCurrentFilters,
            ),
          ),

          // Expandable Map Controls
          Positioned(
            bottom: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Expanded Controls (shown when _showMapControls is true)
                if (_showMapControls) ...[
                  // Toggle Amenities Button
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: FloatingActionButton(
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
                      backgroundColor: _showAmenities ? const Color(0xFF20B2AA) : Colors.grey,
                      child: Icon(
                        _showAmenities ? Icons.location_on : Icons.location_off,
                        color: Colors.white,
                      ),
                      tooltip: _showAmenities ? 'Hide Amenities' : 'Show Amenities',
                    ),
                  ),
                  // Toggle Boundaries Button
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          _showBoundaries = !_showBoundaries;
                        });
                      },
                      backgroundColor: _showBoundaries ? const Color(0xFF20B2AA) : Colors.grey,
                      child: Icon(
                        _showBoundaries ? Icons.layers : Icons.layers_outlined,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // All Phases Button
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: FloatingActionButton(
                      onPressed: () {
                        setState(() {
                          _selectedPhase = 'All Phases';
                        });
                        _centerMapOnBoundaries();
                      },
                      backgroundColor: const Color(0xFF20B2AA),
                      child: const Icon(Icons.home_work, color: Colors.white),
                    ),
                  ),
                  // Zoom In Button
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: FloatingActionButton(
                      onPressed: () {
                        _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1);
                      },
                      backgroundColor: const Color(0xFF20B2AA),
                      mini: true,
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ),
                  // Zoom Out Button
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: FloatingActionButton(
                      onPressed: () {
                        _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1);
                      },
                      backgroundColor: const Color(0xFF20B2AA),
                      mini: true,
                      child: const Icon(Icons.remove, color: Colors.white),
                    ),
                  ),
                ],
                // Main Toggle Button (always visible)
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      _showMapControls = !_showMapControls;
                    });
                  },
                  backgroundColor: const Color(0xFF20B2AA),
                  child: Icon(
                    _showMapControls ? Icons.close : Icons.menu,
                    color: Colors.white,
                  ),
                  tooltip: _showMapControls ? 'Close Controls' : 'Open Controls',
                ),
              ],
            ),
          ),

          // Dynamic Amenities Dropdown (above phase boundaries)
          if (_showAmenities)
            Positioned(
              bottom: 120, // Position above phase boundaries
              left: 20,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 200),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: _zoom >= 12.0 ? Colors.green : Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Amenities',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _zoom >= 12.0 ? Colors.green : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                     if (_zoom < 12.0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Zoom in to see amenities',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      _buildAmenityLegendItem('Park', Colors.green, Icons.park),
                      const SizedBox(height: 4),
                      _buildAmenityLegendItem('Masjid', Colors.blue, Icons.mosque),
                      const SizedBox(height: 4),
                      _buildAmenityLegendItem('School', Colors.orange, Icons.school),
                      const SizedBox(height: 4),
                      _buildAmenityLegendItem('Play Ground', Colors.lightGreen, Icons.sports_soccer),
                      const SizedBox(height: 4),
                      _buildAmenityLegendItem('Health Facility', Colors.red, Icons.local_hospital),
                      const SizedBox(height: 4),
                      _buildAmenityLegendItem('Graveyard', Colors.brown, Icons.place),
                      const SizedBox(height: 4),
                      _buildAmenityLegendItem('Petrol Pump', Colors.amber, Icons.local_gas_station),
                    ],
                  ],
                ),
              ),
            ),

          // Compact Legend (Phase Boundaries)
          Positioned(
            bottom: 20,
            left: 20,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Phase Boundaries (always visible)
                  const Text(
                    'Phase Boundaries',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._boundaryPolygons.take(3).map((boundary) => 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: _buildLegendItem(boundary.phaseName, boundary.color),
                    ),
                  ),
                  if (_boundaryPolygons.length > 3)
                    Text(
                      '+ ${_boundaryPolygons.length - 3} more',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Plot Details Card
          if (_showProjectDetails && _selectedPlot != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                child: PlotInfoCard(
                  plot: _selectedPlot!,
                  onClose: () {
                    setState(() {
                      _showProjectDetails = false;
                      _selectedPlot = null;
                    });
                  },
                ),
              ),
            ),
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

  List<Polygon> _getAllPolygons(PlotsProvider plotsProvider) {
    try {
      // Get plots with valid polygon coordinates using state manager
      final plotsWithPolygons = plotsProvider.getPlotsWithPolygons();
      
      if (plotsWithPolygons.isEmpty) {
        print('❌ No plots with valid polygons found');
        // Print polygon statistics for debugging
        final stats = plotsProvider.getPolygonStats();
        print('Polygon stats: $stats');
        return [];
      }
      
      // Limit polygons for performance (show max 100 polygons at once)
      final limitedPlots = plotsWithPolygons.take(100).toList();
      
      print('✅ Rendering ${limitedPlots.length} polygons (using state manager for performance)');
      return EnhancedPolygonService.createPlotPolygons(limitedPlots);
    } catch (e) {
      print('❌ Error creating polygons: $e');
      return [];
    }
  }

  void _handleMapTap(LatLng point) {
    final plotsProvider = Provider.of<PlotsProvider>(context, listen: false);
    final plotsWithPolygons = plotsProvider.getPlotsWithPolygons();
    
    print('Map tapped at: $point');
    print('Available plots with polygons: ${plotsWithPolygons.length}');
    
      // Check if amenities are visible (zoom level 10+)
      if (_showAmenities && _zoom >= 12.0) {
      // Find amenity at tapped point
      final tappedAmenity = _findAmenityAtPoint(point);
      if (tappedAmenity != null) {
        setState(() {
          _selectedAmenity = tappedAmenity;
          _showProjectDetails = false;
          _selectedPlot = null;
        });
        _showAmenityInfo(tappedAmenity);
        return;
      }
    }
    
    // Find plot at tapped point
    final tappedPlot = EnhancedPolygonService.findPlotAtPoint(point, plotsWithPolygons);
    
    print('Plot tapped: ${tappedPlot?.plotNo}');
    print('Show project details: ${tappedPlot != null}');
    
    setState(() {
      if (tappedPlot != null) {
        _selectedPlot = tappedPlot;
        _showProjectDetails = true;
        _selectedAmenity = null;
      } else {
        _showProjectDetails = false;
        _selectedPlot = null;
        _selectedAmenity = null;
      }
    });
  }

  /// Find amenity at a specific point
  AmenityMarker? _findAmenityAtPoint(LatLng point) {
    const double tolerance = 0.0001; // Small tolerance for click detection
    
    for (final amenity in _amenitiesMarkers) {
      final distance = _calculateDistance(point, amenity.point);
      if (distance <= tolerance) {
        return amenity;
      }
    }
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
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
            border: Border.all(color: Colors.grey[300]!, width: 0.5),
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
                      final plotsProvider = Provider.of<PlotsProvider>(context, listen: false);
                      await plotsProvider.searchPlotById(id);
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
    
    // Only reload plots if zoom level changed significantly (more than 2 levels)
    if ((newZoomLevel - _zoom.round()).abs() > 2) {
      final plotsProvider = Provider.of<PlotsProvider>(context, listen: false);
      plotsProvider.updateZoomLevel(newZoomLevel);
    }
  }
}
