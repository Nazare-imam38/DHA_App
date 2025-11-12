import 'dart:convert';
import 'package:http/http.dart' as http;

class PropertyTypeService {
  static const String baseUrl = 'https://marketplace-testingbackend.dhamarketplace.com/api';
  
  // Get property categories
  Future<List<String>> getCategories() async {
    try {
      // Based on your Postman collection, categories are in the enums endpoint
      final response = await http.get(
        Uri.parse('$baseUrl/enums'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['categories'] != null) {
          return List<String>.from(data['categories']);
        }
      }
      
      // Fallback to default categories
      return ['Residential', 'Commercial'];
    } catch (e) {
      print('Error loading categories: $e');
      return ['Residential', 'Commercial'];
    }
  }
  
  // Get property types based on category and purpose
  Future<List<Map<String, dynamic>>> getPropertyTypes({
    String? category,
    String? purpose,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null) queryParams['category'] = category;
      if (purpose != null) queryParams['purpose'] = purpose;
      
      final uri = Uri.parse('$baseUrl/property/types').replace(
        queryParameters: queryParams,
      );
      
      print('API Call: GET $uri'); // Debug log
      
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      print('Response Status: ${response.statusCode}'); // Debug log
      print('Response Body: ${response.body}'); // Debug log
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      
      // Fallback to default property types based on category
      return _getDefaultPropertyTypes(category);
    } catch (e) {
      print('Error loading property types: $e');
      return _getDefaultPropertyTypes(category);
    }
  }
  
  // Get property subtypes based on parent type
  Future<List<Map<String, dynamic>>> getPropertySubtypes({
    required int parentId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/property/sub-types');
      
      print('API Call: POST $uri with parent_id: $parentId'); // Debug log
      
      // Create form data with parent_id[] format as shown in Postman
      final Map<String, String> formData = {
        'parent_id[]': parentId.toString(),
      };
      
      print('Request Body: $formData'); // Debug log
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: formData,
      );
      
      print('Response Status: ${response.statusCode}'); // Debug log
      print('Response Body: ${response.body}'); // Debug log
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Check if response has success field and data
        if (data is Map<String, dynamic>) {
          if (data['success'] == true && data['data'] != null) {
            final List<dynamic> subtypesList = data['data'];
            return subtypesList.map((item) => Map<String, dynamic>.from(item)).toList();
          }
          // If no success field but has data directly
          else if (data['data'] != null) {
            final List<dynamic> subtypesList = data['data'];
            return subtypesList.map((item) => Map<String, dynamic>.from(item)).toList();
          }
        }
        // If response is directly an array
        else if (data is List) {
          return data.map((item) => Map<String, dynamic>.from(item)).toList();
        }
      }
      
      print('No subtypes found for parent_id: $parentId');
      return [];
    } catch (e) {
      print('Error loading property subtypes: $e');
      return [];
    }
  }
  
  // Default property types based on category
  List<Map<String, dynamic>> _getDefaultPropertyTypes(String? category) {
    switch (category) {
      case 'Residential':
        return [
          {'id': 1, 'name': 'Apartment'},
          {'id': 2, 'name': 'Plot'},
          {'id': 3, 'name': 'House'},
          {'id': 4, 'name': 'Villa'},
        ];
      case 'Commercial':
        return [
          {'id': 5, 'name': 'Office'},
          {'id': 6, 'name': 'Plot'},
          {'id': 7, 'name': 'Shop'},
          {'id': 8, 'name': 'Warehouse'},
        ];
      default:
        return [];
    }
  }
}
