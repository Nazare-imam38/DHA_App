import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dha_tileserver_service.dart';

/// Service that loads DHA phase boundaries from the local tileserver
/// instead of GeoJSON files from assets
class TileserverBoundaryService {
  static List<BoundaryPolygon>? _cachedBoundaries;
  static bool _isPreloaded = false;
  static bool _isLoading = false;
  
  /// Load all boundary data from the tileserver
  static Future<List<BoundaryPolygon>> loadAllBoundaries() async {
    if (_isLoading) {
      // Wait for current loading to complete
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return _cachedBoundaries ?? [];
    }
    
    if (_isPreloaded && _cachedBoundaries != null) {
      return _cachedBoundaries!;
    }
    
    _isLoading = true;
    
    try {
      print('🔄 Loading boundaries from tileserver...');
      
      // Check if tileserver is running
      final isRunning = await DHATileserverService.isServerRunning();
      if (!isRunning) {
        print('❌ Tileserver not running, falling back to empty boundaries');
        _cachedBoundaries = [];
        _isPreloaded = true;
        return [];
      }
      
      // Get available phases from tileserver
      final phases = await DHATileserverService.getAvailablePhases();
      print('📋 Available phases from tileserver: $phases');
      
      final boundaries = <BoundaryPolygon>[];
      
      // Create boundary polygons for each phase
      for (final phaseName in phases) {
        final boundary = _createBoundaryFromPhase(phaseName);
        if (boundary != null) {
          boundaries.add(boundary);
        }
      }
      
      _cachedBoundaries = boundaries;
      _isPreloaded = true;
      
      print('✅ Loaded ${boundaries.length} boundaries from tileserver');
      return boundaries;
      
    } catch (e) {
      print('❌ Error loading boundaries from tileserver: $e');
      _cachedBoundaries = [];
      _isPreloaded = true;
      return [];
    } finally {
      _isLoading = false;
    }
  }

  /// Create a boundary polygon from a phase name
  static BoundaryPolygon? _createBoundaryFromPhase(String phaseName) {
    try {
      // Get phase styling
      final color = DHATileserverService.getPhaseColor(phaseName);
      final icon = DHATileserverService.getPhaseIcon(phaseName);
      
      // Create a placeholder boundary - the actual boundaries will be rendered
      // as tile layers instead of polygons
      return BoundaryPolygon(
        phaseName: phaseName,
        polygons: [], // Empty polygons since we'll use tile layers
        color: color,
        icon: icon,
        isTileserverBoundary: true, // Flag to indicate this is from tileserver
      );
    } catch (e) {
      print('❌ Error creating boundary for $phaseName: $e');
      return null;
    }
  }

  /// Get boundaries instantly (from cache)
  static List<BoundaryPolygon> getBoundariesInstantly() {
    return _cachedBoundaries ?? [];
  }

  /// Check if boundaries are loaded
  static bool get isLoaded => _isPreloaded && _cachedBoundaries != null;

  /// Check if loading has been attempted
  static bool get hasAttemptedLoad => _isPreloaded;

  /// Clear cached boundaries
  static void clearCache() {
    _cachedBoundaries = null;
    _isPreloaded = false;
    _isLoading = false;
  }

  /// Get tile layers for all phases
  static List<TileLayer> getTileLayers() {
    if (!isLoaded) return [];
    
    final tileLayers = <TileLayer>[];
    
    for (final boundary in _cachedBoundaries!) {
      if (boundary.isTileserverBoundary == true) {
        final tileLayer = TileLayer(
          urlTemplate: DHATileserverService.getTileUrlTemplate(boundary.phaseName),
          userAgentPackageName: 'com.dha.marketplace',
          maxZoom: 18,
          minZoom: 8,
          errorTileCallback: (tile, error, stackTrace) {
            print('🚫 Tile error for ${boundary.phaseName}: $error');
          },
          tileBuilder: (context, tileWidget, tile) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: boundary.color.withOpacity(0.3),
                  width: 1.0,
                ),
              ),
              child: tileWidget,
            );
          },
        );
        
        tileLayers.add(tileLayer);
      }
    }
    
    return tileLayers;
  }

  /// Get tile layer for a specific phase
  static TileLayer? getTileLayerForPhase(String phaseName) {
    if (!isLoaded) return null;
    
    final boundary = _cachedBoundaries!.firstWhere(
      (b) => b.phaseName == phaseName,
      orElse: () => throw StateError('Phase $phaseName not found'),
    );
    
    if (boundary.isTileserverBoundary == true) {
      return TileLayer(
        urlTemplate: DHATileserverService.getTileUrlTemplate(phaseName),
        userAgentPackageName: 'com.dha.marketplace',
        maxZoom: 18,
        minZoom: 8,
        errorTileCallback: (tile, error, stackTrace) {
          print('🚫 Tile error for $phaseName: $error');
        },
        tileBuilder: (context, tileWidget, tile) {
          return Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: boundary.color.withOpacity(0.3),
                width: 1.0,
              ),
            ),
            child: tileWidget,
          );
        },
      );
    }
    
    return null;
  }

  /// Test tileserver connection and get status
  static Future<Map<String, dynamic>> testConnection() async {
    return await DHATileserverService.testConnection();
  }
}

/// Extended BoundaryPolygon class to support tileserver boundaries
class BoundaryPolygon {
  final String phaseName;
  final List<List<LatLng>> polygons;
  final Color color;
  final IconData icon;
  final bool? isTileserverBoundary;
  final LatLng? center;

  BoundaryPolygon({
    required this.phaseName,
    required this.polygons,
    required this.color,
    required this.icon,
    this.isTileserverBoundary,
    this.center,
  });
}
