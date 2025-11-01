import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local cache for storing property amenities when backend doesn't return them
class LocalAmenitiesCache {
  static const String _keyPrefix = 'property_amenities_';
  static const String _namesCacheKey = 'amenities_names_cache';
  
  /// Store amenities for a property locally
  static Future<void> storePropertyAmenities(String propertyId, List<String> amenityIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('${_keyPrefix}$propertyId', amenityIds);
  }
  
  /// Get stored amenities for a property
  static Future<List<String>> getPropertyAmenities(String propertyId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('${_keyPrefix}$propertyId') ?? [];
  }
  
  /// Store amenity ID to name mappings
  static Future<void> storeAmenityNames(Map<String, String> idToNameMap) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(idToNameMap);
    await prefs.setString(_namesCacheKey, jsonString);
  }
  
  /// Store complete amenity details for a specific property
  static Future<void> storePropertyAmenityDetails(String propertyId, Map<String, Map<String, dynamic>> amenityDetails) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(amenityDetails);
    await prefs.setString('${_keyPrefix}details_$propertyId', jsonString);
  }
  
  /// Get complete amenity details for a specific property
  static Future<Map<String, Map<String, dynamic>>> getPropertyAmenityDetails(String propertyId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('${_keyPrefix}details_$propertyId');
    if (jsonString != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(jsonString);
        return decoded.map((key, value) => MapEntry(key, Map<String, dynamic>.from(value)));
      } catch (e) {
        return {};
      }
    }
    return {};
  }
  
  /// Get stored amenity names
  static Future<Map<String, String>> getAmenityNames() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_namesCacheKey);
    if (jsonString != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(jsonString);
        return decoded.map((key, value) => MapEntry(key, value.toString()));
      } catch (e) {
        return {};
      }
    }
    return {};
  }
  
  /// Clear all cached data
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_keyPrefix) || key == _namesCacheKey);
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}