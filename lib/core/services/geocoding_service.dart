import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class GeocodingService {
  static final GeocodingService _instance = GeocodingService._internal();
  factory GeocodingService() => _instance;
  GeocodingService._internal();

  /// Geocode an address to get coordinates
  Future<LatLng?> geocodeAddress(String address) async {
    try {
      if (address.trim().isEmpty) return null;
      
      List<Location> locations = await locationFromAddress(address);
      
      if (locations.isNotEmpty) {
        Location location = locations.first;
        return LatLng(location.latitude, location.longitude);
      }
      
      return null;
    } catch (e) {
      print('Geocoding error: $e');
      return null;
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
