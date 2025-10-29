import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  // Test the API calls directly
  await testPropertyTypesAPI();
  await testPropertySubtypesAPI();
}

Future<void> testPropertyTypesAPI() async {
  print('=== Testing Property Types API ===');
  
  try {
    final uri = Uri.parse('https://testingbackend.dhamarketplace.com/api/property/types?purpose=Sell&category=Residential');
    
    print('Making GET request to: $uri');
    
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Success: ${data['success']}');
      print('Data: ${data['data']}');
    }
  } catch (e) {
    print('Error: $e');
  }
}

Future<void> testPropertySubtypesAPI() async {
  print('\n=== Testing Property Subtypes API ===');
  
  try {
    final uri = Uri.parse('https://testingbackend.dhamarketplace.com/api/property/sub-types');
    
    print('Making POST request to: $uri');
    print('Body: parent_id[] = 6');
    
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      },
      body: {
        'parent_id[]': '6',
      },
    );
    
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Success: ${data['success']}');
      print('Data: ${data['data']}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
