import 'dart:convert';
import 'package:http/http.dart' as http;

// Test script to check property type IDs
void main() async {
  await testPropertyTypesAPI();
}

Future<void> testPropertyTypesAPI() async {
  print('🧪 Testing Property Types API to find correct IDs');
  print('=' * 60);
  
  try {
    // Test for Residential category
    final uri = Uri.parse('https://marketplace-testingbackend.dhamarketplace.com/api/property/types').replace(
      queryParameters: {
        'category': 'Residential',
        'purpose': 'Sell',
      },
    );
    
    print('📤 Request: GET $uri');
    
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    print('📥 Response Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('📥 Response Body: ${json.encode(data)}');
      
      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> propertyTypes = data['data'];
        
        print('\n✅ Found ${propertyTypes.length} property types:');
        for (final type in propertyTypes) {
          print('   - ID: ${type['id']}, Name: ${type['name']}');
          
          // Test subcategory for each property type
          if (type['name'] == 'Apartment') {
            print('\n🔍 Testing subcategories for Apartment (ID: ${type['id']})');
            await testSubcategoryForPropertyType(type['id']);
          }
        }
      }
    } else {
      print('❌ API Error: ${response.statusCode}');
      print('❌ Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}

Future<void> testSubcategoryForPropertyType(int propertyTypeId) async {
  try {
    final uri = Uri.parse('https://marketplace-testingbackend.dhamarketplace.com/api/property/sub-types');
    
    final Map<String, String> formData = {
      'parent_id[]': propertyTypeId.toString(),
    };
    
    print('📤 Subcategory Request: POST $uri');
    print('📤 Body: $formData');
    
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: formData,
    );
    
    print('📥 Subcategory Response Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('📥 Subcategory Response: ${json.encode(data)}');
      
      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> subtypes = data['data'];
        if (subtypes.isNotEmpty) {
          print('✅ Found ${subtypes.length} subtypes for Apartment:');
          for (final subtype in subtypes) {
            print('   - ID: ${subtype['id']}, Name: ${subtype['name']}');
          }
        } else {
          print('ℹ️ No subtypes found for Apartment ID: $propertyTypeId');
        }
      }
    } else {
      print('❌ Subcategory API Error: ${response.statusCode}');
      print('❌ Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Subcategory Exception: $e');
  }
}