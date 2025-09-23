import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/plot_model.dart';

class PolygonRendererService {
  /// Create polygon overlays for plots
  static List<Polygon> createPlotPolygons(List<PlotModel> plots) {
    final polygons = <Polygon>[];
    
    for (final plot in plots) {
      try {
        final plotPolygons = plot.polygonCoordinates;
        
        for (int i = 0; i < plotPolygons.length; i++) {
          final coordinates = plotPolygons[i];
          if (coordinates.length >= 3) { // Need at least 3 points for a polygon
            // Ensure polygon is closed (first and last points are the same)
            final closedCoordinates = List<LatLng>.from(coordinates);
            if (closedCoordinates.isNotEmpty && 
                (closedCoordinates.first.latitude != closedCoordinates.last.latitude ||
                 closedCoordinates.first.longitude != closedCoordinates.last.longitude)) {
              closedCoordinates.add(closedCoordinates.first);
            }
            
            polygons.add(
              Polygon(
                points: closedCoordinates,
                color: _getPlotColor(plot).withOpacity(0.3),
                borderColor: _getBorderColor(plot),
                borderStrokeWidth: 2.0,
                label: 'Plot ${plot.plotNo}',
                labelStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.white,
                      blurRadius: 2,
                    ),
                  ],
                ),
                labelPlacement: PolygonLabelPlacement.polylabel,
              ),
            );
          }
        }
      } catch (e) {
        print('Error creating polygon for plot ${plot.plotNo}: $e');
      }
    }
    
    return polygons;
  }

  /// Get color based on plot category and status
  static Color _getPlotColor(PlotModel plot) {
    // Base color by category
    Color baseColor;
    switch (plot.category.toLowerCase()) {
      case 'residential':
        baseColor = const Color(0xFF20B2AA); // Teal
        break;
      case 'commercial':
        baseColor = const Color(0xFF1E3C90); // Blue
        break;
      case 'industrial':
        baseColor = const Color(0xFF8B4513); // Brown
        break;
      default:
        baseColor = const Color(0xFF9E9E9E); // Grey
    }

    // Adjust color based on status
    switch (plot.status.toLowerCase()) {
      case 'available':
        return baseColor; // Keep original color
      case 'sold':
        return Colors.red;
      case 'reserved':
        return Colors.orange;
      case 'unsold':
        return baseColor.withOpacity(0.7);
      default:
        return baseColor.withOpacity(0.5);
    }
  }

  /// Get border color based on plot status
  static Color _getBorderColor(PlotModel plot) {
    switch (plot.status.toLowerCase()) {
      case 'available':
        return const Color(0xFF4CAF50); // Green
      case 'sold':
        return const Color(0xFFF44336); // Red
      case 'reserved':
        return const Color(0xFFFF9800); // Orange
      case 'unsold':
        return const Color(0xFF2196F3); // Blue
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  /// Create a single polygon for a plot with custom styling
  static Polygon createPlotPolygon(
    PlotModel plot, {
    Color? fillColor,
    Color? borderColor,
    double borderWidth = 2.0,
    double opacity = 0.3,
  }) {
    final coordinates = plot.polygonCoordinates;
    if (coordinates.isEmpty) {
      return Polygon(
        points: [],
        color: Colors.transparent,
        borderColor: Colors.transparent,
      );
    }

    final firstPolygon = coordinates.first;
    return Polygon(
      points: firstPolygon,
      color: (fillColor ?? _getPlotColor(plot)).withOpacity(opacity),
      borderColor: borderColor ?? _getBorderColor(plot),
      borderStrokeWidth: borderWidth,
      label: 'Plot ${plot.plotNo}',
      labelStyle: const TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.white,
            blurRadius: 2,
          ),
        ],
      ),
      labelPlacement: PolygonLabelPlacement.polylabel,
    );
  }

  /// Get plot statistics for legend
  static Map<String, Color> getPlotColorLegend() {
    return {
      'Residential Available': const Color(0xFF20B2AA),
      'Residential Sold': Colors.red,
      'Residential Reserved': Colors.orange,
      'Residential Unsold': const Color(0xFF20B2AA).withOpacity(0.7),
      'Commercial Available': const Color(0xFF1E3C90),
      'Commercial Sold': Colors.red,
      'Commercial Reserved': Colors.orange,
      'Commercial Unsold': const Color(0xFF1E3C90).withOpacity(0.7),
    };
  }

  /// Check if a point is inside a polygon
  static bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersectCount = 0;
    for (int i = 0; i < polygon.length; i++) {
      final p1 = polygon[i];
      final p2 = polygon[(i + 1) % polygon.length];
      
      if (point.latitude > min(p1.latitude, p2.latitude) &&
          point.latitude <= max(p1.latitude, p2.latitude) &&
          point.longitude <= max(p1.longitude, p2.longitude) &&
          p1.latitude != p2.latitude) {
        final xinters = (point.latitude - p1.latitude) * (p2.longitude - p1.longitude) / 
                       (p2.latitude - p1.latitude) + p1.longitude;
        if (p1.longitude == p2.longitude || point.longitude <= xinters) {
          intersectCount++;
        }
      }
    }
    return (intersectCount % 2) == 1;
  }

  /// Find plot at a given point
  static PlotModel? findPlotAtPoint(LatLng point, List<PlotModel> plots) {
    for (final plot in plots) {
      final polygons = plot.polygonCoordinates;
      for (final polygon in polygons) {
        if (isPointInPolygon(point, polygon)) {
          return plot;
        }
      }
    }
    return null;
  }
}
