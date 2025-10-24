import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/nearby_facility.dart';

class FacilityService {
  static const String overpassUrl = 'https://overpass-api.de/api/interpreter';
  
  /// Get nearby facilities for a property location
  static Future<List<NearbyFacility>> getNearbyFacilities(
    LatLng propertyLocation, {
    double radiusKm = 5.0
  }) async {
    try {
      final lat = propertyLocation.latitude;
      final lng = propertyLocation.longitude;
      final radius = (radiusKm * 1000).round(); // Convert km to meters
      
      // Build Overpass query for residential-relevant facilities within radius
      String query = '''
        [out:json][timeout:25];
        (
          node["amenity"~"^(hospital|clinic)\$"](around:${radius},${lat},${lng});
          node["amenity"~"^(school|university|college)\$"](around:${radius},${lat},${lng});
          node["leisure"~"^(park|playground|sports_centre)\$"](around:${radius},${lat},${lng});
          node["shop"~"^(mall|supermarket|department_store|market|bazaar)\$"](around:${radius},${lat},${lng});
          node["tourism"~"^(attraction|museum)\$"](around:${radius},${lat},${lng});
          node["public_transport"~"^(station|stop)\$"](around:${radius},${lat},${lng});
          node["railway"~"^(station|halt)\$"](around:${radius},${lat},${lng});
          node["highway"~"^(bus_stop|bus_station)\$"](around:${radius},${lat},${lng});
          node["amenity"~"^(bus_station|taxi_stand)\$"](around:${radius},${lat},${lng});
        );
        out geom;
      ''';
      
      final response = await http.post(
        Uri.parse(overpassUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'data': query},
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseOverpassResponse(data);
      } else {
        print('Overpass API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching facilities: $e');
      return [];
    }
  }
  
  /// Parse Overpass API response and convert to NearbyFacility objects
  static List<NearbyFacility> _parseOverpassResponse(Map<String, dynamic> data) {
    List<NearbyFacility> facilities = [];
    
    if (data['elements'] != null) {
      for (var element in data['elements']) {
        try {
          final facility = _parseElement(element);
          if (facility != null) {
            facilities.add(facility);
          }
        } catch (e) {
          print('Error parsing facility element: $e');
          continue;
        }
      }
    }
    
    // Remove duplicates and sort by distance from property
    facilities = _removeDuplicates(facilities);
    return facilities.take(8).toList(); // Limit to 8 facilities to reduce clutter
  }
  
  /// Parse individual element from Overpass response
  static NearbyFacility? _parseElement(Map<String, dynamic> element) {
    if (element['lat'] == null || element['lon'] == null) return null;
    
    final lat = element['lat'] as double;
    final lng = element['lon'] as double;
    final tags = element['tags'] as Map<String, dynamic>? ?? {};
    
    // Get facility name with better fallbacks
    String name = tags['name'] ?? 
                 tags['name:en'] ?? 
                 tags['brand'] ?? 
                 tags['operator'] ??
                 tags['shop'] ??
                 tags['amenity'] ??
                 '';
    
    // Skip facilities with no proper name or "Unknown Facility"
    if (name.isEmpty || name.toLowerCase().contains('unknown') || name == 'Unknown Facility') {
      return null;
    }
    
    // Determine category based on OSM tags
    String category = _determineCategory(tags);
    
    // Skip "other" category facilities
    if (category == 'other') {
      return null;
    }
    
    // Get address if available
    String? address = tags['addr:full'] ?? 
                     tags['addr:street'] ?? 
                     tags['addr:housename'];
    
    return NearbyFacility(
      name: name,
      category: category,
      coordinates: LatLng(lat, lng),
      address: address,
    );
  }
  
  /// Determine facility category based on OSM tags - Focus on residential-relevant facilities
  static String _determineCategory(Map<String, dynamic> tags) {
    // Check amenity tags
    if (tags['amenity'] != null) {
      final amenity = tags['amenity'] as String;
      if (amenity.contains('hospital') || amenity.contains('clinic')) {
        return 'hospital';
      } else if (amenity.contains('school') || amenity.contains('university') || amenity.contains('college')) {
        return 'school';
      }
    }
    
    // Check leisure tags
    if (tags['leisure'] != null) {
      final leisure = tags['leisure'] as String;
      if (leisure.contains('park') || leisure.contains('playground')) {
        return 'park';
      } else if (leisure.contains('sports_centre')) {
        return 'park'; // Treat sports centers as recreational facilities
      }
    }
    
    // Check shop tags
    if (tags['shop'] != null) {
      final shop = tags['shop'] as String;
      if (shop.contains('mall') || shop.contains('supermarket') || shop.contains('department_store')) {
        return 'shopping';
      } else if (shop.contains('market') || shop.contains('bazaar')) {
        return 'market';
      }
    }
    
    // Check tourism tags
    if (tags['tourism'] != null) {
      final tourism = tags['tourism'] as String;
      if (tourism.contains('attraction') || tourism.contains('museum')) {
        return 'entertainment';
      }
    }
    
    // Check transport tags
    if (tags['public_transport'] != null || tags['railway'] != null || tags['highway'] != null) {
      return 'transport';
    }
    
    // Check amenity transport tags
    if (tags['amenity'] != null) {
      final amenity = tags['amenity'] as String;
      if (amenity.contains('bus_station') || amenity.contains('taxi_stand')) {
        return 'transport';
      }
    }
    
    return 'other';
  }
  
  /// Remove duplicate facilities based on name and coordinates
  static List<NearbyFacility> _removeDuplicates(List<NearbyFacility> facilities) {
    final uniqueFacilities = <String, NearbyFacility>{};
    
    for (final facility in facilities) {
      final key = '${facility.name}_${facility.coordinates.latitude}_${facility.coordinates.longitude}';
      if (!uniqueFacilities.containsKey(key)) {
        uniqueFacilities[key] = facility;
      }
    }
    
    return uniqueFacilities.values.toList();
  }
  
  /// Get facility icon based on category - Focus on residential-relevant facilities
  static String getFacilityIcon(String category) {
    switch (category) {
      case 'hospital':
        return '🏥';
      case 'school':
        return '🏫';
      case 'park':
        return '🏞️';
      case 'shopping':
        return '🛍️';
      case 'market':
        return '🏪';
      case 'transport':
        return '🚇';
      case 'entertainment':
        return '🎢';
      default:
        return '📍';
    }
  }
  
  /// Get facility color based on category - All use app's blue theme
  static int getFacilityColor(String category) {
    // Use app's blue theme color (0xFF1B5993) for all facilities
    return 0xFF1B5993; // App's blue theme color
  }
}
