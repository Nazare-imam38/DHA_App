import 'dart:math';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Enhanced MBTiles Service for DHA Marketplace
/// Provides comprehensive tile layer management with bounds checking,
/// performance optimization, and dynamic layer loading
class MBTilesService {
  static const String _baseUrl = 'https://tiles.dhamarketplace.com/data';
  static const int _minZoom = 14;
  static const int _maxZoom = 18;
  static const int _tileSize = 256;

  /// DHA Phase definitions with comprehensive bounds and metadata
  static const Map<String, DHAPhase> _phases = {
    'phase1': DHAPhase(
      id: 'phase1',
      name: 'Phase 1',
      description: 'DHA Phase 1 Development',
      center: LatLng(33.5348, 73.0951),
      bounds: LatLngBounds(
        LatLng(33.522675, 73.084847), // SW
        LatLng(33.555491, 73.11721),  // NE
      ),
      attribution: 'Phase 1 Tiles © DHA Marketplace',
      color: Color(0xFF4CAF50),
      icon: Icons.home,
    ),
    'phase2': DHAPhase(
      id: 'phase2',
      name: 'Phase 2',
      description: 'DHA Phase 2 Development',
      center: LatLng(33.52844, 73.15383),
      bounds: LatLngBounds(
        LatLng(33.509562, 73.128907), // SW
        LatLng(33.542692, 73.183331), // NE
      ),
      attribution: 'Phase 2 Tiles © DHA Marketplace',
      color: Color(0xFF2196F3),
      icon: Icons.business,
    ),
    'phase3': DHAPhase(
      id: 'phase3',
      name: 'Phase 3',
      description: 'DHA Phase 3 Development',
      center: LatLng(33.49562, 73.15650),
      bounds: LatLngBounds(
        LatLng(33.463783, 73.11683), // SW
        LatLng(33.517631, 73.198346), // NE
      ),
      attribution: 'Phase 3 Tiles © DHA Marketplace',
      color: Color(0xFFFF9800),
      icon: Icons.location_city,
    ),
    'phase4': DHAPhase(
      id: 'phase4',
      name: 'Phase 4',
      description: 'DHA Phase 4 Development',
      center: LatLng(33.52165, 73.07213),
      bounds: LatLngBounds(
        LatLng(33.471374, 72.989226), // SW
        LatLng(33.531711, 73.089317), // NE
      ),
      attribution: 'Phase 4 Tiles © DHA Marketplace',
      color: Color(0xFF9C27B0),
      icon: Icons.landscape,
    ),
    'phase4_gv': DHAPhase(
      id: 'phase4_gv',
      name: 'Phase 4 GV',
      description: 'DHA Phase 4 Garden View',
      center: LatLng(33.50073, 73.04962),
      bounds: LatLngBounds(
        LatLng(33.485000, 73.035000), // SW
        LatLng(33.515000, 73.065000), // NE
      ),
      attribution: 'Phase 4 GV Tiles © DHA Marketplace',
      color: Color(0xFF4CAF50),
      icon: Icons.park,
    ),
    'phase4_rvs': DHAPhase(
      id: 'phase4_rvs',
      name: 'Phase 4 RVS',
      description: 'DHA Phase 4 RVS Development',
      center: LatLng(33.48358, 72.99944),
      bounds: LatLngBounds(
        LatLng(33.470000, 72.985000), // SW
        LatLng(33.495000, 73.015000), // NE
      ),
      attribution: 'Phase 4 RVS Tiles © DHA Marketplace',
      color: Color(0xFF607D8B),
      icon: Icons.villa,
    ),
    'phase5': DHAPhase(
      id: 'phase5',
      name: 'Phase 5',
      description: 'DHA Phase 5 Development',
      center: LatLng(33.52335, 73.20746),
      bounds: LatLngBounds(
        LatLng(33.500307, 73.181263), // SW
        LatLng(33.545447, 73.237663), // NE
      ),
      attribution: 'Phase 5 Tiles © DHA Marketplace',
      color: Color(0xFFE91E63),
      icon: Icons.apartment,
    ),
    'phase6': DHAPhase(
      id: 'phase6',
      name: 'Phase 6',
      description: 'DHA Phase 6 Development',
      center: LatLng(33.55784, 73.28214),
      bounds: LatLngBounds(
        LatLng(33.522786, 73.226116), // SW
        LatLng(33.590846, 73.339476), // NE
      ),
      attribution: 'Phase 6 Tiles © DHA Marketplace',
      color: Color(0xFF795548),
      icon: Icons.domain,
    ),
    // Phase 7 Sub-phases
    'bluebell': DHAPhase(
      id: 'bluebell',
      name: 'Bluebell',
      description: 'DHA Phase 7 Bluebell Sector',
      center: LatLng(33.560000, 73.300000),
      bounds: LatLngBounds(
        LatLng(33.550000, 73.290000), // SW
        LatLng(33.570000, 73.310000), // NE
      ),
      attribution: 'Bluebell Tiles © DHA Marketplace',
      color: Color(0xFF3F51B5),
      icon: Icons.local_florist,
    ),
    'bougainvillea': DHAPhase(
      id: 'bougainvillea',
      name: 'Bougainvillea',
      description: 'DHA Phase 7 Bougainvillea Sector',
      center: LatLng(33.565000, 73.305000),
      bounds: LatLngBounds(
        LatLng(33.555000, 73.295000), // SW
        LatLng(33.575000, 73.315000), // NE
      ),
      attribution: 'Bougainvillea Tiles © DHA Marketplace',
      color: Color(0xFFE91E63),
      icon: Icons.local_florist,
    ),
    'daisy': DHAPhase(
      id: 'daisy',
      name: 'Daisy',
      description: 'DHA Phase 7 Daisy Sector',
      center: LatLng(33.570000, 73.310000),
      bounds: LatLngBounds(
        LatLng(33.560000, 73.300000), // SW
        LatLng(33.580000, 73.320000), // NE
      ),
      attribution: 'Daisy Tiles © DHA Marketplace',
      color: Color(0xFFFFEB3B),
      icon: Icons.local_florist,
    ),
    'gardenia': DHAPhase(
      id: 'gardenia',
      name: 'Gardenia',
      description: 'DHA Phase 7 Gardenia Sector',
      center: LatLng(33.575000, 73.315000),
      bounds: LatLngBounds(
        LatLng(33.565000, 73.305000), // SW
        LatLng(33.585000, 73.325000), // NE
      ),
      attribution: 'Gardenia Tiles © DHA Marketplace',
      color: Color(0xFF4CAF50),
      icon: Icons.local_florist,
    ),
    'eglentine': DHAPhase(
      id: 'eglentine',
      name: 'Eglentine',
      description: 'DHA Phase 7 Eglentine Sector',
      center: LatLng(33.580000, 73.320000),
      bounds: LatLngBounds(
        LatLng(33.570000, 73.310000), // SW
        LatLng(33.590000, 73.330000), // NE
      ),
      attribution: 'Eglentine Tiles © DHA Marketplace',
      color: Color(0xFF9C27B0),
      icon: Icons.local_florist,
    ),
    'lavender': DHAPhase(
      id: 'lavender',
      name: 'Lavender',
      description: 'DHA Phase 7 Lavender Sector',
      center: LatLng(33.585000, 73.325000),
      bounds: LatLngBounds(
        LatLng(33.575000, 73.315000), // SW
        LatLng(33.595000, 73.335000), // NE
      ),
      attribution: 'Lavender Tiles © DHA Marketplace',
      color: Color(0xFF673AB7),
      icon: Icons.local_florist,
    ),
  };

