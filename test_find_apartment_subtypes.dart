import 'dart:convert';
import 'package:http/http.dart' as http;

// Test script to find which ID has apartment subtypes
void main() async {
  await findApartmentSubtypes();
}

Future<void> findApartmentSubtypes() async {
  print('🔍 Testing multiple IDs to find apartment subtypes');
  print('=' * 60);
  
  // Test IDs from 1 to 15 to find which one has apartment subtypes
  for (int id = 1; id <= 15; id++) {
    await testSubcategoryForId(id);
    print(''); // Add spacing
  }
}

Future<void> testSubcategoryForId(int id) async {
  try {
    final uri = Uri.parse('https://testingbackend.dhamarketplace.com/api/property/sub-types');
    
    final Map<String, String> formData = {
      'parent_id[]': id.toString(),
    };
    
    print('🔍 Testing ID: $id');
    
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: formData,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> subtypes = data['data'];
        if (subtypes.isNotEmpty) {
          print('✅ ID $id has ${subtypes.length} subtypes:');
          for (final subtype in subtypes) {
            print('   - ${subtype['name']} (ID: ${subtype['id']})');
          }
        } else {
          print('❌ ID $id: No subtypes');
        }
      }
    } else {
      print('❌ ID $id: API Error ${response.statusCode}');
    }
  } catch (e) {
    print('❌ ID $id: Exception $e');
  }
}