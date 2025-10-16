import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../core/services/dha_tileserver_service.dart';
import '../ui/widgets/sidebar_drawer.dart';
import '../ui/widgets/enhanced_phase_label.dart';

/// PURE Tileserver Projects Screen - NO GeoJSON dependencies
/// Uses only MBTiles from localhost:8090
class ProjectsScreenPureTileserver extends StatefulWidget {
  const ProjectsScreenPureTileserver({super.key});

  @override
  State<ProjectsScreenPureTileserver> createState() => _ProjectsScreenPureTileserverState();
}

class _ProjectsScreenPureTileserverState extends State<ProjectsScreenPureTileserver>
    with TickerProviderStateMixin {
  // Map controllers
  late MapController _mapController;
  late AnimationController _animationController;
  late Animation<double> _animation;

  // Map state
  LatLng _mapCenter = const LatLng(33.5348, 73.0951); // DHA Phase 1 center
  double _zoom = 12.0;
  bool _isLoading = true;

  // PURE Tileserver state - NO GeoJSON
  bool _showBoundaries = true;
  bool _tileserverConnected = false;
  String? _selectedPhase;
  List<String> _availablePhases = [];
  Map<String, dynamic> _connectionStatus = {};

  // UI state
  bool _showDebugInfo = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
    _initializeLocation();
    _testTileserverConnection();
  }

  void _initializeMap() {
    _mapController = MapController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
  }

  void _initializeLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _mapCenter = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testTileserverConnection() async {
    try {
      print('🔄 Testing PURE tileserver connection (NO GeoJSON)...');
      
      // Test connection to tileserver
      final status = await DHATileserverService.testConnection();
      setState(() {
        _connectionStatus = status;
        _tileserverConnected = status['server_running'] == true;
      });

      if (_tileserverConnected) {
        print('✅ Tileserver connected - getting phases...');
        
        // Get available phases from tileserver ONLY
        final phases = await DHATileserverService.getAvailablePhases();
        setState(() {
          _availablePhases = phases;
          if (phases.isNotEmpty) {
            _selectedPhase = phases.first;
          }
        });
        
        print('📋 Available phases from tileserver: $phases');
        _showSnackBar('Tileserver connected! ${phases.length} phases available', isError: false);
      } else {
        print('❌ Tileserver not connected');
        _showSnackBar('Tileserver not accessible. Please ensure it\'s running on localhost:8090', isError: true);
      }
    } catch (e) {
      print('❌ Error testing tileserver connection: $e');
      _showSnackBar('Error connecting to tileserver: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
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
          // Map
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
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  _handleZoomChange(position.zoom);
                }
              },
            ),
            children: [
              // Base tile layer
              TileLayer(
                urlTemplate: _getTileLayerUrl(),
                userAgentPackageName: 'com.dha.marketplace',
                maxZoom: 18,
                errorTileCallback: (tile, error, stackTrace) {
                  print('Base tile error: $error');
                },
              ),
              
              // PURE Tileserver boundary layers - NO GeoJSON
              if (_tileserverConnected && _showBoundaries) ...[
                // Load all available phases as tile layers from tileserver
                ..._getTileserverBoundaryLayers(),
              ],
              
              // Phase labels for tileserver boundaries
              if (_showBoundaries && _tileserverConnected && _availablePhases.isNotEmpty)
                MarkerLayer(
                  markers: _getPhaseLabelMarkers(),
                ),
              
              // Fallback: Show message if tileserver not connected
              if (!_tileserverConnected && _showBoundaries)
                Container(
                  color: Colors.red.withOpacity(0.1),
                  child: const Center(
                    child: Text(
                      'Tileserver not connected\nBoundaries unavailable',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading map...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Tileserver controls
          Positioned(
            top: 16,
            right: 16,
            child: _buildTileserverControls(),
          ),
          
          // Debug info
          if (_showDebugInfo)
            Positioned(
              bottom: 16,
              left: 16,
              child: _buildDebugInfo(),
            ),
        ],
      ),
    );
  }

  Widget _buildTileserverControls() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _tileserverConnected ? Icons.check_circle : Icons.error,
                  color: _tileserverConnected ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tileserver',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _testTileserverConnection,
                  tooltip: 'Refresh connection',
                ),
              ],
            ),
            
            if (_tileserverConnected) ...[
              const SizedBox(height: 8),
              Text(
                'Connected to localhost:8090',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 12,
                ),
              ),
              
              if (_availablePhases.isNotEmpty) ...[
                const SizedBox(height: 8),
                DropdownButton<String>(
                  value: _selectedPhase,
                  hint: const Text('Select Phase'),
                  items: _availablePhases.map((phase) {
                    return DropdownMenuItem(
                      value: phase,
                      child: Text(phase),
                    );
                  }).toList(),
                  onChanged: (phase) {
                    setState(() {
                      _selectedPhase = phase;
                    });
                  },
                ),
              ],
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'Not connected',
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 12,
                ),
              ),
            ],
            
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: _showBoundaries,
                  onChanged: (value) {
                    setState(() {
                      _showBoundaries = value;
                    });
                  },
                ),
                const Text('Show Boundaries'),
              ],
            ),
            
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: _showDebugInfo,
                  onChanged: (value) {
                    setState(() {
                      _showDebugInfo = value;
                    });
                  },
                ),
                const Text('Debug Info'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugInfo() {
    return Card(
      color: Colors.black.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Debug Info',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Server: ${_tileserverConnected ? "✅ Connected" : "❌ Disconnected"}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            Text(
              'Phases: ${_availablePhases.length}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            Text(
              'Selected: ${_selectedPhase ?? "None"}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            Text(
              'Zoom: ${_zoom.toStringAsFixed(1)}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            Text(
              'Center: ${_mapCenter.latitude.toStringAsFixed(4)}, ${_mapCenter.longitude.toStringAsFixed(4)}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
            if (_connectionStatus.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Status: ${_connectionStatus.toString()}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTileLayerUrl() {
    // Use satellite imagery as base layer
    return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
  }

  void _handleMapTap(LatLng point) {
    print('Map tapped at: $point');
  }

  void _handleZoomChange(double? zoom) {
    if (zoom != null) {
      setState(() {
        _zoom = zoom;
      });
    }
  }

  /// Get PURE tileserver boundary layers - NO GeoJSON
  List<TileLayer> _getTileserverBoundaryLayers() {
    if (!_tileserverConnected || _availablePhases.isEmpty) {
      return [];
    }

    final tileLayers = <TileLayer>[];
    
    // Create tile layers for each available phase from tileserver
    for (final phase in _availablePhases) {
      final tileLayer = TileLayer(
        urlTemplate: DHATileserverService.getTileUrlTemplate(phase),
        userAgentPackageName: 'com.dha.marketplace',
        maxZoom: 18,
        minZoom: 8,
        errorTileCallback: (tile, error, stackTrace) {
          print('🚫 Tileserver tile error for $phase: $error');
        },
        tileBuilder: (context, tileWidget, tile) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: DHATileserverService.getPhaseColor(phase).withOpacity(0.5),
                width: 1.0,
              ),
            ),
            child: tileWidget,
          );
        },
      );
      
      tileLayers.add(tileLayer);
    }
    
    return tileLayers;
  }

  /// Get phase label markers for tileserver boundaries - NO GeoJSON
  List<Marker> _getPhaseLabelMarkers() {
    if (!_tileserverConnected || _availablePhases.isEmpty) {
      return [];
    }

    final markers = <Marker>[];
    
    // Only show labels at zoom level 12 and above
    if (_zoom < 12) return markers;
    
    // Create markers for each phase (using default DHA coordinates)
    final phaseCenters = {
      'Phase1': const LatLng(33.5348, 73.0951),
      'Phase2': const LatLng(33.5400, 73.1000),
      'Phase3': const LatLng(33.5450, 73.1050),
      'Phase4': const LatLng(33.5500, 73.1100),
      'Phase5': const LatLng(33.5550, 73.1150),
      'Phase6': const LatLng(33.5600, 73.1200),
      'Phase7': const LatLng(33.5650, 73.1250),
    };
    
    for (final phase in _availablePhases) {
      final center = phaseCenters[phase] ?? const LatLng(33.5348, 73.0951);
      
      final marker = Marker(
        point: center,
        width: 120,
        height: 40,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            phase,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              letterSpacing: 0.8,
              height: 1.2,
            ),
          ),
        ),
      );
      
      markers.add(marker);
    }
    
    return markers;
  }
}
