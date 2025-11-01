import 'package:flutter/material.dart';
import 'lib/services/local_amenities_cache.dart';

// Simple test for local amenities cache
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('Testing Local Amenities Cache...\n');
  
  // Test storing amenities for a property
  const propertyId = '32';
  const amenityIds = ['2', '16', '30', '34'];
  
  print('1. Storing amenities for property $propertyId: $amenityIds');
  await LocalAmenitiesCache.storePropertyAmenities(propertyId, amenityIds);
  
  // Test retrieving amenities
  print('2. Retrieving amenities for property $propertyId');
  final retrievedAmenities = await LocalAmenitiesCache.getPropertyAmenities(propertyId);
  print('   Retrieved: $retrievedAmenities');
  
  // Test storing amenity names
  const amenityNames = {
    '2': 'Water Supply',
    '16': 'Elevator Access', 
    '30': 'Parking (Allocated)',
    '34': 'Fire Extinguisher',
  };
  
  print('3. Storing amenity names: $amenityNames');
  await LocalAmenitiesCache.storeAmenityNames(amenityNames);
  
  // Test retrieving amenity names
  print('4. Retrieving amenity names');
  final retrievedNames = await LocalAmenitiesCache.getAmenityNames();
  print('   Retrieved: $retrievedNames');
  
  // Test resolving amenity IDs to names
  print('5. Resolving amenity IDs to names:');
  for (final id in retrievedAmenities) {
    final name = retrievedNames[id] ?? 'Unknown';
    print('   ID $id -> $name');
  }
  
  print('\n✅ Local amenities cache test completed!');
}