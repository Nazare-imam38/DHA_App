import 'dart:convert';
import 'package:http/http.dart' as http;

// Test script to verify new amenities format
void main() async {
  await testNewAmenitiesFormat();
}

Future<void> testNewAmenitiesFormat() async {
  print('🧪 Testing New Amenities Format');
  print('=' * 50);
  
  const String baseUrl = 'https://marketplace-testingbackend.dhamarketplace.com/api';
  const String authToken = 'YOUR_AUTH_TOKEN_HERE'; // Replace with real token
  
  // Simulate the scenario you described
  const int propertyTypeId = 9; // From Step 3 (category + property type selection)
  const List<int> selectedAmenityIds = [3, 5, 7]; // From Step 5 (user selection)
  
  print('📋 Scenario:');
  print('   Property Type ID: $propertyTypeId (from Step 3)');
  print('   Selected Amenity IDs: $selectedAmenityIds (from Step 5)');
  print('');
  
  try {
    // Create multipart request
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/create/property'),
    );
    
    request.headers['Authorization'] = 'Bearer $authToken';
    
    // Add basic property fields
    request.fields['title'] = 'Test Property';
    request.fields['description'] = 'Test Description';
    request.fields['purpose'] = 'Sell';
    request.fields['category'] = 'Commercial';
    request.fields['property_type_id'] = propertyTypeId.toString();
    request.fields['property_duration'] = '15 days';
    request.fields['is_rent'] = '0';
    request.fields['location'] = 'Test Location';
    request.fields['latitude'] = '33.531375';
    request.fields['longitude'] = '73.160215';
    request.fields['building'] = 'Test Building';
    request.fields['area'] = '5';
    request.fields['area_unit'] = 'Marla';
    request.fields['phase'] = 'Phase 2';
    request.fields['sector'] = 'Sector A';
    request.fields['street_number'] = 'Street 5';
    request.fields['unit_no'] = '45';
    request.fields['payment_method'] = 'KuickPay';
    request.fields['price'] = '555';
    request.fields['on_behalf'] = '0';
    request.fields['cnic'] = '3840392735407';
    request.fields['name'] = 'Abdul';
    request.fields['phone'] = '+923035523964';
    request.fields['address'] = 'kjkjkgjkgjdf';
    request.fields['email'] = 'test@gmail.com';
    
    // NEW AMENITIES FORMAT: amenities[property_type_id][amenity_id]
    print('📤 Adding amenities in new format:');
    for (final amenityId in selectedAmenityIds) {
      final fieldKey = 'amenities[$propertyTypeId][$amenityId]';
      request.fields[fieldKey] = ''; // Optional value
      print('   $fieldKey = ""');
    }
    
    print('');
    print('📋 Complete Request Fields:');
    request.fields.forEach((key, value) {
      if (key.startsWith('amenities')) {
        print('   🏠 $key = "$value"');
      } else {
        print('   📝 $key = "$value"');
      }
    });
    
    print('');
    print('✅ Expected API Behavior:');
    print('   • Backend receives amenities in nested format');
    print('   • Property Type ID $propertyTypeId is the key');
    print('   • Amenity IDs $selectedAmenityIds are sub-keys');
    print('   • Format: amenities[9][3], amenities[9][5], amenities[9][7]');
    
    // Note: Uncomment below to actually send the request
    /*
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    print('');
    print('📥 Response Status: ${response.statusCode}');
    print('📥 Response Body: $responseBody');
    */
    
  } catch (e) {
    print('❌ Error: $e');
  }
}

// Simulate fetching amenities for property type
Future<void> simulateAmenitiesFetch() async {
  print('');
  print('🔍 Simulating Amenities Fetch:');
  print('   GET /api/amenities/by-property-type?property_type_id=9');
  print('   Response: List of amenities available for property type 9');
  print('   User selects amenities with IDs: 3, 5, 7');
  print('   These IDs are then used in the nested format');
}