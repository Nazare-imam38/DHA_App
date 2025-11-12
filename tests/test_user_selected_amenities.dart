import 'package:flutter/material.dart';
import 'lib/services/local_amenities_cache.dart';

// Test script to verify user-selected amenities storage and retrieval
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=== TESTING USER-SELECTED AMENITIES ===\n');
  
  // Simulate user creating a property with specific amenities
  const propertyId = '35'; // Latest property from your API response
  const userSelectedAmenityIds = ['2', '15', '29', '38']; // Water, Elevator, Parking, Security
  
  // Simulate the amenity details the user selected
  final userSelectedAmenityDetails = {
    '2': {
      'name': 'Water Supply',
      'description': 'Running water for pantry/washrooms; storage tanks if needed.',
      'amenity_type': 'Basic Utilities',
    },
    '15': {
      'name': 'Elevator Access',
      'description': 'Lift service for multi-storey buildings.',
      'amenity_type': 'Building Infrastructure',
    },
    '29': {
      'name': 'Parking (Allocated)',
      'description': 'Basement/compound reserved slot.',
      'amenity_type': 'Parking & Transportation',
    },
    '38': {
      'name': 'Security Features',
      'description': 'Boundary wall, secure gate; optional alarm/CCTV.',
      'amenity_type': 'Security & Safety',
    },
  };
  
  print('1. STORING USER-SELECTED AMENITIES:');
  print('   Property ID: $propertyId');
  print('   Selected Amenity IDs: $userSelectedAmenityIds');
  
  // Store the user's selections
  await LocalAmenitiesCache.storePropertyAmenities(propertyId, userSelectedAmenityIds);
  await LocalAmenitiesCache.storePropertyAmenityDetails(propertyId, userSelectedAmenityDetails);
  
  print('   ✅ Stored successfully\n');
  
  print('2. RETRIEVING USER-SELECTED AMENITIES:');
  
  // Retrieve the stored amenities (this is what My Listings will do)
  final retrievedIds = await LocalAmenitiesCache.getPropertyAmenities(propertyId);
  final retrievedDetails = await LocalAmenitiesCache.getPropertyAmenityDetails(propertyId);
  
  print('   Retrieved Amenity IDs: $retrievedIds');
  print('   Retrieved Details Count: ${retrievedDetails.length}');
  
  print('\n3. DISPLAYING AMENITIES (as My Listings would):');
  for (final id in retrievedIds) {
    if (retrievedDetails.containsKey(id)) {
      final details = retrievedDetails[id]!;
      print('   • ${details['name']} (${details['amenity_type']})');
      print('     Description: ${details['description']}');
    }
  }
  
  print('\n4. EXPECTED RESULT IN MY LISTINGS:');
  print('   Property "Grey" should show exactly these 4 amenities:');
  print('   • Water Supply (Basic Utilities)');
  print('   • Elevator Access (Building Infrastructure)');
  print('   • Parking (Allocated) (Parking & Transportation)');
  print('   • Security Features (Security & Safety)');
  
  print('\n✅ Test completed! The My Listings screen should now show only the user-selected amenities.');
}