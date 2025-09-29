import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/plot_model.dart';
import '../utils/enhanced_geojson_parser.dart';
import 'polygon_preloader.dart';

/// Enhanced polygon service for proper plot boundary visualization
class EnhancedPolygonService {
  /// Create plot polygons using preloaded coordinates for maximum performance
  static List<Polygon> createPlotPolygons(List<PlotModel> plots, {PlotModel? selectedPlot}) {
    final polygons = <Polygon>[];
    
    print('EnhancedPolygonService: Creating polygons for ${plots.length} plots (using preloaded coordinates)');
    if (selectedPlot != null) {
      print('EnhancedPolygonService: Selected plot: ${selectedPlot.plotNo}');
    }
    
    for (final plot in plots) {
      try {
        // Use preloaded coordinates for maximum performance
        final plotPolygons = plot.polygonCoordinates;
        
        print('EnhancedPolygonService: Using ${plotPolygons.length} polygons for plot ${plot.plotNo}');
        
        for (int i = 0; i < plotPolygons.length; i++) {
          final coordinates = plotPolygons[i];
          print('EnhancedPolygonService: Polygon $i has ${coordinates.length} points');
          
          if (coordinates.length >= 3) {
            // Ensure polygon is closed
            final closedCoordinates = List<LatLng>.from(coordinates);
            if (closedCoordinates.isNotEmpty && 
                (closedCoordinates.first.latitude != closedCoordinates.last.latitude ||
                 closedCoordinates.first.longitude != closedCoordinates.last.longitude)) {
              closedCoordinates.add(closedCoordinates.first);
            }
            
            // Log first few coordinates for debugging
            if (closedCoordinates.isNotEmpty) {
              print('EnhancedPolygonService: First point: ${closedCoordinates.first}');
              print('EnhancedPolygonService: Last point: ${closedCoordinates.last}');
            }
            
            // Check if this is the selected plot for highlighting
            final isSelected = selectedPlot != null && plot.id == selectedPlot.id;
            
            polygons.add(
              Polygon(
                points: closedCoordinates,
                color: isSelected 
                    ? const Color(0xFF2196F3).withOpacity(0.6) // Blue highlight for selected plot
                    : _getPlotColor(plot).withOpacity(0.4),
                borderColor: isSelected 
                    ? const Color(0xFF1976D2) // Darker blue border for selected plot
                    : _getBorderColor(plot),
                borderStrokeWidth: isSelected ? 3.0 : 2.0, // Thicker border for selected plot
                label: 'Plot ${plot.plotNo}',
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.white,
                  fontSize: isSelected ? 14 : 12, // Larger font for selected plot
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
            
            print('EnhancedPolygonService: Added polygon for plot ${plot.plotNo} (selected: $isSelected)');
          } else {
            print('EnhancedPolygonService: Skipped polygon $i for plot ${plot.plotNo} - insufficient points (${coordinates.length})');
          }
        }
      } catch (e) {
        print('EnhancedPolygonService: Error creating polygon for plot ${plot.plotNo}: $e');
      }
    }
    
    print('EnhancedPolygonService: Created ${polygons.length} total polygons');
    return polygons;
  }
  
  /// Create a single plot polygon with custom styling
  static Polygon createPlotPolygon(
    PlotModel plot, {
    Color? fillColor,
    Color? borderColor,
    double borderWidth = 2.0,
    double opacity = 0.4,
  }) {
    try {
      final coordinates = EnhancedGeoJsonParser.parsePolygonCoordinates(plot.stAsgeojson);
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
      );
    } catch (e) {
      print('Error creating polygon for plot ${plot.plotNo}: $e');
      return Polygon(
        points: [],
        color: Colors.transparent,
        borderColor: Colors.transparent,
      );
    }
  }
  
  /// Get plot color based on status and category
  static Color _getPlotColor(PlotModel plot) {
    switch (plot.status.toLowerCase()) {
      case 'available':
        return plot.category.toLowerCase() == 'commercial' 
            ? const Color(0xFF1E3C90) // Blue for commercial
            : const Color(0xFF20B2AA); // Teal for residential
      case 'sold':
        return Colors.red;
      case 'reserved':
        return Colors.orange;
      case 'unsold':
        return plot.category.toLowerCase() == 'commercial' 
            ? const Color(0xFF1E3C90).withOpacity(0.7)
            : const Color(0xFF20B2AA).withOpacity(0.7);
      default:
        return Colors.grey;
    }
  }
  
  /// Get border color based on plot status
  static Color _getBorderColor(PlotModel plot) {
    switch (plot.status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'sold':
        return Colors.red;
      case 'reserved':
        return Colors.orange;
      case 'unsold':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  
  /// Check if a point is inside a polygon
  static bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int intersections = 0;
    int j = polygon.length - 1;
    
    for (int i = 0; i < polygon.length; i++) {
      if (((polygon[i].latitude > point.latitude) != (polygon[j].latitude > point.latitude)) &&
          (point.longitude < (polygon[j].longitude - polygon[i].longitude) * 
           (point.latitude - polygon[i].latitude) / (polygon[j].latitude - polygon[i].latitude) + 
           polygon[i].longitude)) {
        intersections++;
      }
      j = i;
    }
    
    return intersections % 2 == 1;
  }
  
  /// Find plot at a specific point
  static PlotModel? findPlotAtPoint(LatLng point, List<PlotModel> plots) {
    for (final plot in plots) {
      try {
        final coordinates = EnhancedGeoJsonParser.parsePolygonCoordinates(plot.stAsgeojson);
        for (final polygon in coordinates) {
          if (isPointInPolygon(point, polygon)) {
            return plot;
          }
        }
      } catch (e) {
        print('Error checking point in plot ${plot.plotNo}: $e');
      }
    }
    return null;
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
}
