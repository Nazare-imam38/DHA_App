import 'dart:convert';
import 'package:http/http.dart' as http;

// Test script to verify amenities API integration
void main() async {
  const String baseUrl = 'https://testingbackend.dhamarketplace.com/api';
  const String authToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIwMTlhMmExZC0xMjEyLTczZGYtODE5OS1iMmM5MGM1NmE4NDIiLCJqdGkiOiJkOWE1NDVhMTVmZjNlMWRhYmQyYTFhY2YyZWUxMDYyNDliMDA3MWI1ZDVhYmEyZDYzNWYwN2UxNTc3MWU3M2Y0NWI4N2M5NWUwYjJhYTlmMSIsImlhdCI6MTc2MTc1NjkwNS44NjY2MDQsIm5iZiI6MTc2MTc1NjkwNS44NjY2MDcsImV4cCI6MTc5MzI5MjkwNS44NTYyNDUsInN1YiI6IjE5Iiwic2NvcGVzIjpbXX0.VQEPRjoP-7k9QMm2G8mir-idpWgFvjlRa1BEzV9Om2a3B1Wcp6u2A51vkqI4eXJ9fFSRsWXAmAd-IDMl77l6R8y6d-ej-C9ezCxsJ_oQZLGYporFSABHoSo2-a-z9wyuMuStFyz3PwNmqddsHx5MWfbvdAjoQFejK4BOmoLDkiXqkF6enBYMbfdssRLbA7q52aKZYv3C2dgmP5m5Smw0e2DbVpKxSZ0LvCuV51SvjMHvx6pwdsZmqw-C6AstKa_kOojctfPLX_aLIUgDDUesdVw0i9JQ6-l0FkjvNYRuOtJemGwBB4oO7vCCWExZpcBERE9N3clZ0QPl09kxrpDNgaXRzWGX_W_OgXsVLql3KjH5ur-S2jotdjUV8c2PxT3ZxC1w-2kmqpzvyELp8o3k0bHMKzIhfIUqA2pjFVDxHC9ukvw2F9AylaVD-KbzA2_oJPg8XsKvgNn12C1Jgc--GZvsuzKdZUdEj9sZN9ld3oEnjjzgMOB8r6-QUCA4Qbu52dHa7jYceS_Bt0EoFT68Y2-verzaTpj_uNZvGpgLUunAjoaKLw6CPS5taFtCDmXP4v3ON4_oJ0a3vi12koSTgQVJE8aD3AndnjUunmnW_PNZzM6podx6wxDNfcsFEI8PMzrKQ18g-etB1_bqvpv7qdrOa9SwqIq6BAW9G8jhWbk';

  print('Testing Amenities API Integration...\n');

  // Test 1: Property Types API
  print('1. Testing Property Types API...');
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/property/types?category=Residential&purpose=Sell'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    print('Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Success: ${data['success']}');
      print('Property Types:');
      for (var type in data['data']) {
        print('  - ID: ${type['id']}, Name: ${type['name']}, Purpose: ${type['purpose']}, Category: ${type['category']}');
      }
    } else {
      print('Error: ${response.body}');
    }
  } catch (e) {
    print('Exception: $e');
  }

  print('\n' + '='*50 + '\n');

  // Test 2: Amenities API for Apartment (ID: 5)
  print('2. Testing Amenities API for Apartment (ID: 5)...');
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/amenities/by-property-type?property_type_id=5'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );
    
    print('Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Success: ${data['success']}');
      print('Message: ${data['message']}');
      
      if (data['data'] != null) {
        print('\nAmenities by Category:');
        data['data'].forEach((categoryName, amenitiesList) {
          print('\n$categoryName:');
          for (var amenity in amenitiesList) {
            print('  - ID: ${amenity['id']}, Name: ${amenity['amenity_name']}, Description: ${amenity['description']}');
          }
        });
      }
    } else {
      print('Error: ${response.body}');
    }
  } catch (e) {
    print('Exception: $e');
  }

  print('\n' + '='*50 + '\n');

  // Test 3: Amenities API for Plot (ID: 6)
  print('3. Testing Amenities API for Plot (ID: 6)...');
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/amenities/by-property-type?property_type_id=6'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );
    
    print('Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Success: ${data['success']}');
      print('Message: ${data['message']}');
      
      if (data['data'] != null) {
        print('\nAmenities by Category:');
        data['data'].forEach((categoryName, amenitiesList) {
          print('\n$categoryName:');
          for (var amenity in amenitiesList) {
            print('  - ID: ${amenity['id']}, Name: ${amenity['amenity_name']}, Description: ${amenity['description']}');
          }
        });
      }
    } else {
      print('Error: ${response.body}');
    }
  } catch (e) {
    print('Exception: $e');
  }

  print('\n' + '='*50 + '\n');
  print('API Testing Complete!');
}
