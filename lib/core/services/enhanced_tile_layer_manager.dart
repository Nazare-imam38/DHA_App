import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'mbtiles_service.dart';

/// Enhanced Tile Layer Manager for DHA Marketplace
/// Provides dynamic tile loading, bounds checking, and performance optimization
class EnhancedTileLayerManager {
  final MapController _mapController;
  final List<DHAPhase> _activePhases = [];
  final Map<String, TileLayer> _tileLayers = {};
  final Map<String, bool> _layerVisibility = {};
  
  bool _isInitialized = false;
  LatLngBounds? _lastViewportBounds;
  Timer? _debounceTimer;

  EnhancedTileLayerManager(this._mapController);

  /// Initialize the tile layer manager
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isInitialized = true;
    print('🗺️ Enhanced Tile Layer Manager initialized');
  }

  /// Update viewport and manage tile layers dynamically
  void updateViewport(LatLngBounds viewportBounds, double zoom) {
    // Debounce viewport updates to avoid excessive processing
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _processViewportUpdate(viewportBounds, zoom);
    });
  }

  /// Process viewport update with bounds checking
  void _processViewportUpdate(LatLngBounds viewportBounds, double zoom) {
    if (_lastViewportBounds != null && 
        _boundsEqual(_lastViewportBounds!, viewportBounds)) {
      return; // No significant change
    }

    _lastViewportBounds = viewportBounds;
    
    // Only show tiles at appropriate zoom levels
    if (zoom < MBTilesService.minZoom || zoom > MBTilesService.maxZoom) {
      _hideAllLayers();
      return;
    }

    // Get phases that intersect with current viewport
    final intersectingPhases = MBTilesService.getPhasesInBounds(viewportBounds);
    
    // Update active phases
    _updateActivePhases(intersectingPhases);
    
    print('🗺️ Viewport updated: ${intersectingPhases.length} phases visible');
  }

  /// Update active phases based on viewport
  void _updateActivePhases(List<DHAPhase> newPhases) {
    // Remove phases that are no longer in viewport
    _activePhases.removeWhere((phase) => !newPhases.contains(phase));
    
    // Add new phases
    for (final phase in newPhases) {
      if (!_activePhases.contains(phase)) {
        _activePhases.add(phase);
        _createTileLayer(phase);
      }
    }
  }

  /// Create tile layer for a specific phase
  void _createTileLayer(DHAPhase phase) {
    final tileLayer = TileLayer(
      urlTemplate: 'https://tiles.dhamarketplace.com/data/${phase.id}/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.dha.marketplace',
      maxZoom: MBTilesService.maxZoom,
      minZoom: MBTilesService.minZoom,
      tileProvider: NetworkTileProvider(),
      errorTileCallback: (tile, error, stackTrace) {
        print('🚫 Tile error for ${phase.name}: $error');
        _handleTileError(phase, tile, error);
      },
      tileBuilder: (context, tileWidget, tile) {
        return _buildTileWidget(context, tileWidget, tile, phase);
      },
    );

    _tileLayers[phase.id] = tileLayer;
    _layerVisibility[phase.id] = true;
    
    print('🗺️ Created tile layer for ${phase.name}');
  }

  /// Build custom tile widget with phase-specific styling
  Widget _buildTileWidget(BuildContext context, Widget tileWidget, Tile tile, DHAPhase phase) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: phase.color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: tileWidget,
    );
  }

  /// Handle tile loading errors
  void _handleTileError(DHAPhase phase, Tile tile, Object error) {
    // Implement fallback mechanism
    print('🚫 Tile error for ${phase.name} at ${tile.coordinates}: $error');
    
    // Could implement retry logic or fallback tiles here
  }

  /// Get all active tile layers
  List<TileLayer> getActiveTileLayers() {
    return _activePhases
        .where((phase) => _layerVisibility[phase.id] == true)
        .map((phase) => _tileLayers[phase.id]!)
        .toList();
  }

  /// Toggle layer visibility
  void toggleLayerVisibility(String phaseId, bool visible) {
    _layerVisibility[phaseId] = visible;
    print('🗺️ Layer $phaseId visibility: $visible');
  }

  /// Show all layers
  void showAllLayers() {
    for (final phase in _activePhases) {
      _layerVisibility[phase.id] = true;
    }
  }

  /// Hide all layers
  void _hideAllLayers() {
    for (final phase in _activePhases) {
      _layerVisibility[phase.id] = false;
    }
  }

  /// Get phases in current viewport
  List<DHAPhase> getPhasesInViewport() {
    return List.from(_activePhases);
  }

  /// Get layer visibility status
  bool isLayerVisible(String phaseId) {
    return _layerVisibility[phaseId] ?? false;
  }

  /// Check if bounds are equal (with tolerance)
  bool _boundsEqual(LatLngBounds bounds1, LatLngBounds bounds2) {
    const tolerance = 0.0001;
    return (bounds1.south - bounds2.south).abs() < tolerance &&
           (bounds1.north - bounds2.north).abs() < tolerance &&
           (bounds1.west - bounds2.west).abs() < tolerance &&
           (bounds1.east - bounds2.east).abs() < tolerance;
  }

  /// Dispose resources
  void dispose() {
    _debounceTimer?.cancel();
    _tileLayers.clear();
    _activePhases.clear();
    _layerVisibility.clear();
    _isInitialized = false;
  }
}

