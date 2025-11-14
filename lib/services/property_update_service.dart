import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'auth_service.dart';
import 'package:image/image.dart' as img;

class PropertyUpdateService {
  static const String baseUrl = 'https://marketplace-testingbackend.dhamarketplace.com/api';
  final AuthService _authService = AuthService();

  // Update property with all details
  Future<Map<String, dynamic>> updateProperty({
    required String propertyId,
    required Map<String, dynamic> propertyData,
    List<File>? images,
    List<File>? videos,
    int? propertyTypeId,
    List<String>? amenities, // List of amenity IDs
  }) async {
    try {
      print('🔄 PROPERTY UPDATE SERVICE: Starting update for property $propertyId');
      print('📊 Property data: $propertyData');
      
      // Get authentication token
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found. User must be logged in.');
      }

      // Prepare multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/update/property/$propertyId'),
      );

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Add property data as form fields
      propertyData.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          request.fields[key] = value.toString();
          print('   📝 Field: $key = $value');
        }
      });

      // Add amenities in nested format: amenities[property_type_id][amenity_id]
      // IMPORTANT: Backend expects amenity IDs (numeric), not names
      if (amenities != null && amenities.isNotEmpty && propertyTypeId != null) {
        print('🏠 Adding ${amenities.length} amenities in nested format');
        int index = 1;
        for (final amenityValue in amenities) {
          final amenityStr = amenityValue.toString().trim();
          if (amenityStr.isEmpty) continue;
          
          // Validate that we're sending an ID (numeric), not a name
          // If it's not numeric, log a warning but still send it (backend will handle validation)
          final isNumeric = RegExp(r'^\d+$').hasMatch(amenityStr);
          if (!isNumeric) {
            print('⚠️ WARNING: Amenity value "$amenityStr" is not numeric (expected ID). This may cause backend errors.');
          }
          
          print('   ✅ Adding amenities[$propertyTypeId][$index]: $amenityStr');
          request.fields['amenities[$propertyTypeId][$index]'] = amenityStr;
          index++;
        }
      }

      // Add images to the request (with compression to avoid 413 errors)
      if (images != null && images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          final imageFile = images[i];
          final fileName = path.basename(imageFile.path);
          final fileExtension = path.extension(fileName).toLowerCase();

          // Validate file type
          if (!['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(fileExtension)) {
            print('⚠️ Image $fileName has unsupported format. Skipping...');
            continue;
          }

          // Read and compress to ~0.9MB max
          final originalBytes = await imageFile.readAsBytes();
          img.Image? decoded;
          try {
            decoded = img.decodeImage(originalBytes);
          } catch (_) {}

          if (decoded == null) {
            print('⚠️ Could not decode image $fileName, sending as-is');
            request.files.add(
              await http.MultipartFile.fromPath('images[]', imageFile.path, filename: fileName),
            );
            continue;
          }

          // Resize if very large
          const maxSide = 1920;
          if (decoded.width > maxSide || decoded.height > maxSide) {
            decoded = img.copyResize(decoded, width: decoded.width > decoded.height ? maxSide : null, height: decoded.height >= decoded.width ? maxSide : null);
          }

          // Iteratively lower quality to keep under 900KB
          int quality = 85;
          List<int> encoded = img.encodeJpg(decoded, quality: quality);
          while (encoded.length > 900 * 1024 && quality > 50) {
            quality -= 5;
            encoded = img.encodeJpg(decoded, quality: quality);
          }

          print('📸 Adding compressed image $fileName (${(encoded.length/1024).round()}KB, q=$quality)');
          request.files.add(
            http.MultipartFile.fromBytes('images[]', encoded, filename: path.setExtension(fileName, '.jpg')),
          );
        }
      }

      // Add videos to the request
      if (videos != null && videos.isNotEmpty) {
        for (int i = 0; i < videos.length; i++) {
          final videoFile = videos[i];
          final fileName = path.basename(videoFile.path);
          final fileExtension = path.extension(fileName).toLowerCase();
          
          // Validate file size (50MB limit for videos)
          final fileSize = await videoFile.length();
          if (fileSize > 50 * 1024 * 1024) {
            print('⚠️ Video $fileName is too large (${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB). Skipping...');
            continue;
          }

          // Validate file type
          if (!['.mp4', '.mov', '.avi', '.mkv', '.webm'].contains(fileExtension)) {
            print('⚠️ Video $fileName has unsupported format. Skipping...');
            continue;
          }

          print('🎥 Adding video $fileName to request');
          request.files.add(
            await http.MultipartFile.fromPath(
              'videos[]',
              videoFile.path,
              filename: fileName,
            ),
          );
        }
      }

      print('🌐 Sending update request to: $baseUrl/update/property/$propertyId');
      print('📦 Request fields: ${request.fields}');
      print('📁 Files count: ${request.files.length}');

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📊 Update Response Status: ${response.statusCode}');
      print('📄 Update Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('✅ Property updated successfully!');
        return {
          'success': true,
          'data': responseData,
          'message': 'Property updated successfully',
        };
      } else {
        print('❌ Property update failed with status: ${response.statusCode}');
        print('📄 Full response body: ${response.body}');
        
        Map<String, dynamic> errorData;
        String errorMessage;
        
        try {
          errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? response.body;
          
          // Check for specific backend validation errors
          if (errorMessage.contains('validateSometimesIf') || 
              errorMessage.contains('sometimes_if')) {
            errorMessage = 'Backend validation error: The server is using an unsupported validation rule. '
                'Please contact support or try again later. '
                'This is a server-side issue that needs to be fixed by the backend team.';
          }
        } catch (e) {
          errorData = {};
          errorMessage = 'Failed to update property. Server returned status ${response.statusCode}';
        }
        
        return {
          'success': false,
          'error': 'Update failed with status: ${response.statusCode}',
          'message': errorMessage,
          'errors': errorData['errors'],
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('❌ Error updating property: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to update property',
      };
    }
  }
}

