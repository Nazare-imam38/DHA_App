import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class CustomerPropertiesService {
  static const String baseUrl = 'https://testingbackend.dhamarketplace.com/api';
  final AuthService _authService = AuthService();

  // Get all properties posted by the current user
  Future<Map<String, dynamic>> getCustomerProperties() async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication token missing. Please login again.',
        };
      }

      print('🏠 Fetching customer properties...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/customer-properties'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📊 Customer Properties Response Status: ${response.statusCode}');
      print('📄 Customer Properties Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return {
          'success': true,
          'data': data,
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Unauthorized. Please login again.',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch properties. Status: ${response.statusCode}',
          'body': response.body,
        };
      }
    } catch (e) {
      print('❌ Error fetching customer properties: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get approval status for a specific property
  Future<Map<String, dynamic>> getPropertyApprovalStatus(String propertyId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication token missing.',
        };
      }

      print('🔍 Checking approval status for property: $propertyId');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/property/user-approval'),
      );
      
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['property_id'] = propertyId;

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      print('📊 Approval Status Response: ${response.statusCode}');
      print('📄 Approval Status Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to get approval status. Status: ${response.statusCode}',
          'body': response.body,
        };
      }
    } catch (e) {
      print('❌ Error getting approval status: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}