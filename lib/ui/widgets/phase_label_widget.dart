import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../core/services/unified_memory_cache.dart';

/// Phase Label Widget for displaying phase names on boundaries
class PhaseLabelWidget extends StatelessWidget {
  final List<BoundaryPolygon> boundaries;
  final double zoom;
  final LatLngBounds viewportBounds;

  const PhaseLabelWidget({
    super.key,
    required this.boundaries,
    required this.zoom,
    required this.viewportBounds,
  });

  @override
  Widget build(BuildContext context) {
    // Only show labels at zoom level 12 and above to reduce clutter
    if (zoom < 12) {
      return const SizedBox.shrink();
    }

    // ALWAYS show all boundary labels - no viewport filtering for performance
    return Stack(
      children: boundaries.map((boundary) {
        return _buildPhaseLabel(boundary);
      }).toList(),
    );
  }

  Widget _buildPhaseLabel(BoundaryPolygon boundary) {
    return Positioned(
      left: _calculateLabelPosition(boundary).dx,
      top: _calculateLabelPosition(boundary).dy,
      child: Text(
        boundary.phaseName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
          shadows: [
            Shadow(
              color: Colors.black,
              blurRadius: 2,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
    );
  }

  Offset _calculateLabelPosition(BoundaryPolygon boundary) {
    // Calculate the center position of the boundary
    final center = boundary.center;
    
    // Convert lat/lng to screen coordinates
    // This is a simplified calculation - in a real implementation,
    // you'd use the map's projection to convert coordinates
    final screenX = (center.longitude + 180) * 2; // Simplified projection
    final screenY = (90 - center.latitude) * 2; // Simplified projection
    
    return Offset(screenX, screenY);
  }
}

/// Phase Label Layer for Flutter Map
class PhaseLabelLayer extends StatelessWidget {
  final List<BoundaryPolygon> boundaries;
  final double zoom;
  final LatLngBounds viewportBounds;

  const PhaseLabelLayer({
    super.key,
    required this.boundaries,
    required this.zoom,
    required this.viewportBounds,
  });

  @override
  Widget build(BuildContext context) {
    return PhaseLabelWidget(
      boundaries: boundaries,
      zoom: zoom,
      viewportBounds: viewportBounds,
    );
  }
}

/// Enhanced Phase Label with better positioning and styling
class EnhancedPhaseLabel extends StatelessWidget {
  final String phaseName;
  final Color color;
  final IconData icon;
  final LatLng position;
  final double zoom;

  const EnhancedPhaseLabel({
    super.key,
    required this.phaseName,
    required this.color,
    required this.icon,
    required this.position,
    required this.zoom,
  });

  @override
  Widget build(BuildContext context) {
    // Only show labels at zoom level 12 and above to reduce clutter
    if (zoom < 12) {
      return const SizedBox.shrink();
    }

    return Text(
      phaseName,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        fontFamily: 'Inter',
        shadows: [
          Shadow(
            color: Colors.black,
            blurRadius: 2,
            offset: Offset(1, 1),
          ),
        ],
      ),
    );
  }
}
