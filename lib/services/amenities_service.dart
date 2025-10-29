import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class AmenitiesService {
  static const String baseUrl = 'https://testingbackend.dhamarketplace.com/api';
  final AuthService _authService = AuthService();
  
  // Get amenities by property type
  Future<Map<String, List<Map<String, dynamic>>>> getAmenitiesByPropertyType(int propertyTypeId) async {
    final apiUrl = '$baseUrl/amenities/by-property-type?property_type_id=$propertyTypeId';
    print('🚀 AMENITIES SERVICE: Starting API call');
    print('📍 URL: $apiUrl');
    
    try {
      // Get the authentication token from the auth service
      final token = await _authService.getToken();
      
      if (token == null) {
        print('❌ ERROR: No authentication token found. User must be logged in.');
        return {};
      }
      
      print('✅ Token found, making API request...');
      
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('🌐 API Call: GET $apiUrl');
      print('📊 Response Status: ${response.statusCode}');
      print('📦 Response Headers: ${response.headers}');
      print('📄 Response Body Length: ${response.body.length} characters');
      
      // Print first 500 characters of response for debugging
      if (response.body.isNotEmpty) {
        final preview = response.body.length > 500 
          ? '${response.body.substring(0, 500)}...' 
          : response.body;
        print('📄 Response Preview: $preview');
      }
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          // The API returns amenities grouped by category
          // Convert the nested structure to our expected format
          Map<String, List<Map<String, dynamic>>> amenitiesByCategory = {};
          
          // Iterate through each category in the response
          data['data'].forEach((categoryName, amenitiesList) {
            if (amenitiesList is List) {
              amenitiesByCategory[categoryName] = List<Map<String, dynamic>>.from(amenitiesList);
            }
          });
          
          print('Parsed amenities by category: ${amenitiesByCategory.keys.toList()}');
          return amenitiesByCategory;
        } else {
          print('API returned success: false or data is null');
          print('Response data: $data');
        }
      } else {
        print('API call failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
      }
      
      // Fallback to empty data
      return {};
    } catch (e) {
      print('Error loading amenities: $e');
      return {};
    }
  }
}