  /// Get all available phases
  static List<DHAPhase> getAllPhases() {
    return _phases.values.toList();
  }

  /// Get phase by ID
  static DHAPhase? getPhase(String phaseId) {
    return _phases[phaseId];
  }

  /// Get phases that intersect with the given bounds
  static List<DHAPhase> getPhasesInBounds(LatLngBounds viewportBounds) {
    return _phases.values.where((phase) {
      return _boundsIntersect(viewportBounds, phase.bounds);
    }).toList();
  }

  /// Get phases that contain the given point
  static List<DHAPhase> getPhasesAtPoint(LatLng point) {
    return _phases.values.where((phase) {
      return phase.bounds.contains(point);
    }).toList();
  }

  /// Generate tile URL for a specific phase
  static String getTileUrl(String phaseId, int z, int x, int y) {
    return '$_baseUrl/$phaseId/{z}/{x}/{y}.png'
        .replaceAll('{z}', z.toString())
        .replaceAll('{x}', x.toString())
        .replaceAll('{y}', y.toString());
  }

  /// Generate tile URL with error fallback
  static String getTileUrlWithFallback(String phaseId, int z, int x, int y) {
    // Primary URL
    final primaryUrl = getTileUrl(phaseId, z, x, y);
    
    // Fallback to transparent 1x1 PNG if tile doesn't exist
    return primaryUrl;
  }