/// Enhanced Tile Layer Widget
/// Provides optimized tile rendering with bounds checking
class EnhancedTileLayer extends StatelessWidget {
  final EnhancedTileLayerManager manager;
  final bool showDebugInfo;

  const EnhancedTileLayer({
    Key? key,
    required this.manager,
    this.showDebugInfo = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activeLayers = manager.getActiveTileLayers();
    
    if (activeLayers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // Render all active tile layers
        ...activeLayers.map((layer) => layer),
        
        // Debug info overlay
        if (showDebugInfo) _buildDebugOverlay(),
      ],
    );
  }

  Widget _buildDebugOverlay() {
    return Positioned(
      top: 10,
      right: 10,
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
              'Active Layers: ${manager.getPhasesInViewport().length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            ...manager.getPhasesInViewport().map((phase) => Text(
              '• ${phase.name}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
            )),
          ],
        ),
      ),
    );
  }
}

/// Tile Layer Performance Monitor
/// Tracks tile loading performance and provides optimization insights
class TileLayerPerformanceMonitor {
  final Map<String, List<Duration>> _tileLoadTimes = {};
  final Map<String, int> _tileErrorCounts = {};
  final Map<String, int> _tileSuccessCounts = {};

  /// Record tile load time
  void recordTileLoadTime(String phaseId, Duration loadTime) {
    _tileLoadTimes.putIfAbsent(phaseId, () => []);
    _tileLoadTimes[phaseId]!.add(loadTime);
    
    // Keep only last 100 measurements per phase
    if (_tileLoadTimes[phaseId]!.length > 100) {
      _tileLoadTimes[phaseId]!.removeAt(0);
    }
  }

  /// Record tile success
  void recordTileSuccess(String phaseId) {
    _tileSuccessCounts[phaseId] = (_tileSuccessCounts[phaseId] ?? 0) + 1;
  }

  /// Record tile error
  void recordTileError(String phaseId) {
    _tileErrorCounts[phaseId] = (_tileErrorCounts[phaseId] ?? 0) + 1;
  }

  /// Get average load time for a phase
  Duration getAverageLoadTime(String phaseId) {
    final times = _tileLoadTimes[phaseId];
    if (times == null || times.isEmpty) return Duration.zero;
    
    final totalMs = times.fold(0, (sum, duration) => sum + duration.inMilliseconds);
    return Duration(milliseconds: totalMs ~/ times.length);
  }

  /// Get success rate for a phase
  double getSuccessRate(String phaseId) {
    final success = _tileSuccessCounts[phaseId] ?? 0;
    final errors = _tileErrorCounts[phaseId] ?? 0;
    final total = success + errors;
    
    if (total == 0) return 1.0;
    return success / total;
  }

  /// Get performance summary
  Map<String, dynamic> getPerformanceSummary() {
    final summary = <String, dynamic>{};
    
    for (final phaseId in _tileLoadTimes.keys) {
      summary[phaseId] = {
        'averageLoadTime': getAverageLoadTime(phaseId).inMilliseconds,
        'successRate': getSuccessRate(phaseId),
        'totalTiles': (_tileSuccessCounts[phaseId] ?? 0) + (_tileErrorCounts[phaseId] ?? 0),
      };
    }
    
    return summary;
  }

  /// Clear performance data
  void clearData() {
    _tileLoadTimes.clear();
    _tileErrorCounts.clear();
    _tileSuccessCounts.clear();
  }
}
