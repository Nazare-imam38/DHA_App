import 'dart:convert';
import 'package:http/http.dart' as http;

// Test script to create a property with complete amenity details
void main() async {
  const String baseUrl = 'https://marketplace-testingbackend.dhamarketplace.com/api';
  const String authToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIwMTlhMzkzOC0xOGE1LTcwMWYtYjE4MS1hOTJlYWQxNWVkMzUiLCJqdGkiOiJiYzMzZGUwZTI3MjhmOTZmYzYwNTNiNGYxMWZiZGM5YzIzMzgxZGQyYjBhNmI4NzE5MDlhZmY4YjkyOGRlMDVlZDNmNDYzZTJkY2Q2MmM2YiIsImlhdCI6MTc2MTkxMTEyMC40MjE4MiwibmJmIjoxNzYxOTExMTIwLjQyMTgyMywiZXhwIjoxNzkzNDQ3MTIwLjQxMjEwMiwic3ViIjoiMjUiLCJzY29wZXMiOltdfQ.Yf0ayK8j6YmIx8jTeZsXXki3LwRFi9JUsyis8_A9Q_NzehP7Uui6dhQ-KIGYuUAHyFCUzrQe1tu4OH7r5dNlqwKhUfkonCWF1QvTtjpcNlXncXjCSCFCin0WBKO2BwiQQyaokqbcK-bCVvhiHCJDD6_OWD-2sdbdjwG51tUYRIOLtshE8G4PpXwtGv72EO1GdNhYqfvS3k8aiNkQIfOAOuWXBq3nhnmkeAHaKcRUzTop7iGxX942gAwQgXxSjpXhgOrnwCj-L5WZTXdsmajJuG91lHWpfpuxIqdrLmjZlrYlFiKI9rNOR_J8MbVpz8KaVtWnmaxUIyrExiN1F8AnTuJY_Gc48Y_T_Wxr02uduQRRQl8FUUJUD55amc0eJWPOkfIjgJCrC65MaYHJZsR0H_2Qw16qeKUniQ_mUV9CVARPch6iP8SxdLCZ6F2foCyIHhdbwFQjwxrwBPghDlx1s7AhY6oMVuBkYCk84gMdPYCGb8KEEjau60zUAP_ltTyMGSwAXCfvAos6nIVd5PocZGPp670OKDENl9STxbnR9iWMTLJy5EY45OJJFiuzZypRZRFqrUS7AWRTjwto2WIjgTjbmfjFNRTBHFU6XQ10d9wFlp9fgxBCrbKRVcPASlr4XI-gUfEA6Da5o9gd-RngWn1BR9tVOUVUKUF62rJoC80';

  print('Testing Enhanced Amenities Creation...\n');

  try {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/create/property'),
    );
    
    request.headers['Authorization'] = 'Bearer $authToken';
    
    // Add basic property fields
    request.fields.addAll({
      'title': 'ENHANCED AMENITIES TEST',
      'description': 'Testing complete amenity details submission',
      'purpose': 'Sell',
      'category': 'Residential',
      'property_type_id': '5', // Apartment
      'property_duration': '15 days',
      'is_rent': '0',
      'location': '33.544674, 73.093578',
      'latitude': '33.54467423780209',
      'longitude': '73.0935780484061',
      'building': 'Test Tower',
      'floor': '2nd Floor',
      'apartment_number': 'B-22',
      'area': '5',
      'area_unit': 'Marla',
      'phase': 'Phase 1',
      'sector': 'Sector A',
      'street_number': 'Street 1',
      'unit_no': 'B-22',
      'payment_method': 'KuickPay',
      'on_behalf': '0',
      'price': '5000000',
    });
    
    // Add amenity IDs only (backend expects only IDs)
    print('Adding amenity IDs...');
    
    request.fields['amenities[0]'] = '2';   // Water Supply
    request.fields['amenities[1]'] = '15';  // Elevator Access  
    request.fields['amenities[2]'] = '29';  // Parking (Allocated)
    request.fields['amenities[3]'] = '38';  // Security Features
    
    print('Request fields for amenities:');
    request.fields.forEach((key, value) {
      if (key.startsWith('amenities')) {
        print('  $key = $value');
      }
    });
    
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    
    print('\nCreate Property Status: ${response.statusCode}');
    print('Create Property Response: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      
      if (data['data'] != null) {
        final propertyId = data['data']['id']?.toString();
        print('✅ Property created successfully! ID: $propertyId');
        
        if (propertyId != null) {
          // Test fetching the property to see if amenities are now included
          print('\nFetching created property details...');
          
          await Future.delayed(Duration(seconds: 2));
          
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
                  print('  🎉 SUCCESS! Amenities found in response:');
                  for (int i = 0; i < amenitiesList.length; i++) {
                    final amenity = amenitiesList[i];
                    print('    Amenity $i: $amenity');
                    if (amenity is Map) {
                      print('      Name: ${amenity['amenity_name']}');
                      print('      Type: ${amenity['amenity_type']}');
                      print('      Description: ${amenity['description']}');
                    }
                  }
                } else {
                  print('  ❌ Still no amenities in response');
                }
              }
            }
          }
        }
      }
    } else {
      print('❌ Property creation failed with status ${response.statusCode}');
      print('Response: ${response.body}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}