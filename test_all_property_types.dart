import 'dart:convert';
import 'package:http/http.dart' as http;

// Test script to check all property types for different purposes
void main() async {
  await testAllPropertyTypes();
}

Future<void> testAllPropertyTypes() async {
  print('🧪 Testing All Property Types for Different Purposes');
  print('=' * 60);
  
  final testCases = [
    {'category': 'Residential', 'purpose': 'Sell'},
    {'category': 'Residential', 'purpose': 'Rent'},
    {'category': 'Commercial', 'purpose': 'Sell'},
    {'category': 'Commercial', 'purpose': 'Rent'},
  ];
  
  for (final testCase in testCases) {
    await testPropertyTypesForCase(testCase['category']!, testCase['purpose']!);
    print('');
  }
}

Future<void> testPropertyTypesForCase(String category, String purpose) async {
  try {
    print('🔍 Testing: $category - $purpose');
    
    final uri = Uri.parse('https://testingbackend.dhamarketplace.com/api/property/types').replace(
      queryParameters: {
        'category': category,
        'purpose': purpose,
      },
    );
    
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['success'] == true && data['data'] != null) {
        final List<dynamic> propertyTypes = data['data'];
        
        print('✅ Found ${propertyTypes.length} property types:');
        for (final type in propertyTypes) {
          print('   - ID: ${type['id']}, Name: ${type['name']}');
        }
      }
    } else {
      print('❌ API Error: ${response.statusCode}');
    }
  } catch (e) {
    print('❌ Exception: $e');
  }
}