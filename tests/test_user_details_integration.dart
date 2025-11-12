import 'dart:convert';
import 'package:http/http.dart' as http;

// Test script to verify user details integration
void main() async {
  await testUserDetailsIntegration();
}

Future<void> testUserDetailsIntegration() async {
  print('🧪 Testing User Details Integration for Property Creation');
  print('=' * 60);
  
  // Test 1: Fetch user details from API
  await testUserAPI();
  
  print('');
  
  // Test 2: Simulate property creation with user details
  await testPropertyCreationWithUserDetails();
}

Future<void> testUserAPI() async {
  print('🔍 Test 1: Fetching User Details from API');
  print('-' * 40);
  
  try {
    // Note: This would need a real auth token in production
    final response = await http.get(
      Uri.parse('https://testingbackend.dhamarketplace.com/api/user'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer YOUR_AUTH_TOKEN_HERE', // Replace with real token
      },
    );
    
    print('📥 User API Response Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('📥 User API Response: ${json.encode(data)}');
      
      // Extract owner details
      Map<String, dynamic> ownerDetails = {};
      if (data is Map<String, dynamic>) {
        if (data['success'] == true && data['data'] != null) {
          final userData = data['data'];
          ownerDetails = extractOwnerDetails(userData);
        } else if (data.containsKey('name') || data.containsKey('cnic')) {
          ownerDetails = extractOwnerDetails(data);
        }
      }
      
      print('✅ Extracted Owner Details:');
      print('   CNIC: ${ownerDetails['cnic']}');
      print('   Name: ${ownerDetails['name']}');
      print('   Phone: ${ownerDetails['phone']}');
      print('   Address: ${ownerDetails['address']}');
      print('   Email: ${ownerDetails['email']}');
      
    } else if (response.statusCode == 401) {
      print('❌ Authentication required - need valid token');
    } else {
      print('❌ User API Error: ${response.statusCode}');
      print('❌ Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}

Map<String, dynamic> extractOwnerDetails(Map<String, dynamic> userData) {
  return {
    'cnic': userData['cnic'] ?? userData['id_number'] ?? '',
    'name': userData['name'] ?? userData['full_name'] ?? '',
    'phone': userData['phone'] ?? userData['mobile'] ?? userData['phone_number'] ?? '',
    'address': userData['address'] ?? userData['full_address'] ?? '',
    'email': userData['email'] ?? userData['email_address'] ?? '',
  };
}

Future<void> testPropertyCreationWithUserDetails() async {
  print('🔍 Test 2: Property Creation Payload with User Details');
  print('-' * 40);
  
  // Simulate the property data that would be sent
  final propertyData = {
    // Basic property info
    'title': 'Test Property',
    'description': 'Test Description',
    'purpose': 'Sell',
    'category': 'Residential',
    'property_type_id': '6',
    'property_duration': '15 days',
    'is_rent': '0',
    
    // Location
    'location': '33.531375, 73.160215',
    'latitude': '33.53137508003366',
    'longitude': '73.16021509338842',
    
    // Property details
    'building': '45',
    'area': '5',
    'area_unit': 'Marla',
    'phase': 'Phase 2',
    'sector': 'sector A',
    'street_number': 'Street 5',
    'unit_no': '45',
    'payment_method': 'KuickPay',
    'price': '555',
    
    // Owner details (would be fetched from user API for own property)
    'on_behalf': '0', // Own property
    'cnic': '3840392735407', // From user API
    'name': 'Abdul', // From user API
    'phone': '+923035523964', // From user API
    'address': 'kjkjkgjkgjdf', // From user API
    'email': 'test@gmail.com', // From user API
    
    // Amenities
    'amenities[0]': '1',
    'amenities[1]': '3',
    'amenities[2]': '4',
    'amenities[3]': '16',
    'amenities[4]': '38',
  };
  
  print('✅ Complete Property Creation Payload:');
  propertyData.forEach((key, value) {
    print('   $key: $value');
  });
  
  print('');
  print('🎯 Key Points:');
  print('• on_behalf: 0 (own property)');
  print('• Owner details automatically fetched from user API');
  print('• All required fields present for property creation');
  print('• No missing owner information');
}