import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService extends ChangeNotifier {
  String _currentLocation = 'Islamabad, Pakistan';
  bool _isLoadingLocation = false;
  bool _hasLocationPermission = false;
  static const String _locationKey = 'saved_location';
  static const String _permissionKey = 'location_permission_granted';

  String get currentLocation => _currentLocation;
  bool get isLoadingLocation => _isLoadingLocation;

  // Initialize location service
  Future<void> initializeLocation() async {
    await _loadSavedLocation();
    await _checkLocationPermission();
  }

  // Check location permission status
  Future<void> _checkLocationPermission() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasLocationPermission = prefs.getBool(_permissionKey) ?? false;
      
      // If we have permission, try to get current location
      if (_hasLocationPermission) {
        await getCurrentLocation();
      }
    } catch (e) {
      print('Error checking location permission: $e');
    }
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
    _hasLocationPermission = status.isGranted;
    
    // Save permission status
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_permissionKey, _hasLocationPermission);
    } catch (e) {
      print('Error saving permission status: $e');
    }
    
    if (status.isGranted) {
      await getCurrentLocation();
    } else {
      // Keep default location (Islamabad) when permission denied
      _currentLocation = 'Islamabad, Pakistan';
      notifyListeners();
    }
  }

  Future<void> getCurrentLocation() async {
    // Only get location if we have permission and haven't updated recently
    if (!_hasLocationPermission) {
      _currentLocation = 'Islamabad, Pakistan';
      notifyListeners();
      return;
    }

    _isLoadingLocation = true;
    notifyListeners();

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10), // Add timeout
      );
      
      // Get city name from coordinates (simplified)
      String cityName = await _getCityName(position.latitude, position.longitude);
      
      // Only update if location has changed significantly
      if (cityName != _currentLocation) {
        _currentLocation = cityName;
        await _saveLocation(cityName);
      }
    } catch (e) {
      // Keep current location if failed, don't change to default
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

  // Force location update (only when user explicitly requests)
  Future<void> forceLocationUpdate() async {
    if (_hasLocationPermission) {
      await getCurrentLocation();
    }
  }

  // Reset to default location
  Future<void> resetToDefaultLocation() async {
    _currentLocation = 'Islamabad, Pakistan';
    await _saveLocation(_currentLocation);
    notifyListeners();
  }
}
