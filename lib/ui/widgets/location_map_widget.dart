import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_theme.dart';

class LocationMapWidget extends StatefulWidget {
  final LatLng? location;
  final String? address;
  final Function(LatLng)? onLocationChanged;
  final double height;
  final bool showMarker;
  final bool isSatelliteView;

  const LocationMapWidget({
    super.key,
    this.location,
    this.address,
    this.onLocationChanged,
    this.height = 200,
    this.showMarker = true,
    this.isSatelliteView = false,
  });

  @override
  State<LocationMapWidget> createState() => _LocationMapWidgetState();
}

class _LocationMapWidgetState extends State<LocationMapWidget> {
  late MapController _mapController;
  late LatLng _currentLocation;
  bool _isMapReady = false;

  // Default location (Islamabad - DHA Phase 1)
  static const LatLng _defaultLocation = LatLng(33.6844, 73.0479);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentLocation = widget.location ?? _defaultLocation;
  }

  @override
  void didUpdateWidget(LocationMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.location != oldWidget.location) {
      _currentLocation = widget.location ?? _defaultLocation;
      if (_isMapReady) {
        // Use a timer to ensure the map is ready
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted && _isMapReady) {
            try {
              // Adjust zoom level based on location type
              double zoomLevel = 15.0;
              
              // For major cities, use different zoom levels
              if (widget.address?.toLowerCase().contains('karachi') == true ||
                  widget.address?.toLowerCase().contains('lahore') == true) {
                zoomLevel = 12.0; // Zoom out for major cities
              } else if (widget.address?.toLowerCase().contains('islamabad') == true) {
                zoomLevel = 14.0; // Medium zoom for Islamabad
              }
              
              _mapController.move(_currentLocation, zoomLevel);
            } catch (e) {
              print('Map move error: $e');
            }
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderGrey.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _currentLocation,
                      initialZoom: 14.0,
                      minZoom: 5.0,
                      maxZoom: 18.0,
                      onMapReady: () {
                        if (mounted) {
                          setState(() {
                            _isMapReady = true;
                          });
                        }
                      },
                      onTap: widget.onLocationChanged != null
                          ? (tapPosition, point) {
                              setState(() {
                                _currentLocation = point;
                              });
                              widget.onLocationChanged!(point);
                            }
                          : null,
                    ),
                          children: [
                            TileLayer(
                              urlTemplate: widget.isSatelliteView 
                                  ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
                                  : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.dha.marketplace',
                              maxZoom: 18,
                              minZoom: 5,
                              subdomains: widget.isSatelliteView ? const <String>[] : const ['a', 'b', 'c'],
                              additionalOptions: const {
                                'attribution': '© OpenStreetMap contributors',
                              },
                              errorTileCallback: (tile, error, stackTrace) {
                                print('Tile error: $error');
                              },
                            ),
                            if (widget.showMarker)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: _currentLocation,
                                    width: 30,
                                    height: 30,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryBlue,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                                            blurRadius: 6,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.place,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        // Loading indicator
                        if (!_isMapReady)
                          Positioned.fill(
                            child: Container(
                              color: Colors.white.withValues(alpha: 0.8),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                        // Zoom controls
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Column(
                            children: [
                              // Zoom In Button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: _isMapReady ? () {
                                    try {
                                      double currentZoom = _mapController.camera.zoom;
                                      if (currentZoom < 18.0) {
                                        _mapController.move(
                                          _mapController.camera.center,
                                          currentZoom + 1,
                                        );
                                      }
                                    } catch (e) {
                                      print('Zoom in error: $e');
                                    }
                                  } : null,
                                  icon: Icon(
                                    Icons.add,
                                    color: !_isMapReady || _mapController.camera.zoom >= 18.0 
                                        ? Colors.grey 
                                        : AppTheme.primaryBlue,
                                    size: 20,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                  padding: const EdgeInsets.all(8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Zoom Out Button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  onPressed: _isMapReady ? () {
                                    try {
                                      double currentZoom = _mapController.camera.zoom;
                                      if (currentZoom > 5.0) {
                                        _mapController.move(
                                          _mapController.camera.center,
                                          currentZoom - 1,
                                        );
                                      }
                                    } catch (e) {
                                      print('Zoom out error: $e');
                                    }
                                  } : null,
                                  icon: Icon(
                                    Icons.remove,
                                    color: !_isMapReady || _mapController.camera.zoom <= 5.0 
                                        ? Colors.grey 
                                        : AppTheme.primaryBlue,
                                    size: 20,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                  padding: const EdgeInsets.all(8),
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
}
