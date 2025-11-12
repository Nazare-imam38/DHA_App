import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class PropertyApprovalService {
  static const String baseUrl = 'https://marketplace-testingbackend.dhamarketplace.com/api';
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>> checkApprovalStatus({required String propertyId}) async {
    final url = Uri.parse('$baseUrl/property/user-approval');
    try {
      final token = await _authService.getToken();
      if (token == null) {
        return { 'success': false, 'message': 'Authentication token missing.' };
      }

      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['property_id'] = propertyId;

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return { 'success': true, 'data': data };
      }

      if (response.statusCode == 401) {
        return { 'success': false, 'message': 'Unauthorized (401). Please re-login.' };
      }

      return { 'success': false, 'message': 'API error: ${response.statusCode}', 'body': response.body };
    } catch (e) {
      return { 'success': false, 'message': 'Exception: $e' };
    }
  }
}


