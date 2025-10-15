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

  const LocationMapWidget({
    super.key,
    this.location,
    this.address,
    this.onLocationChanged,
    this.height = 200,
    this.showMarker = true,
  });

  @override
  State<LocationMapWidget> createState() => _LocationMapWidgetState();
}

class _LocationMapWidgetState extends State<LocationMapWidget> {
  late MapController _mapController;
  LatLng? _currentLocation;
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _currentLocation = widget.location;
  }

        @override
        void didUpdateWidget(LocationMapWidget oldWidget) {
          super.didUpdateWidget(oldWidget);
          if (widget.location != oldWidget.location) {
            _currentLocation = widget.location;
            if (_currentLocation != null && _isMapReady) {
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
                    
                    _mapController.move(_currentLocation!, zoomLevel);
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
              child: _currentLocation != null
                  ? Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: _currentLocation!,
                            initialZoom: 15.0,
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
                              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.dha.marketplace',
                              maxZoom: 18,
                              subdomains: const ['a', 'b', 'c'],
                            ),
                            if (widget.showMarker && _currentLocation != null)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: _currentLocation!,
                                    width: 40,
                                    height: 40,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryBlue,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 3,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
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
                    )
            : Container(
                decoration: BoxDecoration(
                  color: AppTheme.backgroundGrey,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        size: 48,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.address?.isNotEmpty == true 
                            ? 'Location not found for: ${widget.address}'
                            : 'Enter address to see location',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (widget.address?.isNotEmpty == true) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Showing Islamabad area',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
