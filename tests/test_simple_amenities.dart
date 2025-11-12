import 'dart:convert';
import 'package:http/http.dart' as http;

// Simple test to verify amenities API and create a property
void main() async {
  const String baseUrl = 'https://marketplace-testingbackend.dhamarketplace.com/api';
  const String authToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIwMTlhMzkzOC0xOGE1LTcwMWYtYjE4MS1hOTJlYWQxNWVkMzUiLCJqdGkiOiJiYzMzZGUwZTI3MjhmOTZmYzYwNTNiNGYxMWZiZGM5YzIzMzgxZGQyYjBhNmI4NzE5MDlhZmY4YjkyOGRlMDVlZDNmNDYzZTJkY2Q2MmM2YiIsImlhdCI6MTc2MTkxMTEyMC40MjE4MiwibmJmIjoxNzYxOTExMTIwLjQyMTgyMywiZXhwIjoxNzkzNDQ3MTIwLjQxMjEwMiwic3ViIjoiMjUiLCJzY29wZXMiOltdfQ.Yf0ayK8j6YmIx8jTeZsXXki3LwRFi9JUsyis8_A9Q_NzehP7Uui6dhQ-KIGYuUAHyFCUzrQe1tu4OH7r5dNlqwKhUfkonCWF1QvTtjpcNlXncXjCSCFCin0WBKO2BwiQQyaokqbcK-bCVvhiHCJDD6_OWD-2sdbdjwG51tUYRIOLtshE8G4PpXwtGv72EO1GdNhYqfvS3k8aiNkQIfOAOuWXBq3nhnmkeAHaKcRUzTop7iGxX942gAwQgXxSjpXhgOrnwCj-L5WZTXdsmajJuG91lHWpfpuxIqdrLmjZlrYlFiKI9rNOR_J8MbVpz8KaVtWnmaxUIyrExiN1F8AnTuJY_Gc48Y_T_Wxr02uduQRRQl8FUUJUD55amc0eJWPOkfIjgJCrC65MaYHJZsR0H_2Qw16qeKUniQ_mUV9CVARPch6iP8SxdLCZ6F2foCyIHhdbwFQjwxrwBPghDlx1s7AhY6oMVuBkYCk84gMdPYCGb8KEEjau60zUAP_ltTyMGSwAXCfvAos6nIVd5PocZGPp670OKDENl9STxbnR9iWMTLJy5EY45OJJFiuzZypRZRFqrUS7AWRTjwto2WIjgTjbmfjFNRTBHFU6XQ10d9wFlp9fgxBCrbKRVcPASlr4XI-gUfEA6Da5o9gd-RngWn1BR9tVOUVUKUF62rJoC80';

  print('Testing Simple Amenities Approach...\n');

  // Step 1: Test amenities API for apartment (property type 5)
  print('1. Testing amenities API for Apartment (ID: 5)...');
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/amenities/by-property-type?property_type_id=5'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );
    
    print('Status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Success: ${data['success']}');
      
      if (data['data'] != null) {
        print('Available amenities for Apartment:');
        data['data'].forEach((categoryName, amenitiesList) {
          print('\n$categoryName:');
          for (var amenity in amenitiesList) {
            print('  - ID: ${amenity['id']}, Name: ${amenity['amenity_name']}');
          }
        });
        
        // Extract some amenity IDs for testing
        List<int> testAmenityIds = [];
        data['data'].forEach((categoryName, amenitiesList) {
          for (var amenity in amenitiesList) {
            if (testAmenityIds.length < 4) {
              testAmenityIds.add(amenity['id']);
            }
          }
        });
        
        print('\nSelected amenity IDs for testing: $testAmenityIds');
        
        // Step 2: Create a property with these amenities
        print('\n2. Creating property with selected amenities...');
        
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/create/property'),
        );
        
        request.headers['Authorization'] = 'Bearer $authToken';
        
        // Basic property data
        request.fields.addAll({
          'title': 'SIMPLE AMENITIES TEST',
          'description': 'Testing simplified amenities approach',
          'purpose': 'Sell',
          'category': 'Residential',
          'property_type_id': '5',
          'property_duration': '15 days',
          'is_rent': '0',
          'location': '33.544674, 73.093578',
          'latitude': '33.54467423780209',
          'longitude': '73.0935780484061',
          'building': 'Simple Tower',
          'floor': '1st Floor',
          'apartment_number': 'S-11',
          'area': '4',
          'area_unit': 'Marla',
          'phase': 'Phase 1',
          'sector': 'Sector S',
          'street_number': 'Street 1',
          'unit_no': 'S-11',
          'payment_method': 'KuickPay',
          'on_behalf': '0',
          'price': '4000000',
        });
        
        // Add amenities
        for (int i = 0; i < testAmenityIds.length; i++) {
          request.fields['amenities[$i]'] = testAmenityIds[i].toString();
        }
        
        final streamed = await request.send();
        final createResponse = await http.Response.fromStream(streamed);
        
        print('Create Status: ${createResponse.statusCode}');
        if (createResponse.statusCode == 200 || createResponse.statusCode == 201) {
          final createData = json.decode(createResponse.body);
          final propertyId = createData['data']?['id']?.toString();
          print('✅ Property created! ID: $propertyId');
          print('✅ Amenities sent: $testAmenityIds');
          print('✅ Now the app should display these amenities using the amenities API');
        } else {
          print('❌ Property creation failed: ${createResponse.body}');
        }
      }
    } else {
      print('❌ Amenities API failed: ${response.body}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}