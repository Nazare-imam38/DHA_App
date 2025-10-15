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
      if (_currentLocation != null) {
        _mapController.move(_currentLocation!, 15.0);
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
            ? FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentLocation!,
                  initialZoom: 15.0,
                  minZoom: 5.0,
                  maxZoom: 18.0,
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
                      Icon(
                        Icons.map_outlined,
                        size: 48,
                        color: AppTheme.textLight,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enter address to see location',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
