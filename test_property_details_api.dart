import 'dart:convert';
import 'package:http/http.dart' as http;

// Test script to check individual property details API response format
void main() async {
  const String baseUrl = 'https://testingbackend.dhamarketplace.com/api';
  const String authToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIwMTlhMzkzOC0xOGE1LTcwMWYtYjE4MS1hOTJlYWQxNWVkMzUiLCJqdGkiOiJiYzMzZGUwZTI3MjhmOTZmYzYwNTNiNGYxMWZiZGM5YzIzMzgxZGQyYjBhNmI4NzE5MDlhZmY4YjkyOGRlMDVlZDNmNDYzZTJkY2Q2MmM2YiIsImlhdCI6MTc2MTkxMTEyMC40MjE4MiwibmJmIjoxNzYxOTExMTIwLjQyMTgyMywiZXhwIjoxNzkzNDQ3MTIwLjQxMjEwMiwic3ViIjoiMjUiLCJzY29wZXMiOltdfQ.Yf0ayK8j6YmIx8jTeZsXXki3LwRFi9JUsyis8_A9Q_NzehP7Uui6dhQ-KIGYuUAHyFCUzrQe1tu4OH7r5dNlqwKhUfkonCWF1QvTtjpcNlXncXjCSCFCin0WBKO2BwiQQyaokqbcK-bCVvhiHCJDD6_OWD-2sdbdjwG51tUYRIOLtshE8G4PpXwtGv72EO1GdNhYqfvS3k8aiNkQIfOAOuWXBq3nhnmkeAHaKcRUzTop7iGxX942gAwQgXxSjpXhgOrnwCj-L5WZTXdsmajJuG91lHWpfpuxIqdrLmjZlrYlFiKI9rNOR_J8MbVpz8KaVtWnmaxUIyrExiN1F8AnTuJY_Gc48Y_T_Wxr02uduQRRQl8FUUJUD55amc0eJWPOkfIjgJCrC65MaYHJZsR0H_2Qw16qeKUniQ_mUV9CVARPch6iP8SxdLCZ6F2foCyIHhdbwFQjwxrwBPghDlx1s7AhY6oMVuBkYCk84gMdPYCGb8KEEjau60zUAP_ltTyMGSwAXCfvAos6nIVd5PocZGPp670OKDENl9STxbnR9iWMTLJy5EY45OJJFiuzZypRZRFqrUS7AWRTjwto2WIjgTjbmfjFNRTBHFU6XQ10d9wFlp9fgxBCrbKRVcPASlr4XI-gUfEA6Da5o9gd-RngWn1BR9tVOUVUKUF62rJoC80';

  print('Testing Property Details API...\n');

  // Test with a few property IDs including the newly created one
  final propertyIds = ['32', '30', '29', '28'];

  for (final propertyId in propertyIds) {
    print('=== Testing Property ID: $propertyId ===');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/property/$propertyId'),
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
          final property = data['data'];
          print('Property Details:');
          print('  ID: ${property['id']}');
          print('  Title: ${property['title']}');
          print('  Amenities: ${property['amenities']}');
          print('  Amenities Type: ${property['amenities'].runtimeType}');
          
          if (property['amenities'] is List) {
            final amenitiesList = property['amenities'] as List;
            print('  Amenities Count: ${amenitiesList.length}');
            
            if (amenitiesList.isNotEmpty) {
              print('  ✅ FOUND AMENITIES!');
              for (int i = 0; i < amenitiesList.length; i++) {
                final amenity = amenitiesList[i];
                print('    Amenity $i: $amenity (${amenity.runtimeType})');
                
                if (amenity is Map) {
                  print('      Keys: ${amenity.keys.toList()}');
                  if (amenity.containsKey('amenity_name')) {
                    print('      Name: ${amenity['amenity_name']}');
                  }
                  if (amenity.containsKey('id')) {
                    print('      ID: ${amenity['id']}');
                  }
                }
              }
              break; // Found amenities, no need to test more properties
            }
          }
          
          // Check if there's amenities_by_category
          if (property.containsKey('amenities_by_category')) {
            print('  Amenities By Category: ${property['amenities_by_category']}');
          }
        }
      } else {
        print('Error: ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
    
    print(''); // Empty line between properties
  }
}