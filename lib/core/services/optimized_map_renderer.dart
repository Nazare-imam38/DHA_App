import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Optimized map renderer that handles boundaries and amenities with performance optimizations
class OptimizedMapRenderer {
  static const double TOWN_PLAN_MIN_ZOOM = 14.0;
  static const double AMENITIES_MIN_ZOOM = 16.0; // Lazy loading for performance
  static const double BOUNDARY_OPTIMIZATION_ZOOM = 12.0;
  
  /// Get optimized boundary polygons - ALWAYS show all boundaries for performance
  static List<Polygon> getOptimizedBoundaryPolygons(
    List<BoundaryPolygon> boundaryPolygons,
    double zoomLevel,
    bool showBoundaries,
  ) {
    if (!showBoundaries) return [];
    
    // ALWAYS show all boundaries - no zoom filtering for performance
    final polygons = <Polygon>[];
    
    for (final boundary in boundaryPolygons) {
      for (final polygonCoords in boundary.polygons) {
        if (polygonCoords.length >= 3) {
          // NO SIMPLIFICATION - use original coordinates for best performance
          polygons.add(
            Polygon(
              points: polygonCoords,
              color: Colors.transparent,
              borderColor: Colors.transparent,
              borderStrokeWidth: 0.0,
              label: boundary.phaseName, // Always show labels
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
    
    return polygons;
  }
  
  /// Get optimized boundary lines - ALWAYS show all boundaries for performance
  static List<Polyline> getOptimizedBoundaryLines(
    List<BoundaryPolygon> boundaryPolygons,
    double zoomLevel,
    bool showBoundaries,
  ) {
    if (!showBoundaries) return [];
    
    // ALWAYS show all boundary lines - no zoom filtering for performance
    final polylines = <Polyline>[];
    
    for (final boundary in boundaryPolygons) {
      for (final polygonCoords in boundary.polygons) {
        if (polygonCoords.length >= 3) {
          // NO SIMPLIFICATION - use original coordinates for best performance
          final dottedLines = _createOptimizedDottedLines(polygonCoords, zoomLevel);
          polylines.addAll(dottedLines);
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
  
  
  /// Create optimized dotted lines - simplified for performance
  static List<Polyline> _createOptimizedDottedLines(List<LatLng> coordinates, double zoomLevel) {
    final polylines = <Polyline>[];
    
    // Fixed segment count for consistent performance
    final segmentCount = 8;
    
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
              strokeWidth: 2.0, // Fixed stroke width for performance
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
