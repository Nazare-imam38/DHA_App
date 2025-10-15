import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class CustomGeocodingService {
  static final CustomGeocodingService _instance = CustomGeocodingService._internal();
  factory CustomGeocodingService() => _instance;
  CustomGeocodingService._internal();

  /// Geocode using OpenStreetMap Nominatim API as fallback
  Future<LatLng?> geocodeAddress(String address) async {
    try {
      if (address.trim().isEmpty) return null;
      
      print('Attempting custom geocoding for: $address');
      
      // Generate smart address variations
      List<String> addressVariations = _generateCustomAddressVariations(address);
      
      for (String addr in addressVariations) {
        try {
          print('Trying custom geocoding for: $addr');
          
          // Process the address variation normally
          
          // Use OpenStreetMap Nominatim API with better parameters for Pakistani addresses
          String encodedAddress = Uri.encodeComponent(addr);
          String url = 'https://nominatim.openstreetmap.org/search?q=$encodedAddress&format=json&limit=5&countrycodes=pk&addressdetails=1&bounded=1&viewbox=60.0,23.0,78.0,37.0';
          
          final response = await http.get(
            Uri.parse(url),
            headers: {
              'User-Agent': 'DHA_Marketplace_App/1.0',
            },
          ).timeout(const Duration(seconds: 8));
          
          if (response.statusCode == 200) {
            List<dynamic> results = json.decode(response.body);
            
            if (results.isNotEmpty) {
              // Find the best result based on importance and relevance
              Map<String, dynamic>? bestResult;
              double bestScore = 0.0;
              
              for (var result in results) {
                double lat = double.parse(result['lat'].toString());
                double lon = double.parse(result['lon'].toString());
                
                // Validate coordinates are in Pakistan area
                if (lat >= 23.0 && lat <= 37.0 && lon >= 60.0 && lon <= 78.0) {
                  // Calculate relevance score
                  double score = _calculateRelevanceScore(result, addr);
                  
                  if (score > bestScore) {
                    bestScore = score;
                    bestResult = result;
                  }
                }
              }
              
              if (bestResult != null) {
                double lat = double.parse(bestResult['lat'].toString());
                double lon = double.parse(bestResult['lon'].toString());
                print('Custom geocoding successful for: $addr');
                print('Coordinates: $lat, $lon');
                print('Relevance score: $bestScore');
                return LatLng(lat, lon);
              } else {
                print('No valid results found for: $addr');
              }
            } else {
              print('No results found for: $addr');
            }
          } else {
            print('HTTP error ${response.statusCode} for: $addr');
          }
        } catch (e) {
          print('Custom geocoding failed for $addr: $e');
          continue;
        }
      }
      
      // Fallback to Islamabad coordinates
      print('All custom geocoding attempts failed, using fallback location');
      return const LatLng(33.6844, 73.0479);
      
    } catch (e) {
      print('Custom geocoding error: $e');
      return const LatLng(33.6844, 73.0479);
    }
  }

  /// Generate smart address variations for proper geocoding of ANY address
  List<String> _generateCustomAddressVariations(String address) {
    List<String> variations = [];
    
    // Clean the address
    String cleanAddress = address.trim();
    variations.add(cleanAddress);
    
    // Add Pakistan context if not present
    if (!cleanAddress.toLowerCase().contains('pakistan')) {
      variations.add('$cleanAddress, Pakistan');
    }
    
    // Extract city from address for better context
    String cityContext = _extractCityFromAddress(cleanAddress);
    if (cityContext.isNotEmpty) {
      variations.add('$cleanAddress, $cityContext, Pakistan');
    }
    
    // Add city-specific variations
    if (cleanAddress.toLowerCase().contains('islamabad') || 
        cleanAddress.toLowerCase().contains('f-') ||
        cleanAddress.toLowerCase().contains('sector')) {
      variations.add('$cleanAddress, Islamabad, Pakistan');
    }
    
    if (cleanAddress.toLowerCase().contains('karachi') || 
        cleanAddress.toLowerCase().contains('dha') ||
        cleanAddress.toLowerCase().contains('phase')) {
      variations.add('$cleanAddress, Karachi, Pakistan');
    }
    
    if (cleanAddress.toLowerCase().contains('lahore') || 
        cleanAddress.toLowerCase().contains('gulberg') ||
        cleanAddress.toLowerCase().contains('model town')) {
      variations.add('$cleanAddress, Lahore, Pakistan');
    }
    
    if (cleanAddress.toLowerCase().contains('rawalpindi') || 
        cleanAddress.toLowerCase().contains('saddar')) {
      variations.add('$cleanAddress, Rawalpindi, Pakistan');
    }
    
    // Add simplified versions
    List<String> words = cleanAddress.split(' ');
    if (words.length > 3) {
      // Try with fewer words but keep important ones
      List<String> importantWords = words.where((word) => 
          word.length > 2 && // Keep words longer than 2 characters
          !word.toLowerCase().contains('shop') &&
          !word.toLowerCase().contains('floor') &&
          !word.toLowerCase().contains('first') &&
          !word.toLowerCase().contains('second') &&
          !word.toLowerCase().contains('third') &&
          !word.toLowerCase().contains('ground') &&
          !word.toLowerCase().contains('basement')
      ).toList();
      
      if (importantWords.isNotEmpty) {
        variations.add(importantWords.join(' '));
        variations.add('${importantWords.join(' ')}, Pakistan');
      }
    }
    
    // Remove common words that might confuse geocoding
    String simplified = cleanAddress
        .replaceAll(RegExp(r'\b(shop|floor|first|second|third|ground|basement)\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\b(opposite|near|beside|next to|close to|behind|in front of)\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (simplified != cleanAddress) {
      variations.add(simplified);
      variations.add('$simplified, Pakistan');
    }
    
    // Remove duplicates and return
    return variations.toSet().toList();
  }
  
  /// Calculate relevance score for geocoding results
  double _calculateRelevanceScore(Map<String, dynamic> result, String address) {
    double score = 0.0;
    String displayName = result['display_name']?.toString().toLowerCase() ?? '';
    String addressLower = address.toLowerCase();
    
    // Base score from importance
    double importance = double.tryParse(result['importance']?.toString() ?? '0') ?? 0.0;
    score += importance * 10;
    
    // Bonus for exact matches
    if (displayName.contains(addressLower)) {
      score += 50;
    }
    
    // Bonus for city matches
    if (addressLower.contains('islamabad') && displayName.contains('islamabad')) {
      score += 20;
    } else if (addressLower.contains('karachi') && displayName.contains('karachi')) {
      score += 20;
    } else if (addressLower.contains('lahore') && displayName.contains('lahore')) {
      score += 20;
    } else if (addressLower.contains('rawalpindi') && displayName.contains('rawalpindi')) {
      score += 20;
    }
    
    // Bonus for specific area matches
    if (addressLower.contains('f-8') && displayName.contains('f-8')) {
      score += 30;
    } else if (addressLower.contains('dha') && displayName.contains('dha')) {
      score += 30;
    } else if (addressLower.contains('gulberg') && displayName.contains('gulberg')) {
      score += 30;
    }
    
    // Bonus for landmark matches
    if (addressLower.contains('mall') && displayName.contains('mall')) {
      score += 25;
    } else if (addressLower.contains('market') && displayName.contains('market')) {
      score += 25;
    } else if (addressLower.contains('plaza') && displayName.contains('plaza')) {
      score += 25;
    }
    
    return score;
  }

  /// Extract city from address for better context
  String _extractCityFromAddress(String address) {
    String lowerAddress = address.toLowerCase();
    
    if (lowerAddress.contains('islamabad') || 
        lowerAddress.contains('f-8') || 
        lowerAddress.contains('centaurus') ||
        lowerAddress.contains('jinnah avenue')) {
      return 'Islamabad';
    } else if (lowerAddress.contains('karachi') || 
               lowerAddress.contains('dha')) {
      return 'Karachi';
    } else if (lowerAddress.contains('lahore') || 
               lowerAddress.contains('gulberg')) {
      return 'Lahore';
    } else if (lowerAddress.contains('rawalpindi')) {
      return 'Rawalpindi';
    }
    
    return '';
  }
}
