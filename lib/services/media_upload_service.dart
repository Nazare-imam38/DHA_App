import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'auth_service.dart';
import 'package:image/image.dart' as img;

class MediaUploadService {
  static const String baseUrl = 'https://testingbackend.dhamarketplace.com/api';
  final AuthService _authService = AuthService();

  // Upload images and videos to S3 via your API
  Future<Map<String, dynamic>> uploadPropertyMedia({
    required List<File> images,
    required List<File> videos,
    required Map<String, dynamic> propertyData,
  }) async {
    try {
      print('🚀 MEDIA UPLOAD SERVICE: Starting upload process');
      print('📊 Images to upload: ${images.length}');
      print('📊 Videos to upload: ${videos.length}');
      print('📋 Property data being sent:');
      propertyData.forEach((key, value) {
        print('   $key: $value (${value.runtimeType})');
      });
      
      // Get authentication token
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No authentication token found. User must be logged in.');
      }

      // Prepare multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/create/property'),
      );

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Add property data as form fields
      propertyData.forEach((key, value) {
        if (value != null) {
          if (key == 'amenities' && value is List) {
            // Handle amenities array - extract IDs only (backend expects only IDs)
            print('🏠 Adding ${value.length} amenities to request');
            print('🏠 Amenities list: $value');
            if (value.isEmpty) {
              print('⚠️ WARNING: Amenities list is EMPTY!');
            } else {
              for (int i = 0; i < value.length; i++) {
                final amenity = value[i];
                String amenityId = '';
                
                if (amenity is Map<String, dynamic>) {
                  // Extract ID from complete amenity object
                  amenityId = amenity['id'].toString();
                  print('   ✅ Extracting ID from amenity object $i: ${amenity['amenity_name']} (ID: $amenityId)');
                } else {
                  // Simple ID
                  amenityId = amenity.toString().trim();
                  print('   ✅ Using amenity ID $i: $amenityId');
                }
                
                if (amenityId.isNotEmpty) {
                  // Backend expects only the ID in indexed array format
                  request.fields['amenities[$i]'] = amenityId;
                } else {
                  print('   ⚠️ Skipping empty amenity at index $i');
                }
              }
              print('🏠 Total amenity IDs sent: ${value.length}');
            }
          } else {
            request.fields[key] = value.toString();
          }
        }
      });
      
      // Debug: Print all amenities fields being sent
      print('🔍 Final request fields for amenities:');
      int amenitiesCount = 0;
      request.fields.forEach((k, v) {
        if (k.startsWith('amenities')) {
          print('   $k = $v');
          amenitiesCount++;
        }
      });
      print('🔍 Total amenities fields in request: $amenitiesCount');
      
      // Also print all fields for debugging
      print('📋 All request fields:');
      request.fields.forEach((k, v) {
        print('   $k = $v');
      });

      // Add images to the request (with compression to avoid 413 errors)
      for (int i = 0; i < images.length; i++) {
        final imageFile = images[i];
        final fileName = path.basename(imageFile.path);
        final fileExtension = path.extension(fileName).toLowerCase();

        // Validate file type
        if (!['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(fileExtension)) {
          print('⚠️ Image $fileName has unsupported format. Skipping...');
          continue;
        }

        // Read and compress to ~0.9MB max to satisfy nginx small body limits
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
        const maxSide = 1920; // keep quality but reduce extremes
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

      // Add videos to the request
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
            'videos[]', // API expects videos[] array
            videoFile.path,
            filename: fileName,
          ),
        );
      }

      print('🌐 Sending multipart request to: $baseUrl/create/property');
      print('📦 Request fields: ${request.fields}');
      print('📁 Files count: ${request.files.length}');

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Headers: ${response.headers}');
      print('📄 Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        print('✅ Media upload successful!');
        return {
          'success': true,
          'data': responseData,
          'message': 'Media uploaded successfully to S3',
        };
      } else {
        print('❌ Media upload failed with status: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Upload failed with status: ${response.statusCode}',
          'message': response.body,
        };
      }
    } catch (e) {
      print('❌ Error uploading media: $e');
      return {
        'success': false,
        'error': e.toString(),
        'message': 'Failed to upload media files',
      };
    }
  }

  // Test the API with the provided token
  Future<Map<String, dynamic>> testApiConnection() async {
    try {
      print('🧪 Testing API connection...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/create/property'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIwMTlhMmExZC0xMjEyLTczZGYtODE5OS1iMmM5MGM1NmE4NDIiLCJqdGkiOiI4YTA5Y2U4ODQxNWM4NGI3YjEyOTUwMTY2Y2UzOTU2NzFhMzc0ZWY3NTQ5ZmUzYWFmNjZkZTA2MzIzYWI4YzNiM2VlMmU5ZGE4NTBhYTdmOSIsImlhdCI6MTc2MTc2MzgxMi45ODY3NzgsIm5iZiI6MTc2MTc2MzgxMi45ODY3ODIsImV4cCI6MTc5MzI5OTgxMi45NzY2NjEsInN1YiI6IjE5Iiwic2NvcGVzIjpbXX0.D6quu21hk5sEe17frN6um0a30i7VLZMQmE6BERb_dxkRw5aCNSx33ek5uY7pF0eMnUE2owk__-LwCR7O1A1ezVIq68LF81t_04iKj5ZES4LPT1t8SRqhk1bqfZYpT1_WqpPcavoALGOw1UZyxLn3U8iRgcI7cNZgJmtH0vOjX8k4airq__BcI9UvLjVXW4p44LzYuBjNL0GfLpR0s81TkncYltpDK7TWYCqM7q5bb9fxDjk1zu9UHPBXoYYN74k0WeqCHUKCr9fQhABIcvZzmOW7R8BQvBf-XDVm_tYu8YOxUz_HaFSN6f_JuhduqpRUaIRXZAS1G37ZOa5g-Uwz41azYkjgMw3vdEfiu5JwrSpfAiVBXo7DDyzfTflfltF77y6-JOT2vfb44bKY7UF655NTx7-YltrIgZVkKU9LIg3dtCi1TCT8s3e0N6AmRs444DS6z_lPEl4OJw7lVDFMTQy5IGEAuVF44A5Ce87Pr68UIJNvwqkWL2yGMVLyoocC7XGYBEBfH9QIPu2gprlRJ8Yb4A4qXpcW2oRApCRQzM71DvEx4uF-IFCZZCSVAu7p3v3c8hehq8hG__Mc1vPAuGghAVsIeqoViOogB1BmkplYLsWQB6rb73ECpHADf8ti5ThV3n1KPgkvCNjGJVbYjPaHwtC2XMnXoSuPUysFlno',
        },
      );

      print('📊 Test Response Status: ${response.statusCode}');
      print('📄 Test Response Body: ${response.body}');

      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'body': response.body,
      };
    } catch (e) {
      print('❌ Error testing API: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}
