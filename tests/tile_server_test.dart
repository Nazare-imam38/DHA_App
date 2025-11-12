import 'dart:io';
import 'package:http/http.dart' as http;

/// Tile Server Test Service
/// Tests MBTiles server connectivity and tile availability
class TileServerTestService {
  static const String _baseUrl = 'https://tiles.dhamarketplace.com/data';
  
  /// Test if tile server is accessible
  static Future<bool> testServerConnectivity() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/'),
        headers: {
          'User-Agent': 'DHA Marketplace Mobile App',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('🌐 Server connectivity test: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Server connectivity test failed: $e');
      return false;
    }
  }
  
  /// Test specific phase tile availability
  static Future<bool> testPhaseTile(String phaseId, int z, int x, int y) async {
    try {
      final url = '$_baseUrl/$phaseId/$z/$x/$y.png';
      print('🔍 Testing tile: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent': 'DHA Marketplace Mobile App',
          'Accept': 'image/png',
        },
      ).timeout(const Duration(seconds: 10));
      
      print('🔍 Tile response: ${response.statusCode}');
      print('🔍 Content length: ${response.bodyBytes.length}');
      
      if (response.statusCode == 200) {
        print('✅ Tile available: $url');
        return true;
      } else {
        print('❌ Tile not available: $url (${response.statusCode})');
        return false;
      }
    } catch (e) {
      print('❌ Tile test failed: $e');
      return false;
    }
  }
  
  /// Test all available phases
  static Future<Map<String, bool>> testAllPhases() async {
    final results = <String, bool>{};
    
    final phases = [
      'phase1', 'phase2', 'phase3', 'phase4', 'phase4_gv', 
      'phase4_rvs', 'phase5', 'phase6'
    ];
    
    for (final phase in phases) {
      print('🔍 Testing phase: $phase');
      final isAvailable = await testPhaseTile(phase, 14, 12345, 67890);
      results[phase] = isAvailable;
      
      // Small delay to avoid overwhelming server
      await Future.delayed(const Duration(milliseconds: 500));
    }
    
    return results;
  }
  
  /// Test tile coordinates for DHA area
  static Future<void> testDHATiles() async {
    print('🗺️ Testing DHA area tiles...');
    
    // DHA center coordinates
    const dhaCenter = [33.5227, 73.0951];
    
    // Test different zoom levels
    for (int zoom = 14; zoom <= 16; zoom++) {
      print('🔍 Testing zoom level: $zoom');
      
      // Convert lat/lng to tile coordinates
      final tileX = _lngToTileX(dhaCenter[1], zoom);
      final tileY = _latToTileY(dhaCenter[0], zoom);
      
      print('🔍 Tile coordinates: $tileX, $tileY');
      
      // Test phase2 tiles
      final isAvailable = await testPhaseTile('phase2', zoom, tileX, tileY);
      print('🔍 Phase 2 tile at zoom $zoom: ${isAvailable ? "✅" : "❌"}');
    }
  }
  
  /// Convert longitude to tile X coordinate
  static int _lngToTileX(double lng, int zoom) {
    return ((lng + 180) / 360 * (1 << zoom)).floor();
  }
  
  /// Convert latitude to tile Y coordinate
  static int _latToTileY(double lat, int zoom) {
    final latRad = lat * 3.14159265359 / 180;
    return ((1 - (latRad.tanh() + 1) / 2) * (1 << zoom)).floor();
  }
  
  /// Run comprehensive tile server test
  static Future<void> runComprehensiveTest() async {
    print('🚀 Starting comprehensive tile server test...');
    
    // Test server connectivity
    final isServerUp = await testServerConnectivity();
    if (!isServerUp) {
      print('❌ Server is not accessible. Check network connection.');
      return;
    }
    
    print('✅ Server is accessible');
    
    // Test all phases
    final phaseResults = await testAllPhases();
    print('📊 Phase availability results:');
    for (final entry in phaseResults.entries) {
      print('  ${entry.key}: ${entry.value ? "✅" : "❌"}');
    }
    
    // Test DHA area tiles
    await testDHATiles();
    
    print('🏁 Comprehensive test completed');
  }
}
