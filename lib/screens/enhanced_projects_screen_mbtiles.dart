import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../core/services/mbtiles_service.dart';
import '../core/services/enhanced_tile_layer_manager.dart';
import '../core/services/tile_cache_service.dart';
import '../ui/widgets/enhanced_town_plan_controls.dart';
import '../providers/plots_provider.dart';

/// Enhanced Projects Screen with Advanced MBTiles Implementation
/// Integrates comprehensive town plan overlay system with performance optimization
class EnhancedProjectsScreenMBTiles extends StatefulWidget {
  const EnhancedProjectsScreenMBTiles({Key? key}) : super(key: key);

  @override
  State<EnhancedProjectsScreenMBTiles> createState() => _EnhancedProjectsScreenMBTilesState();
}

class _EnhancedProjectsScreenMBTilesState extends State<EnhancedProjectsScreenMBTiles>
    with TickerProviderStateMixin {
  
  // Map controllers
  late MapController _mapController;
  late EnhancedTileLayerManager _tileManager;
  
  // Map state
  LatLng _mapCenter = const LatLng(33.5227, 73.0951); // DHA Center
  double _zoom = 14.0;
  LatLngBounds? _currentViewportBounds;
  
  // Town plan state
  bool _showTownPlan = false;
  String? _selectedTownPlanLayer;
  Map<String, bool> _layerVisibility = {};
  
  // UI state
  bool _showControls = true;
  bool _showDebugInfo = false;
  
  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  // Performance monitoring
  final TileLayerPerformanceMonitor _performanceMonitor = TileLayerPerformanceMonitor();
  Timer? _viewportUpdateTimer;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _initializeServices();
    _loadInitialData();
  }

  void _initializeControllers() {
    _mapController = MapController();
    _tileManager = EnhancedTileLayerManager(_mapController);
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize tile cache service
      await TileCacheService.instance.initialize();
      
      // Initialize tile layer manager
      await _tileManager.initialize();
      
      print('✅ Enhanced MBTiles services initialized');
    } catch (e) {
      print('❌ Failed to initialize MBTiles services: $e');
    }
  }

  Future<void> _loadInitialData() async {
    try {
      // Load plots data
      final plotsProvider = Provider.of<PlotsProvider>(context, listen: false);
      await plotsProvider.fetchPlots();
      
      // Set initial viewport bounds
      _updateViewportBounds();
      
      print('✅ Initial data loaded');
    } catch (e) {
      print('❌ Failed to load initial data: $e');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _tileManager.dispose();
    _viewportUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main map
          _buildMap(),
          
          // Town plan controls
          if (_showControls)
            EnhancedTownPlanControls(
              tileManager: _tileManager,
              onLayerToggle: _onLayerToggle,
              onTownPlanToggle: _onTownPlanToggle,
              showTownPlan: _showTownPlan,
              selectedPhase: _selectedTownPlanLayer,
            ),
          
          // Debug info
          if (_showDebugInfo) _buildDebugInfo(),
          
          // Performance overlay
          _buildPerformanceOverlay(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _mapCenter,
        initialZoom: _zoom,
        minZoom: 8.0,
        maxZoom: 20.0,
        onTap: (tapPosition, point) => _handleMapTap(point),
        onPositionChanged: (MapPosition position, bool hasGesture) {
          if (hasGesture) {
            _handleMapPositionChanged(position);
          }
        },
      ),
      children: [
        // Base tile layer
        TileLayer(
          urlTemplate: _getBaseTileUrl(),
          userAgentPackageName: 'com.dha.marketplace',
          maxZoom: 18,
          tileProvider: NetworkTileProvider(),
        ),
        
        // Enhanced town plan layers
        if (_showTownPlan) _buildTownPlanLayers(),
        
        // Boundary polygons
        _buildBoundaryPolygons(),
        
        // Plot markers
        _buildPlotMarkers(),
      ],
    );
  }

  Widget _buildTownPlanLayers() {
    return EnhancedTileLayer(
      manager: _tileManager,
      showDebugInfo: _showDebugInfo,
    );
  }

  Widget _buildBoundaryPolygons() {
    // Implementation for boundary polygons
    return const SizedBox.shrink();
  }

  Widget _buildPlotMarkers() {
    // Implementation for plot markers
    return const SizedBox.shrink();
  }

  Widget _buildDebugInfo() {
    return Positioned(
      top: 100,
      left: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Debug Info',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Center: ${_mapCenter.latitude.toStringAsFixed(4)}, ${_mapCenter.longitude.toStringAsFixed(4)}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            Text(
              'Zoom: ${_zoom.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            Text(
              'Town Plan: ${_showTownPlan ? "ON" : "OFF"}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            if (_selectedTownPlanLayer != null)
              Text(
                'Layer: $_selectedTownPlanLayer',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            Text(
              'Active Layers: ${_tileManager.getPhasesInViewport().length}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceOverlay() {
    return Positioned(
      bottom: 100,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Cache: ${_formatBytes(TileCacheService.instance.getCacheStatistics()['totalSize'])}',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
            Text(
              'Usage: ${TileCacheService.instance.getCacheStatistics()['usagePercentage']}%',
              style: const TextStyle(color: Colors.white, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  String _getBaseTileUrl() {
    return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  }

  void _handleMapTap(LatLng point) {
    // Handle map tap
    print('Map tapped at: $point');
  }

  void _handleMapPositionChanged(MapPosition position) {
    if (position.center != null) {
      _mapCenter = position.center!;
      _zoom = position.zoom ?? _zoom;
      
      _updateViewportBounds();
      _updateTileLayers();
    }
  }

  void _updateViewportBounds() {
    if (_mapController.camera?.visibleBounds != null) {
      _currentViewportBounds = _mapController.camera!.visibleBounds;
      _tileManager.updateViewport(_currentViewportBounds!, _zoom);
    }
  }

  void _updateTileLayers() {
    // Debounce viewport updates
    _viewportUpdateTimer?.cancel();
    _viewportUpdateTimer = Timer(const Duration(milliseconds: 500), () {
      if (_currentViewportBounds != null) {
        _tileManager.updateViewport(_currentViewportBounds!, _zoom);
      }
    });
  }

  void _onLayerToggle(String phaseId, bool visible) {
    setState(() {
      _layerVisibility[phaseId] = visible;
    });
    
    _tileManager.toggleLayerVisibility(phaseId, visible);
    
    print('Layer $phaseId visibility: $visible');
  }

  void _onTownPlanToggle(bool showTownPlan) {
    setState(() {
      _showTownPlan = showTownPlan;
    });
    
    if (showTownPlan) {
      _showTownPlanLayerSelector();
    }
    
    print('Town plan overlay: $showTownPlan');
  }

  void _showTownPlanLayerSelector() {
    final phases = MBTilesService.getAllPhases();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => TownPlanLayerSelector(
        phases: phases,
        selectedPhase: _selectedTownPlanLayer,
        onPhaseSelected: (phaseId) {
          setState(() {
            _selectedTownPlanLayer = phaseId;
          });
          Navigator.of(context).pop();
          
          // Enable the selected layer
          _onLayerToggle(phaseId, true);
        },
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

/// MBTiles Integration Example
/// Shows how to integrate the enhanced MBTiles system into existing projects screen
class MBTilesIntegrationExample {
  
  /// Example of how to integrate MBTiles into your existing projects screen
  static Widget buildIntegratedMap({
    required MapController mapController,
    required LatLng mapCenter,
    required double zoom,
    required bool showTownPlan,
    String? selectedTownPlanLayer,
  }) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: mapCenter,
        initialZoom: zoom,
        minZoom: 8.0,
        maxZoom: 20.0,
      ),
      children: [
        // Base satellite layer
        TileLayer(
          urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
          userAgentPackageName: 'com.dha.marketplace',
          maxZoom: 18,
        ),
        
        // Town plan overlay (when enabled)
        if (showTownPlan && selectedTownPlanLayer != null)
          TileLayer(
            urlTemplate: 'https://tiles.dhamarketplace.com/data/$selectedTownPlanLayer/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.dha.marketplace',
            maxZoom: 18,
            minZoom: 14,
            tileProvider: NetworkTileProvider(),
            errorTileCallback: (tile, error, stackTrace) {
              print('Town plan tile error: $error');
            },
          ),
      ],
    );
  }
  
  /// Example of how to add town plan controls to your existing UI
  static Widget buildTownPlanToggle({
    required bool showTownPlan,
    required VoidCallback onToggle,
  }) {
    return FloatingActionButton(
      onPressed: onToggle,
      backgroundColor: showTownPlan ? const Color(0xFF4CAF50) : Colors.white,
      child: Icon(
        showTownPlan ? Icons.layers : Icons.layers_outlined,
        color: showTownPlan ? Colors.white : const Color(0xFF4CAF50),
      ),
    );
  }
}
