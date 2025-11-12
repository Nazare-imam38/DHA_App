import 'dart:convert';
import 'package:http/http.dart' as http;

// Test script to check customer properties API response format
void main() async {
  const String baseUrl = 'https://testingbackend.dhamarketplace.com/api';
  const String authToken = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIwMTlhMzkzOC0xOGE1LTcwMWYtYjE4MS1hOTJlYWQxNWVkMzUiLCJqdGkiOiJiYzMzZGUwZTI3MjhmOTZmYzYwNTNiNGYxMWZiZGM5YzIzMzgxZGQyYjBhNmI4NzE5MDlhZmY4YjkyOGRlMDVlZDNmNDYzZTJkY2Q2MmM2YiIsImlhdCI6MTc2MTkxMTEyMC40MjE4MiwibmJmIjoxNzYxOTExMTIwLjQyMTgyMywiZXhwIjoxNzkzNDQ3MTIwLjQxMjEwMiwic3ViIjoiMjUiLCJzY29wZXMiOltdfQ.Yf0ayK8j6YmIx8jTeZsXXki3LwRFi9JUsyis8_A9Q_NzehP7Uui6dhQ-KIGYuUAHyFCUzrQe1tu4OH7r5dNlqwKhUfkonCWF1QvTtjpcNlXncXjCSCFCin0WBKO2BwiQQyaokqbcK-bCVvhiHCJDD6_OWD-2sdbdjwG51tUYRIOLtshE8G4PpXwtGv72EO1GdNhYqfvS3k8aiNkQIfOAOuWXBq3nhnmkeAHaKcRUzTop7iGxX942gAwQgXxSjpXhgOrnwCj-L5WZTXdsmajJuG91lHWpfpuxIqdrLmjZlrYlFiKI9rNOR_J8MbVpz8KaVtWnmaxUIyrExiN1F8AnTuJY_Gc48Y_T_Wxr02uduQRRQl8FUUJUD55amc0eJWPOkfIjgJCrC65MaYHJZsR0H_2Qw16qeKUniQ_mUV9CVARPch6iP8SxdLCZ6F2foCyIHhdbwFQjwxrwBPghDlx1s7AhY6oMVuBkYCk84gMdPYCGb8KEEjau60zUAP_ltTyMGSwAXCfvAos6nIVd5PocZGPp670OKDENl9STxbnR9iWMTLJy5EY45OJJFiuzZypRZRFqrUS7AWRTjwto2WIjgTjbmfjFNRTBHFU6XQ10d9wFlp9fgxBCrbKRVcPASlr4XI-gUfEA6Da5o9gd-RngWn1BR9tVOUVUKUF62rJoC80';

  print('Testing Customer Properties API...\n');

  try {
    final response = await http.get(
      Uri.parse('$baseUrl/customer-properties'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );
    
    print('Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Success: ${data['success']}');
      
      if (data['data'] is List && (data['data'] as List).isNotEmpty) {
        final properties = data['data'] as List;
        print('Found ${properties.length} properties\n');
        
        // Check all properties for amenities
        for (int i = 0; i < properties.length; i++) {
          final property = properties[i] as Map<String, dynamic>;
          print('Property ${i + 1}:');
          print('  ID: ${property['id']}');
          print('  Title: ${property['title']}');
          print('  Amenities: ${property['amenities']}');
          print('  Amenities Count: ${property['amenities'] is List ? (property['amenities'] as List).length : 0}');
          
          // Check if there's amenities_by_category
          if (property.containsKey('amenities_by_category')) {
            print('  Amenities By Category: ${property['amenities_by_category']}');
          }
          
          // Check for any property with non-empty amenities
          if (property['amenities'] is List && (property['amenities'] as List).isNotEmpty) {
            final amenitiesList = property['amenities'] as List;
            print('  ✅ FOUND AMENITIES! First Amenity: ${amenitiesList[0]}');
            print('  First Amenity Type: ${amenitiesList[0].runtimeType}');
            
            if (amenitiesList[0] is Map) {
              final amenityMap = amenitiesList[0] as Map;
              print('  Amenity Keys: ${amenityMap.keys.toList()}');
              print('  Amenity Values: ${amenityMap.values.toList()}');
            }
            break; // Found one with amenities, that's enough for testing
          }
          print(''); // Empty line between properties
        }
        
      } else {
        print('No properties found or unexpected data structure');
        print('Data: $data');
      }
    } else {
      print('Error: ${response.body}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}