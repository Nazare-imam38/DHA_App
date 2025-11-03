import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

class UserService {
  static const String baseUrl = 'https://testingbackend.dhamarketplace.com/api';
  
  // Get user details from API
  Future<Map<String, dynamic>?> getUserDetails() async {
    try {
      print('🔄 UserService.getUserDetails() called');
      
      // Get auth token using AuthService
      final authService = AuthService();
      final token = await authService.getToken();
      
      print('🔑 Auth token check:');
      print('   Token exists: ${token != null}');
      print('   Token length: ${token?.length ?? 0}');
      if (token != null && token.length > 20) {
        print('   Token preview: ${token.substring(0, 20)}...');
      }
      
      if (token == null) {
        print('❌ No auth token found via AuthService');
        return null;
      }
      
      print('🔄 Making API call to: $baseUrl/user');
      
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('📥 User API Response Status: ${response.statusCode}');
      print('📥 User API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        Map<String, dynamic>? data;
        try {
          final decoded = json.decode(response.body);
          if (decoded is Map) {
            data = Map<String, dynamic>.from(decoded);
          }
        } catch (e) {
          print('❌ Error decoding JSON: $e');
          return null;
        }
        
        if (data == null) {
          print('❌ Decoded data is null or not a Map');
          return null;
        }
        
        print('📊 Parsed response data type: ${data.runtimeType}');
        print('📊 Response data: $data');
        
        // Handle different response formats
        if (data is Map<String, dynamic>) {
          if (data['success'] == true && data['data'] != null) {
            print('✅ Found data in success.data format');
            return Map<String, dynamic>.from(data['data']);
          } else if (data['user'] != null) {
            print('✅ Found data in user format');
            return Map<String, dynamic>.from(data['user']);
          } else {
            // Return the data directly if it contains user fields
            if (data.containsKey('name') || data.containsKey('cnic')) {
              print('✅ Found data in direct format');
              return data;
            } else {
              print('⚠️ Response does not contain expected user fields');
              print('   Available keys: ${data.keys.toList()}');
            }
          }
        } else {
          print('⚠️ Response is not a Map<String, dynamic>');
        }
      } else if (response.statusCode == 401) {
        print('❌ Authentication failed - token may be expired');
      } else {
        print('❌ User API Error: ${response.statusCode}');
        print('❌ Response: ${response.body}');
      }
      
      return null;
    } catch (e, stackTrace) {
      print('❌ Exception in getUserDetails: $e');
      print('❌ Stack trace: $stackTrace');
      return null;
    }
  }
  
  // Extract owner details from user data for property creation
  Map<String, dynamic> extractOwnerDetails(Map<String, dynamic> userData) {
    print('🔍 Extracting owner details from userData:');
    print('   Available keys: ${userData.keys.toList()}');
    
    // Helper function to get value from multiple possible keys
    String? getValue(List<String> keys) {
      for (var key in keys) {
        final value = userData[key];
        if (value != null && value.toString().trim().isNotEmpty) {
          print('   ✓ Found "${key}": ${value.toString()}');
          return value.toString().trim();
        }
      }
      print('   ✗ No value found for keys: $keys');
      return '';
    }
    
    final cnic = getValue(['cnic', 'id_number', 'idNumber', 'cnic_number', 'CNIC']);
    final name = getValue(['name', 'full_name', 'fullName', 'user_name', 'userName']);
    final phone = getValue(['phone', 'mobile', 'phone_number', 'phoneNumber', 'mobile_number', 'contact']);
    final address = getValue(['address', 'full_address', 'fullAddress', 'location', 'residential_address']);
    final email = getValue(['email', 'email_address', 'emailAddress', 'user_email']);
    
    final result = {
      'cnic': cnic ?? '',
      'name': name ?? '',
      'phone': phone ?? '',
      'address': address ?? '',
      'email': email ?? '',
    };
    
    print('📋 Extracted owner details:');
    print('   CNIC: "${result['cnic']}"');
    print('   Name: "${result['name']}"');
    print('   Phone: "${result['phone']}"');
    print('   Address: "${result['address']}"');
    print('   Email: "${result['email']}"');
    
    return result;
  }
  
  // Get complete owner details for property posting
  Future<Map<String, dynamic>?> getOwnerDetailsForProperty() async {
    try {
      print('🔄 UserService.getOwnerDetailsForProperty() called');
      final userData = await getUserDetails();
      
      print('📥 getUserDetails() returned: $userData');
      
      if (userData != null) {
        final ownerDetails = extractOwnerDetails(userData);
        
        print('✅ Extracted owner details:');
        print('   CNIC: ${ownerDetails['cnic']}');
        print('   Name: ${ownerDetails['name']}');
        print('   Phone: ${ownerDetails['phone']}');
        print('   Address: ${ownerDetails['address']}');
        print('   Email: ${ownerDetails['email']}');
        
        return ownerDetails;
      } else {
        print('❌ getUserDetails() returned null');
      }
      return null;
    } catch (e, stackTrace) {
      print('❌ Error getting owner details: $e');
      print('❌ Stack trace: $stackTrace');
      return null;
    }
  }
}