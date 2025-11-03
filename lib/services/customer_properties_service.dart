import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class CustomerPropertiesService {
  static const String baseUrl = 'https://testingbackend.dhamarketplace.com/api';
  final AuthService _authService = AuthService();

  // Get all properties posted by the current user
  // Optional: pass an override token for testing specific responses
  Future<Map<String, dynamic>> getCustomerProperties({String? overrideToken}) async {
    try {
      final token = overrideToken ?? await _authService.getToken();
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
        final decoded = json.decode(response.body);
        // Normalize to a map with a 'properties' list when possible
        if (decoded is Map<String, dynamic>) {
          final map = Map<String, dynamic>.from(decoded);
          final dynamic inner = map['data'];
          if (inner is List) {
            print('📦 Parsed ${inner.length} properties from customer-properties API');
            // Debug: Check first property's media and amenities
            if (inner.isNotEmpty && inner[0] is Map) {
              final firstProp = inner[0] as Map;
              
              // Check media
              final media = firstProp['media'];
              if (media != null && media is List) {
                print('📸 First property has ${media.length} media items');
                for (int i = 0; i < media.length; i++) {
                  final item = media[i];
                  if (item is Map) {
                    final mediaLink = item['media_link']?.toString();
                    final mediaType = item['media_type']?.toString();
                    print('   📷 Media $i: type=$mediaType, link=${mediaLink != null ? mediaLink.substring(0, mediaLink.length > 60 ? 60 : mediaLink.length) : "null"}...');
                  }
                }
              } else {
                print('⚠️ First property has no media or media is not a list');
              }
              
              // Check amenities
              final amenities = firstProp['amenities'];
              print('🔍 First property amenities: $amenities (type: ${amenities.runtimeType})');
            }
            return {'success': true, 'data': {'properties': inner}};
          }
          if (inner is Map<String, dynamic>) {
            if (inner['properties'] is List) {
              return {'success': true, 'data': {'properties': inner['properties']}};
            }
            if (inner['data'] is List) {
              return {'success': true, 'data': {'properties': inner['data']}};
            }
          }
          // Maybe properties at top-level key
          if (map['properties'] is List) {
            return {'success': true, 'data': {'properties': map['properties']}};
          }
          // Fallback: return entire decoded map
          return {'success': true, 'data': map};
        } else if (decoded is List) {
          return {'success': true, 'data': {'properties': decoded}};
        }
        return {
          'success': false,
          'message': 'Unexpected response shape',
          'body': response.body,
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

  // Get property details by ID (includes amenities)
  Future<Map<String, dynamic>> getPropertyDetails(String propertyId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication token missing.',
        };
      }

      print('🔍 Fetching property details for: $propertyId');

      final response = await http.get(
        Uri.parse('$baseUrl/property/$propertyId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📊 Property Details Response Status: ${response.statusCode}');
      print('📄 Property Details Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return {
          'success': true,
          'data': data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to get property details. Status: ${response.statusCode}',
          'body': response.body,
        };
      }
    } catch (e) {
      print('❌ Error getting property details: $e');
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