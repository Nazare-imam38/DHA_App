import 'dart:convert';

/// Universal JSON parser that handles all possible API response formats
class UniversalJsonParser {
  /// Parse API response and extract plots list regardless of format
  static List<dynamic> extractPlotsList(dynamic responseData) {
    if (responseData == null) {
      return [];
    }
    
    // Handle List response (direct array)
    if (responseData is List) {
      return responseData;
    }
    
    // Handle Map response with various structures
    if (responseData is Map<String, dynamic>) {
      // Check for data.plots structure
      if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
        final data = responseData['data'] as Map<String, dynamic>;
        if (data.containsKey('plots') && data['plots'] is List) {
          return data['plots'] as List<dynamic>;
        }
      }
      
      // Check for direct plots key
      if (responseData.containsKey('plots') && responseData['plots'] is List) {
        return responseData['plots'] as List<dynamic>;
      }
      
      // Check for data being a list directly
      if (responseData.containsKey('data') && responseData['data'] is List) {
        return responseData['data'] as List<dynamic>;
      }
    }
    
    // If we can't find plots, return empty list
    return [];
  }
  
  /// Parse API response and extract counts map regardless of format
  static Map<String, dynamic> extractCountsMap(dynamic responseData) {
    if (responseData == null) {
      return {};
    }
    
    // Handle Map response with various structures
    if (responseData is Map<String, dynamic>) {
      // Check for data.counts structure
      if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
        final data = responseData['data'] as Map<String, dynamic>;
        if (data.containsKey('counts') && data['counts'] is Map<String, dynamic>) {
          return data['counts'] as Map<String, dynamic>;
        }
      }
      
      // Check for direct counts key
      if (responseData.containsKey('counts') && responseData['counts'] is Map<String, dynamic>) {
        return responseData['counts'] as Map<String, dynamic>;
      }
    }
    
    // If we can't find counts, return empty map
    return {};
  }
  
  /// Parse API response and extract success status regardless of format
  static bool extractSuccessStatus(dynamic responseData) {
    if (responseData == null) {
      return false;
    }
    
    // Handle Map response
    if (responseData is Map<String, dynamic>) {
      return responseData['success'] as bool? ?? true; // Default to true if not specified
    }
    
    // For List responses, assume success
    return true;
  }
  
  /// Safely parse JSON response with comprehensive error handling
  static dynamic safeJsonDecode(String jsonString) {
    try {
      return json.decode(jsonString);
    } catch (e) {
      print('UniversalJsonParser: JSON decode error: $e');
      return null;
    }
  }
  
  /// Check if response data is valid for parsing
  static bool isValidResponse(dynamic responseData) {
    if (responseData == null) {
      return false;
    }
    
    // Check if it's a List
    if (responseData is List) {
      return true;
    }
    
    // Check if it's a Map with expected structure
    if (responseData is Map<String, dynamic>) {
      // Check for various possible structures
      if (responseData.containsKey('data') || 
          responseData.containsKey('plots') || 
          responseData.containsKey('success')) {
        return true;
      }
    }
    
    return false;
  }
}
