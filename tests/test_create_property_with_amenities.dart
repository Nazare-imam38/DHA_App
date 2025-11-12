import 'dart:convert';
import 'package:http/http.dart' as http;

// Test script to create a property with amenities and then fetch it back
void main() async {
  const String baseUrl = 'https://testingbackend.dhamarketplace.com/api';
  const String authToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIwMTlhMzkzOC0xOGE1LTcwMWYtYjE4MS1hOTJlYWQxNWVkMzUiLCJqdGkiOiJiYzMzZGUwZTI3MjhmOTZmYzYwNTNiNGYxMWZiZGM5YzIzMzgxZGQyYjBhNmI4NzE5MDlhZmY4YjkyOGRlMDVlZDNmNDYzZTJkY2Q2MmM2YiIsImlhdCI6MTc2MTkxMTEyMC40MjE4MiwibmJmIjoxNzYxOTExMTIwLjQyMTgyMywiZXhwIjoxNzkzNDQ3MTIwLjQxMjEwMiwic3ViIjoiMjUiLCJzY29wZXMiOltdfQ.Yf0ayK8j6YmIx8jTeZsXXki3LwRFi9JUsyis8_A9Q_NzehP7Uui6dhQ-KIGYuUAHyFCUzrQe1tu4OH7r5dNlqwKhUfkonCWF1QvTtjpcNlXncXjCSCFCin0WBKO2BwiQQyaokqbcK-bCVvhiHCJDD6_OWD-2sdbdjwG51tUYRIOLtshE8G4PpXwtGv72EO1GdNhYqfvS3k8aiNkQIfOAOuWXBq3nhnmkeAHaKcRUzTop7iGxX942gAwQgXxSjpXhgOrnwCj-L5WZTXdsmajJuG91lHWpfpuxIqdrLmjZlrYlFiKI9rNOR_J8MbVpz8KaVtWnmaxUIyrExiN1F8AnTuJY_Gc48Y_T_Wxr02uduQRRQl8FUUJUD55amc0eJWPOkfIjgJCrC65MaYHJZsR0H_2Qw16qeKUniQ_mUV9CVARPch6iP8SxdLCZ6F2foCyIHhdbwFQjwxrwBPghDlx1s7AhY6oMVuBkYCk84gMdPYCGb8KEEjau60zUAP_ltTyMGSwAXCfvAos6nIVd5PocZGPp670OKDENl9STxbnR9iWMTLJy5EY45OJJFiuzZypRZRFqrUS7AWRTjwto2WIjgTjbmfjFNRTBHFU6XQ10d9wFlp9fgxBCrbKRVcPASlr4XI-gUfEA6Da5o9gd-RngWn1BR9tVOUVUKUF62rJoC80';

  print('Testing Create Property with Amenities...\n');

  // Step 1: Create a property with amenities (similar to your payload)
  print('1. Creating property with amenities...');
  
  try {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/create/property'),
    );
    
    request.headers['Authorization'] = 'Bearer $authToken';
    
    // Add the same fields as your payload
    request.fields.addAll({
      'title': 'TEST AMENITIES PROPERTY',
      'description': 'Testing amenities functionality',
      'purpose': 'Sell',
      'category': 'Residential',
      'property_type_id': '5', // Apartment
      'property_duration': '15 days',
      'is_rent': '0',
      'location': '33.544674, 73.093578',
      'latitude': '33.54467423780209',
      'longitude': '73.0935780484061',
      'building': 'Tower',
      'floor': '3rd Floor',
      'apartment_number': 'A-33',
      'area': '6',
      'area_unit': 'Marla',
      'phase': 'Phase 1',
      'sector': 'block 2',
      'street_number': 'street 5',
      'unit_no': 'A-33',
      'payment_method': 'KuickPay',
      'on_behalf': '0',
      'price': '22222',
    });
    
    // Add amenities as array (same as your payload)
    request.fields['amenities[0]'] = '3';
    request.fields['amenities[1]'] = '4';
    request.fields['amenities[2]'] = '13';
    request.fields['amenities[3]'] = '15';
    request.fields['amenities[4]'] = '22';
    request.fields['amenities[5]'] = '23';
    request.fields['amenities[6]'] = '29';
    request.fields['amenities[7]'] = '38';
    
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    
    print('Create Property Status: ${response.statusCode}');
    print('Create Property Response: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      
      if (data['data'] != null) {
        final propertyId = data['data']['id']?.toString();
        print('✅ Property created successfully! ID: $propertyId');
        
        if (propertyId != null) {
          // Step 2: Fetch the created property to see if amenities are saved
          print('\n2. Fetching created property details...');
          
          await Future.delayed(Duration(seconds: 2)); // Wait a bit for DB to update
          
          final detailsResponse = await http.get(
            Uri.parse('$baseUrl/property/$propertyId'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
          );
          
          print('Property Details Status: ${detailsResponse.statusCode}');
          
          if (detailsResponse.statusCode == 200) {
            final detailsData = json.decode(detailsResponse.body);
            
            if (detailsData['data'] != null) {
              final property = detailsData['data'];
              print('Property Details:');
              print('  ID: ${property['id']}');
              print('  Title: ${property['title']}');
              print('  Amenities: ${property['amenities']}');
              print('  Amenities Type: ${property['amenities'].runtimeType}');
              
              if (property['amenities'] is List) {
                final amenitiesList = property['amenities'] as List;
                print('  Amenities Count: ${amenitiesList.length}');
                
                if (amenitiesList.isNotEmpty) {
                  print('  ✅ AMENITIES FOUND IN RESPONSE!');
                  for (int i = 0; i < amenitiesList.length; i++) {
                    final amenity = amenitiesList[i];
                    print('    Amenity $i: $amenity (${amenity.runtimeType})');
                  }
                } else {
                  print('  ❌ No amenities in response - they may not be saved or returned');
                }
              }
              
              // Check amenities_by_category
              if (property.containsKey('amenities_by_category')) {
                print('  Amenities By Category: ${property['amenities_by_category']}');
              }
            }
          } else {
            print('Error fetching property details: ${detailsResponse.body}');
          }
          
          // Step 3: Check customer-properties endpoint
          print('\n3. Checking customer-properties endpoint...');
          
          final customerPropsResponse = await http.get(
            Uri.parse('$baseUrl/customer-properties'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $authToken',
            },
          );
          
          if (customerPropsResponse.statusCode == 200) {
            final customerData = json.decode(customerPropsResponse.body);
            
            if (customerData['data'] is List) {
              final properties = customerData['data'] as List;
              
              // Find our created property
              final createdProperty = properties.firstWhere(
                (p) => p['id'].toString() == propertyId,
                orElse: () => null,
              );
              
              if (createdProperty != null) {
                print('Found created property in customer-properties:');
                print('  ID: ${createdProperty['id']}');
                print('  Title: ${createdProperty['title']}');
                print('  Amenities: ${createdProperty['amenities']}');
                print('  Amenities Count: ${createdProperty['amenities'] is List ? (createdProperty['amenities'] as List).length : 0}');
              } else {
                print('Created property not found in customer-properties list');
              }
            }
          }
        }
      } else {
        print('❌ Property creation failed: ${data['message']}');
      }
    } else {
      print('❌ Property creation failed with status ${response.statusCode}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}