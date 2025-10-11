import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

/// Service for connecting to the local DHA tileserver
/// Provides access to DHA phase boundaries via MBTiles
class DHATileserverService {
  static const String _baseUrl = 'http://localhost:8090';
  static const String _styleUrl = '$_baseUrl/styles/dha-style/';
  static const String _tileJsonUrl = '$_baseUrl/data/dha-tiles.json';
  
  static final Map<String, Color> _phaseColors = {
    'Phase1': const Color(0xFF4CAF50), // Green
    'Phase2': const Color(0xFF2196F3), // Blue
    'Phase3': const Color(0xFFFF9800), // Orange
    'Phase4': const Color(0xFF9C27B0), // Purple
    'Phase4_GV': const Color(0xFF9C27B0), // Purple variant
    'Phase4_RVN': const Color(0xFF9C27B0), // Purple variant
    'Phase4_RVS': const Color(0xFF9C27B0), // Purple variant
    'Phase5': const Color(0xFFF44336), // Red
    'Phase6': const Color(0xFF00BCD4), // Cyan
    'Phase7': const Color(0xFF795548), // Brown
  };

  static final Map<String, IconData> _phaseIcons = {
    'Phase1': Icons.home_work,
    'Phase2': Icons.home_work,
    'Phase3': Icons.home_work,
    'Phase4': Icons.home_work,
    'Phase4_GV': Icons.home_work,
    'Phase4_RVN': Icons.home_work,
    'Phase4_RVS': Icons.home_work,
    'Phase5': Icons.home_work,
    'Phase6': Icons.home_work,
    'Phase7': Icons.home_work,
  };

  /// Check if the tileserver is running and accessible
  static Future<bool> isServerRunning() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Tileserver not accessible: $e');
      return false;
    }
  }

  /// Get the tile JSON configuration from the server
  static Future<Map<String, dynamic>?> getTileJson() async {
    try {
      final response = await http.get(
        Uri.parse(_tileJsonUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('❌ Failed to get tile JSON: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting tile JSON: $e');
      return null;
    }
  }

  /// Get the style configuration from the server
  static Future<Map<String, dynamic>?> getStyle() async {
    try {
      final response = await http.get(
        Uri.parse(_styleUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('❌ Failed to get style: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting style: $e');
      return null;
    }
  }

  /// Get the tile URL template for a specific phase
  static String getTileUrlTemplate(String phaseName) {
    // The tileserver uses PBF format, not PNG
    return '$_baseUrl/data/dha-tiles/{z}/{x}/{y}.pbf';
  }

  /// Get all available phases from the tileserver
  static Future<List<String>> getAvailablePhases() async {
    try {
      final tileJson = await getTileJson();
      if (tileJson == null) return [];
      
      // Extract phase names from tilestats
      final tilestats = tileJson['tilestats'] as Map<String, dynamic>?;
      if (tilestats == null) return [];
      
      final layers = tilestats['layers'] as List<dynamic>?;
      if (layers == null || layers.isEmpty) return [];
      
      final layer = layers.first as Map<String, dynamic>;
      final attributes = layer['attributes'] as List<dynamic>?;
      if (attributes == null || attributes.isEmpty) return [];
      
      final phaseAttribute = attributes.first as Map<String, dynamic>;
      final values = phaseAttribute['values'] as List<dynamic>?;
      if (values == null) return [];
      
      // Convert phase names to match our naming convention
      return values.map((phase) => phase.toString().replaceAll(' ', '')).toList();
    } catch (e) {
      print('❌ Error getting available phases: $e');
      return [];
    }
  }

  /// Get phase color
  static Color getPhaseColor(String phaseName) {
    return _phaseColors[phaseName] ?? const Color(0xFF9E9E9E);
  }

  /// Get phase icon
  static IconData getPhaseIcon(String phaseName) {
    return _phaseIcons[phaseName] ?? Icons.location_on;
  }

  /// Test connection to the tileserver
  static Future<Map<String, dynamic>> testConnection() async {
    final results = <String, dynamic>{};
    
    try {
      // Test base server
      final serverRunning = await isServerRunning();
      results['server_running'] = serverRunning;
      
      if (serverRunning) {
        // Test tile JSON
        final tileJson = await getTileJson();
        results['tile_json_available'] = tileJson != null;
        
        if (tileJson != null) {
          results['tile_json_data'] = tileJson;
        }
        
        // Test style
        final style = await getStyle();
        results['style_available'] = style != null;
        
        if (style != null) {
          results['style_data'] = style;
        }
        
        // Get available phases
        final phases = await getAvailablePhases();
        results['available_phases'] = phases;
        results['phase_count'] = phases.length;
      }
    } catch (e) {
      results['error'] = e.toString();
    }
    
    return results;
  }

  /// Get the style URL for opening in browser
  static String getStyleUrl() {
    return _styleUrl;
  }

  /// Get the tile JSON URL
  static String getTileJsonUrl() {
    return _tileJsonUrl;
  }

  /// Get the base server URL
  static String getBaseUrl() {
    return _baseUrl;
  }
}
