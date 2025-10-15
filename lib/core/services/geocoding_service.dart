import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'custom_geocoding_service.dart';

class GeocodingService {
  static final GeocodingService _instance = GeocodingService._internal();
  factory GeocodingService() => _instance;
  GeocodingService._internal();

  /// Geocode an address to get coordinates
  Future<LatLng?> geocodeAddress(String address) async {
    try {
      if (address.trim().isEmpty) return null;
      
      print('Attempting to geocode: $address');
      
      // Use custom geocoding service as primary method (more reliable)
      print('Using custom geocoding service as primary method');
      CustomGeocodingService customService = CustomGeocodingService();
      LatLng? customResult = await customService.geocodeAddress(address);
      
      if (customResult != null) {
        print('Custom geocoding successful');
        return customResult;
      }
      
      // Fallback to standard geocoding if custom fails
      print('Custom geocoding failed, trying standard service');
      List<String> addressVariations = _generateAddressVariations(address);
      
      for (String addr in addressVariations.take(3)) { // Limit to 3 attempts
        try {
          print('Trying standard geocoding for: $addr');
          
          List<Location> locations = await locationFromAddress(addr)
              .timeout(const Duration(seconds: 5));
          
          if (locations.isNotEmpty) {
            Location location = locations.first;
            print('Standard geocoding successful for: $addr');
            print('Coordinates: ${location.latitude}, ${location.longitude}');
            return LatLng(location.latitude, location.longitude);
          }
        } catch (e) {
          print('Standard geocoding failed for $addr: $e');
          if (e.toString().contains('Null check operator')) {
            print('Skipping standard geocoding due to null check error');
            break;
          }
          continue;
        }
      }
      
      // Final fallback to Islamabad
      print('All geocoding attempts failed, using fallback location');
      return const LatLng(33.6844, 73.0479); // Islamabad coordinates
      
    } catch (e) {
      print('Geocoding error: $e');
      // Return a fallback location in Islamabad
      return const LatLng(33.6844, 73.0479);
    }
  }

  /// Reverse geocode coordinates to get address
  Future<String?> reverseGeocode(LatLng coordinates) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        coordinates.latitude,
        coordinates.longitude,
      );
      
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        return '${placemark.street}, ${placemark.locality}, ${placemark.administrativeArea}';
      }
      
      return null;
    } catch (e) {
      print('Reverse geocoding error: $e');
      return null;
    }
  }

  /// Generate smart address variations for better geocoding success
  List<String> _generateAddressVariations(String address) {
    List<String> variations = [];
    
    // Clean the address
    String cleanAddress = address.trim();
    variations.add(cleanAddress);
    
    // Add Pakistan context if not present
    if (!cleanAddress.toLowerCase().contains('pakistan')) {
      variations.add('$cleanAddress, Pakistan');
    }
    
    // Add city context based on common Pakistani cities
    List<String> pakistaniCities = [
      'Islamabad', 'Karachi', 'Lahore', 'Rawalpindi', 'Faisalabad', 
      'Multan', 'Peshawar', 'Quetta', 'Sialkot', 'Gujranwala'
    ];
    
    // Check if address contains any Pakistani city
    bool hasCity = pakistaniCities.any((city) => 
        cleanAddress.toLowerCase().contains(city.toLowerCase()));
    
    if (!hasCity) {
      // Add Islamabad as default city context
      variations.add('$cleanAddress, Islamabad, Pakistan');
    }
    
    // Try with different city contexts if no specific city found
    for (String city in pakistaniCities.take(3)) { // Try top 3 cities
      if (!cleanAddress.toLowerCase().contains(city.toLowerCase())) {
        variations.add('$cleanAddress, $city, Pakistan');
      }
    }
    
    // Add simplified versions
    List<String> words = cleanAddress.split(' ');
    if (words.length > 3) {
      // Try with fewer words
      variations.add(words.take(3).join(' '));
      variations.add(words.take(2).join(' '));
    }
    
    // Add common Pakistani area indicators
    if (cleanAddress.toLowerCase().contains('sector')) {
      variations.add(cleanAddress.replaceAll(RegExp(r'[Ss]ector\s*', caseSensitive: false), ''));
    }
    
    // Remove common words that might confuse geocoding
    String simplified = cleanAddress
        .replaceAll(RegExp(r'\b(opposite|near|beside|next to|close to)\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (simplified != cleanAddress) {
      variations.add(simplified);
    }
    
    // Remove duplicates and return
    return variations.toSet().toList();
  }

  /// Get formatted address from placemark
  String getFormattedAddress(Placemark placemark) {
    List<String> addressParts = [];
    
    if (placemark.street?.isNotEmpty == true) {
      addressParts.add(placemark.street!);
    }
    if (placemark.locality?.isNotEmpty == true) {
      addressParts.add(placemark.locality!);
    }
    if (placemark.administrativeArea?.isNotEmpty == true) {
      addressParts.add(placemark.administrativeArea!);
    }
    if (placemark.country?.isNotEmpty == true) {
      addressParts.add(placemark.country!);
    }
    
    return addressParts.join(', ');
  }
}
