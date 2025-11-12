import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final uri = Uri.parse('https://marketplace-testingbackend.dhamarketplace.com/api/property/sub-types');
  final response = await http.post(
    uri, 
    headers: {'Content-Type': 'application/x-www-form-urlencoded'}, 
    body: {'parent_id[]': '7'}
  );
  final data = json.decode(response.body);
  print('Apartment ID 7 (Rent) subtypes: ${json.encode(data)}');
}