import 'dart:convert';
import 'package:http/http.dart' as http;

class PropertyTypeService {
  static const String baseUrl = 'https://testingbackend.dhamarketplace.com/api';
  
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
      
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'parent_id[]': parentId.toString(),
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
      
      // Fallback to empty list
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
