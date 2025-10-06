import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Optimized map renderer that handles boundaries and amenities with performance optimizations
class OptimizedMapRenderer {
  static const double TOWN_PLAN_MIN_ZOOM = 14.0;
  static const double AMENITIES_MIN_ZOOM = 14.0; // Sync with town plan
  static const double BOUNDARY_OPTIMIZATION_ZOOM = 12.0;
  
  /// Get optimized boundary polygons based on zoom level
  static List<Polygon> getOptimizedBoundaryPolygons(
    List<BoundaryPolygon> boundaryPolygons,
    double zoomLevel,
    bool showBoundaries,
  ) {
    if (!showBoundaries) return [];
    
    // Don't render boundaries at very low zoom levels for performance
    if (zoomLevel < 8.0) return [];
    
    final polygons = <Polygon>[];
    
    for (final boundary in boundaryPolygons) {
      for (final polygonCoords in boundary.polygons) {
        if (polygonCoords.length >= 3) {
          // Simplify polygon at low zoom levels for performance
          final simplifiedCoords = zoomLevel < BOUNDARY_OPTIMIZATION_ZOOM
              ? _simplifyPolygon(polygonCoords, zoomLevel)
              : polygonCoords;
          
          if (simplifiedCoords.length >= 3) {
            polygons.add(
              Polygon(
                points: simplifiedCoords,
                color: Colors.transparent,
                borderColor: Colors.transparent,
                borderStrokeWidth: 0.0,
                label: zoomLevel >= 12.0 ? boundary.phaseName : null, // Only show labels at higher zoom
                labelStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  shadows: [
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
    }
    
    return polygons;
  }
  
  /// Get optimized boundary lines with performance improvements
  static List<Polyline> getOptimizedBoundaryLines(
    List<BoundaryPolygon> boundaryPolygons,
    double zoomLevel,
    bool showBoundaries,
  ) {
    if (!showBoundaries) return [];
    
    // Don't render boundary lines at very low zoom levels
    if (zoomLevel < 8.0) return [];
    
    final polylines = <Polyline>[];
    
    for (final boundary in boundaryPolygons) {
      for (final polygonCoords in boundary.polygons) {
        if (polygonCoords.length >= 3) {
          // Simplify coordinates for performance
          final simplifiedCoords = zoomLevel < BOUNDARY_OPTIMIZATION_ZOOM
              ? _simplifyPolygon(polygonCoords, zoomLevel)
              : polygonCoords;
          
          if (simplifiedCoords.length >= 3) {
            // Create optimized dotted lines
            final dottedLines = _createOptimizedDottedLines(simplifiedCoords, zoomLevel);
            polylines.addAll(dottedLines);
          }
        }
      }
    }
    
    return polylines;
  }
  
  /// Get filtered amenities markers synchronized with town plan zoom level
  static List<Marker> getFilteredAmenitiesMarkers(
    List<AmenityMarker> amenityMarkers,
    double zoomLevel,
    bool showAmenities,
  ) {
    if (!showAmenities) return [];
    
    // Sync amenities with town plan zoom level (14+)
    if (zoomLevel < AMENITIES_MIN_ZOOM) {
      return [];
    }
    
    // Progressive loading based on zoom level
    List<AmenityMarker> filteredMarkers = amenityMarkers;
    
    if (zoomLevel < 16.0) {
      // Show 50% of amenities at zoom levels 14-15
      final maxAmenities = (amenityMarkers.length * 0.5).round();
      filteredMarkers = _sampleAmenitiesEvenly(amenityMarkers, maxAmenities);
    } else if (zoomLevel < 18.0) {
      // Show 75% of amenities at zoom levels 16-17
      final maxAmenities = (amenityMarkers.length * 0.75).round();
      filteredMarkers = _sampleAmenitiesEvenly(amenityMarkers, maxAmenities);
    }
    // At zoom level 18+, show all amenities
    
    return filteredMarkers.map((amenityMarker) => 
        _createOptimizedAmenityMarker(amenityMarker, zoomLevel)
    ).toList();
  }
  
  /// Simplify polygon coordinates for performance
  static List<LatLng> _simplifyPolygon(List<LatLng> coordinates, double zoomLevel) {
    if (coordinates.length <= 3) return coordinates;
    
    // Calculate simplification factor based on zoom level
    final factor = max(1, (coordinates.length / (20 - zoomLevel)).round());
    
    final simplified = <LatLng>[];
    for (int i = 0; i < coordinates.length; i += factor) {
      simplified.add(coordinates[i]);
    }
    
    // Ensure polygon is closed
    if (simplified.isNotEmpty && simplified.first != simplified.last) {
      simplified.add(simplified.first);
    }
    
    return simplified;
  }
  
  /// Create optimized dotted lines
  static List<Polyline> _createOptimizedDottedLines(List<LatLng> coordinates, double zoomLevel) {
    final polylines = <Polyline>[];
    
    // Adjust segment count based on zoom level
    final segmentCount = zoomLevel < 12.0 ? 5 : 10;
    
    for (int i = 0; i < coordinates.length; i++) {
      final start = coordinates[i];
      final end = coordinates[(i + 1) % coordinates.length];
      
      final segments = _createDottedLine(start, end, segmentCount);
      
      for (int j = 0; j < segments.length - 1; j += 2) {
        if (j + 1 < segments.length) {
          polylines.add(
            Polyline(
              points: [segments[j], segments[j + 1]],
              color: Colors.white,
              strokeWidth: zoomLevel < 12.0 ? 1.5 : 2.0,
              pattern: StrokePattern.dashed(segments: [4, 4]),
            ),
          );
        }
      }
    }
    
    return polylines;
  }
  
  /// Create dotted line segments
  static List<LatLng> _createDottedLine(LatLng start, LatLng end, int segments) {
    final points = <LatLng>[];
    
    for (int i = 0; i <= segments; i++) {
      final ratio = i / segments;
      final lat = start.latitude + (end.latitude - start.latitude) * ratio;
      final lng = start.longitude + (end.longitude - start.longitude) * ratio;
      points.add(LatLng(lat, lng));
    }
    
    return points;
  }
  
  /// Sample amenities evenly across phases
  static List<AmenityMarker> _sampleAmenitiesEvenly(List<AmenityMarker> amenityMarkers, int maxAmenities) {
    if (maxAmenities >= amenityMarkers.length) {
      return amenityMarkers;
    }
    
    // Group amenities by phase
    final Map<String, List<AmenityMarker>> amenitiesByPhase = {};
    for (final amenity in amenityMarkers) {
      amenitiesByPhase.putIfAbsent(amenity.phase, () => []).add(amenity);
    }
    
    final phases = amenitiesByPhase.keys.toList();
    final amenitiesPerPhase = (maxAmenities / phases.length).round();
    
    final List<AmenityMarker> sampledAmenities = [];
    
    for (final phase in phases) {
      final phaseAmenities = amenitiesByPhase[phase]!;
      final takeCount = amenitiesPerPhase.clamp(0, phaseAmenities.length);
      
      // Use random sampling
      final shuffled = List<AmenityMarker>.from(phaseAmenities)..shuffle();
      sampledAmenities.addAll(shuffled.take(takeCount));
    }
    
    // Fill remaining slots if needed
    if (sampledAmenities.length < maxAmenities) {
      final remaining = amenityMarkers.where((a) => !sampledAmenities.contains(a)).toList();
      final needed = maxAmenities - sampledAmenities.length;
      sampledAmenities.addAll(remaining.take(needed));
    }
    
    return sampledAmenities;
  }
  
  /// Create optimized amenity marker
  static Marker _createOptimizedAmenityMarker(AmenityMarker amenityMarker, double zoomLevel) {
    // Dynamic sizing based on zoom level
    final size = zoomLevel < 16.0 ? 24.0 : 30.0;
    final iconSize = zoomLevel < 16.0 ? 12.0 : 16.0;
    
    return Marker(
      point: amenityMarker.point,
      width: size,
      height: size,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: amenityMarker.color.withOpacity(0.8),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Icon(
          amenityMarker.icon,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
  
  /// Check if town plan should be visible at current zoom level
  static bool shouldShowTownPlan(double zoomLevel) {
    return zoomLevel >= TOWN_PLAN_MIN_ZOOM;
  }
  
  /// Check if amenities should be visible at current zoom level
  static bool shouldShowAmenities(double zoomLevel) {
    return zoomLevel >= AMENITIES_MIN_ZOOM;
  }
  
  /// Get optimal zoom level for town plan and amenities synchronization
  static double getOptimalZoomLevel() {
    return TOWN_PLAN_MIN_ZOOM;
  }
}

/// Model classes for boundaries and amenities
class BoundaryPolygon {
  final String phaseName;
  final List<List<LatLng>> polygons;
  final Color color;
  final IconData icon;
  
  const BoundaryPolygon({
    required this.phaseName,
    required this.polygons,
    required this.color,
    required this.icon,
  });
}

class AmenityMarker {
  final LatLng point;
  final String phase;
  final Color color;
  final IconData icon;
  
  const AmenityMarker({
    required this.point,
    required this.phase,
    required this.color,
    required this.icon,
  });
}
