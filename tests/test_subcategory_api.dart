import 'dart:convert';
import 'package:http/http.dart' as http;

// Test script to verify subcategory API functionality
void main() async {
  await testSubcategoryAPI();
}

Future<void> testSubcategoryAPI() async {
  print('🧪 Testing Subcategory API Implementation');
  print('=' * 50);
  
  // Test different parent_id values based on property types
  final testCases = [
    {'parent_id': 8, 'description': 'Apartment (Residential)'},
    {'parent_id': 2, 'description': 'Plot (Residential)'},
    {'parent_id': 1, 'description': 'House (Residential)'},
    {'parent_id': 5, 'description': 'Office (Commercial)'},
    {'parent_id': 7, 'description': 'Shop (Commercial)'},
  ];
  
  for (final testCase in testCases) {
    await testSingleSubcategory(
      testCase['parent_id'] as int, 
      testCase['description'] as String
    );
    print(''); // Add spacing between tests
  }
}

Future<void> testSingleSubcategory(int parentId, String description) async {
  try {
    print('🔍 Testing: $description (parent_id: $parentId)');
    
    final uri = Uri.parse('https://marketplace-testingbackend.dhamarketplace.com/api/property/sub-types');
    
    // Create form data exactly as shown in Postman
    final Map<String, String> formData = {
      'parent_id[]': parentId.toString(),
    };
    
    print('📤 Request: POST $uri');
    print('📤 Body: $formData');
    
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: formData,
    );
    
    print('📥 Response Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('📥 Response Body: ${json.encode(data)}');
      
      // Parse response based on different possible formats
      List<Map<String, dynamic>> subtypes = [];
      
      if (data is Map<String, dynamic>) {
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> subtypesList = data['data'];
          subtypes = subtypesList.map((item) => Map<String, dynamic>.from(item)).toList();
        } else if (data['data'] != null) {
          final List<dynamic> subtypesList = data['data'];
          subtypes = subtypesList.map((item) => Map<String, dynamic>.from(item)).toList();
        }
      } else if (data is List) {
        subtypes = data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      
      if (subtypes.isNotEmpty) {
        print('✅ Found ${subtypes.length} subtypes:');
        for (final subtype in subtypes) {
          print('   - ID: ${subtype['id']}, Name: ${subtype['name']}');
        }
      } else {
        print('ℹ️ No subtypes found for this property type');
      }
    } else {
      print('❌ API Error: ${response.statusCode}');
      print('❌ Response: ${response.body}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}