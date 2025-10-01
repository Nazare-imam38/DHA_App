import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService extends ChangeNotifier {
  String _currentLocation = 'Lahore, Pakistan';
  bool _isLoadingLocation = false;
  static const String _locationKey = 'saved_location';

  String get currentLocation => _currentLocation;
  bool get isLoadingLocation => _isLoadingLocation;

  // Initialize location service
  Future<void> initializeLocation() async {
    await _loadSavedLocation();
  }

  // Load saved location from SharedPreferences
  Future<void> _loadSavedLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLocation = prefs.getString(_locationKey);
      if (savedLocation != null && savedLocation.isNotEmpty) {
        _currentLocation = savedLocation;
        notifyListeners();
      }
    } catch (e) {
      print('Error loading saved location: $e');
    }
  }

  // Save location to SharedPreferences
  Future<void> _saveLocation(String location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_locationKey, location);
    } catch (e) {
      print('Error saving location: $e');
    }
  }

  Future<void> requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      await getCurrentLocation();
    }
  }

  Future<void> getCurrentLocation() async {
    _isLoadingLocation = true;
    notifyListeners();

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Get city name from coordinates (simplified)
      String cityName = await _getCityName(position.latitude, position.longitude);
      
      _currentLocation = cityName;
      await _saveLocation(cityName);
    } catch (e) {
      // Keep current location if failed
      print('Failed to get location: $e');
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  Future<String> _getCityName(double lat, double lng) async {
    // Simplified city detection based on coordinates
    // In a real app, you'd use reverse geocoding
    if (lat >= 31.0 && lat <= 32.0 && lng >= 73.0 && lng <= 75.0) {
      return 'Lahore, Pakistan';
    } else if (lat >= 33.0 && lat <= 34.0 && lng >= 72.0 && lng <= 74.0) {
      return 'Islamabad, Pakistan';
    } else if (lat >= 24.0 && lat <= 25.0 && lng >= 67.0 && lng <= 68.0) {
      return 'Karachi, Pakistan';
    } else {
      return 'Unknown Location';
    }
  }

  Future<void> updateLocation(String location) async {
    _currentLocation = location;
    await _saveLocation(location);
    notifyListeners();
  }
}