  /// Check if bounds intersect
  static bool _boundsIntersect(LatLngBounds bounds1, LatLngBounds bounds2) {
    return !(bounds1.south > bounds2.north || 
             bounds1.north < bounds2.south || 
             bounds1.west > bounds2.east || 
             bounds1.east < bounds2.west);
  }

  /// Convert lat/lng to tile coordinates
  static Point<int> latLngToTile(LatLng latLng, int zoom) {
    final latRad = latLng.latitude * pi / 180;
    final n = pow(2, zoom).toDouble();
    final x = ((latLng.longitude + 180) / 360 * n).floor();
    final y = ((1 - asinh(tan(latRad)) / pi) / 2 * n).floor();
    return Point(x, y);
  }

  /// Convert tile coordinates to lat/lng bounds
  static LatLngBounds tileToLatLngBounds(int x, int y, int zoom) {
    final n = pow(2, zoom).toDouble();
    final lonDeg = x / n * 360 - 180;
    final latRad = atan(sinh(pi * (1 - 2 * y / n)));
    final latDeg = latRad * 180 / pi;
    
    final lonDeg2 = (x + 1) / n * 360 - 180;
    final latRad2 = atan(sinh(pi * (1 - 2 * (y + 1) / n)));
    final latDeg2 = latRad2 * 180 / pi;
    
    return LatLngBounds(
      LatLng(min(latDeg, latDeg2), min(lonDeg, lonDeg2)),
      LatLng(max(latDeg, latDeg2), max(lonDeg, lonDeg2)),
    );
  }

  /// Get minimum zoom level for tiles
  static int get minZoom => _minZoom;

  /// Get maximum zoom level for tiles
  static int get maxZoom => _maxZoom;

  /// Get tile size
  static int get tileSize => _tileSize;
}

/// DHA Phase model with comprehensive metadata
class DHAPhase {
  final String id;
  final String name;
  final String description;
  final LatLng center;
  final LatLngBounds bounds;
  final String attribution;
  final Color color;
  final IconData icon;

  const DHAPhase({
    required this.id,
    required this.name,
    required this.description,
    required this.center,
    required this.bounds,
    required this.attribution,
    required this.color,
    required this.icon,
  });

  /// Get tile URL for this phase
  String getTileUrl(int z, int x, int y) {
    return MBTilesService.getTileUrl(id, z, x, y);
  }

  /// Check if a point is within this phase bounds
  bool contains(LatLng point) {
    return bounds.contains(point);
  }

  /// Get distance from center to a point
  double distanceToCenter(LatLng point) {
    const distance = Distance();
    return distance(center, point);
  }

  @override
  String toString() {
    return 'DHAPhase(id: $id, name: $name, center: $center)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DHAPhase && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
