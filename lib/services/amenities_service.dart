import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class AmenitiesService {
  static const String baseUrl = 'https://testingbackend.dhamarketplace.com/api';
  final AuthService _authService = AuthService();

  /// Fetch amenities grouped by category for a given property type id
  Future<Map<String, List<Map<String, dynamic>>>> fetchAmenitiesByPropertyType({
    required int propertyTypeId,
  }) async {
    final uri = Uri.parse('$baseUrl/amenities/by-property-type')
        .replace(queryParameters: {'property_type_id': '$propertyTypeId'});

    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Unauthenticated: missing token. Please login again.');
    }

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401) {
      throw Exception('Unauthenticated: invalid/expired token (401). Please login again.');
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to load amenities (${response.statusCode})');
    }

    final jsonBody = json.decode(response.body) as Map<String, dynamic>;
    if (jsonBody['success'] != true || jsonBody['data'] == null) {
      return {};
    }

    final data = jsonBody['data'] as Map<String, dynamic>;
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    data.forEach((category, items) {
      if (items is List) {
        grouped[category.toString()] = items
            .whereType<Map<String, dynamic>>()
            .map((e) => {
                  'id': e['id'],
                  'name': e['amenity_name'],
                  'description': e['description'],
                })
            .toList();
      }
    });

    return grouped;
  }

  // Back-compat alias for older callers
  Future<Map<String, List<Map<String, dynamic>>>> getAmenitiesByPropertyType(
    int propertyTypeId,
  ) => fetchAmenitiesByPropertyType(propertyTypeId: propertyTypeId);
}


