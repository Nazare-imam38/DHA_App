import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../screens/property_posting/models/property_form_data.dart';

class PropertyService {
  static const String baseUrl = 'https://marketplace-testingbackend.dhamarketplace.com/api';
  
  Future<Map<String, dynamic>> createProperty(PropertyFormData formData) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/create/property'),
      );
      
      // Add headers
      request.headers['Authorization'] = 'Bearer ${await _getAuthToken()}';
      request.headers['Content-Type'] = 'multipart/form-data';
      
      // Add required parameters
      request.fields['purpose'] = formData.purpose!;
      request.fields['property_type_id'] = formData.propertyTypeId.toString();
      request.fields['title'] = formData.title!;
      request.fields['description'] = formData.description!;
      request.fields['area'] = formData.area.toString();
      request.fields['area_unit'] = formData.areaUnit!;
      request.fields['category'] = formData.category!;
      request.fields['unit_no'] = formData.unitNo!;
      request.fields['price'] = formData.price.toString();
      request.fields['latitude'] = formData.latitude.toString();
      request.fields['longitude'] = formData.longitude.toString();
      request.fields['location'] = formData.location!;
      request.fields['sector'] = formData.sector!;
      request.fields['phase'] = formData.phase!;
      request.fields['payment_method'] = formData.paymentMethod!;
      request.fields['property_duration'] = formData.propertyDuration!;
      
      // Add optional parameters
      if (formData.rentPrice != null) {
        request.fields['rent_price'] = formData.rentPrice.toString();
      }
      
      if (formData.block != null) request.fields['block'] = formData.block!;
      if (formData.streetNo != null) request.fields['street_no'] = formData.streetNo!;
      if (formData.floor != null) request.fields['floor'] = formData.floor!;
      if (formData.building != null) request.fields['building'] = formData.building!;
      
      // Add ownership and owner details
      request.fields['on_behalf'] = formData.onBehalf.toString();
      
      // Add owner details (always required for property creation)
      // For own property: details fetched from user API
      // For on behalf: details entered manually
      if (formData.cnic != null) request.fields['cnic'] = formData.cnic!;
      if (formData.name != null) request.fields['name'] = formData.name!;
      if (formData.phone != null) request.fields['phone'] = formData.phone!;
      if (formData.address != null) request.fields['address'] = formData.address!;
      if (formData.email != null) request.fields['email'] = formData.email!;
      
      // Add images
      for (var image in formData.images) {
        request.files.add(await http.MultipartFile.fromPath('images[]', image.path));
      }
      
      // Add videos
      for (var video in formData.videos) {
        request.files.add(await http.MultipartFile.fromPath('videos[]', video.path));
      }
      
      // Add amenities
      for (int i = 0; i < formData.amenities.length; i++) {
        request.fields['amenities[$i]'] = formData.amenities[i];
      }
      
      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create property: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating property: $e');
    }
  }
  
  Future<String> _getAuthToken() async {
    // Implement your token retrieval logic
    // This could be from secure storage, shared preferences, etc.
    return 'YOUR_AUTH_TOKEN';
  }
  
  // Additional methods for property management
  Future<Map<String, dynamic>> getPropertyTypes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/property-types'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load property types');
      }
    } catch (e) {
      throw Exception('Error loading property types: $e');
    }
  }
  
  Future<Map<String, dynamic>> getAmenities() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/amenities'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load amenities');
      }
    } catch (e) {
      throw Exception('Error loading amenities: $e');
    }
  }
  
  Future<Map<String, dynamic>> getUserProperties() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/properties'),
        headers: {
          'Authorization': 'Bearer ${await _getAuthToken()}',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load user properties');
      }
    } catch (e) {
      throw Exception('Error loading user properties: $e');
    }
  }
}
