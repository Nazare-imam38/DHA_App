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

  // Get approved properties for browsing (public listing)
  Future<Map<String, dynamic>> getApprovedProperties({
    String? purpose,
    int perPage = 9,
    int page = 1,
    String? overrideToken,
  }) async {
    try {
      final token = overrideToken ?? await _authService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication token missing. Please login again.',
        };
      }

      print('🏠 Fetching approved properties...');
      
      // Build query parameters
      final queryParams = <String, String>{
        'per_page': perPage.toString(),
        'page': page.toString(),
      };
      if (purpose != null && purpose.isNotEmpty) {
        queryParams['purpose'] = purpose;
      }
      
      final uri = Uri.parse('$baseUrl/properties').replace(queryParameters: queryParams);
      
      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📊 Approved Properties Response Status: ${response.statusCode}');
      print('📄 Approved Properties Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        
        // Handle different response structures
        if (decoded is Map<String, dynamic>) {
          final map = Map<String, dynamic>.from(decoded);
          
          // Check for data property
          if (map['data'] != null) {
            final data = map['data'];
            // Convert to List explicitly if it's a list-like structure
            if (data is List) {
              // Ensure it's a proper Dart List
              final propertiesList = List<Map<String, dynamic>>.from(
                data.map((item) => item is Map ? Map<String, dynamic>.from(item) : <String, dynamic>{})
                    .where((item) => item.isNotEmpty)
              );
              return {'success': true, 'data': {'properties': propertiesList}, 'pagination': map['meta']};
            } else if (data is Map<String, dynamic> && data['data'] is List) {
              final propertiesList = List<Map<String, dynamic>>.from(
                (data['data'] as List).map((item) => item is Map ? Map<String, dynamic>.from(item) : <String, dynamic>{})
                    .where((item) => item.isNotEmpty)
              );
              return {'success': true, 'data': {'properties': propertiesList}, 'pagination': data['meta']};
            }
          }
          
          // Check for properties at top level
          if (map['properties'] is List) {
            final propertiesList = List<Map<String, dynamic>>.from(
              (map['properties'] as List).map((item) => item is Map ? Map<String, dynamic>.from(item) : <String, dynamic>{})
                  .where((item) => item.isNotEmpty)
            );
            return {'success': true, 'data': {'properties': propertiesList}, 'pagination': map['meta']};
          }
          
          // Return entire map if it's a single property or different structure
          return {'success': true, 'data': map};
        } else if (decoded is List) {
          // Convert list to List<Map<String, dynamic>>
          final propertiesList = List<Map<String, dynamic>>.from(
            decoded.map((item) => item is Map ? Map<String, dynamic>.from(item) : <String, dynamic>{})
                .where((item) => item.isNotEmpty)
          );
          return {'success': true, 'data': {'properties': propertiesList}};
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
      print('❌ Error fetching approved properties: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Delete property by ID
  Future<Map<String, dynamic>> deleteProperty(String propertyId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication token missing. Please login again.',
        };
      }

      print('🗑️ Deleting property: $propertyId');

      final response = await http.delete(
        Uri.parse('$baseUrl/delete/property/$propertyId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📊 Delete Property Response Status: ${response.statusCode}');
      print('📄 Delete Property Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        final responseData = response.body.isNotEmpty 
            ? json.decode(response.body) as Map<String, dynamic>
            : {'message': 'Property deleted successfully'};
        return {
          'success': true,
          'data': responseData,
          'message': responseData['message'] ?? 'Property deleted successfully',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Unauthorized. Please login again.',
        };
      } else {
        final errorData = response.body.isNotEmpty 
            ? json.decode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to delete property. Status: ${response.statusCode}',
          'body': response.body,
        };
      }
    } catch (e) {
      print('❌ Error deleting property: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Add property to favorites
  Future<Map<String, dynamic>> addFavoriteProperty(String propertyId, {String? overrideToken}) async {
    try {
      final token = overrideToken ?? await _authService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication token missing. Please login again.',
        };
      }

      print('⭐ Adding property $propertyId to favorites...');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/add/favorite/property'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';
      request.fields['property_id'] = propertyId;

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      print('📊 Add Favorite Response Status: ${response.statusCode}');
      print('📄 Add Favorite Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.body.isNotEmpty 
            ? json.decode(response.body) as Map<String, dynamic>
            : {'message': 'Property added to favorites successfully'};
        return {
          'success': true,
          'data': data,
          'message': data['message'] ?? 'Property added to favorites successfully',
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'message': 'Unauthorized. Please login again.',
        };
      } else {
        final errorData = response.body.isNotEmpty 
            ? json.decode(response.body) as Map<String, dynamic>
            : <String, dynamic>{};
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to add property to favorites. Status: ${response.statusCode}',
          'body': response.body,
        };
      }
    } catch (e) {
      print('❌ Error adding property to favorites: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }
}