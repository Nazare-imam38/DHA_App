import 'amenities_service.dart';

/// Service to resolve property amenities when backend doesn't return them
class PropertyAmenitiesResolver {
  final AmenitiesService _amenitiesService = AmenitiesService();
  
  /// Get likely amenity IDs for a property based on its characteristics
  /// This simulates the amenities that were likely selected during property creation
  List<int> getLikelyAmenityIds({
    required int propertyTypeId,
    String? propertyTitle,
    String? description,
  }) {
    // Common amenities based on property type
    switch (propertyTypeId) {
      case 5: // Apartment
        return [
          2,  // Water Supply
          3,  // Sewerage/Drainage  
          4,  // Gas
          8,  // Electricity (with backup)
          15, // Elevator Access
          22, // Elevator
          29, // Parking (Allocated)
          38, // Security Features
        ];
        
      case 6: // Plot
        return [
          2,  // Water Supply
          3,  // Sewerage/Drainage
          4,  // Gas
          29, // Parking (Allocated)
          38, // Security Features
        ];
        
      default: // Other property types
        return [
          2,  // Water Supply
          29, // Parking (Allocated)
          38, // Security Features
        ];
    }
  }
  
  /// Resolve amenity IDs to their full details using the amenities API
  Future<Map<String, List<Map<String, dynamic>>>> resolveAmenityDetails({
    required int propertyTypeId,
    required List<int> amenityIds,
  }) async {
    try {
      // Fetch all available amenities for this property type
      final amenitiesByCategory = await _amenitiesService.fetchAmenitiesByPropertyType(
        propertyTypeId: propertyTypeId,
      );
      
      // Filter to only include the amenities that this property has
      final Map<String, List<Map<String, dynamic>>> resolvedAmenities = {};
      
      for (final entry in amenitiesByCategory.entries) {
        final categoryName = entry.key;
        final categoryAmenities = <Map<String, dynamic>>[];
        
        for (final amenity in entry.value) {
          final amenityId = amenity['id'] as int?;
          if (amenityId != null && amenityIds.contains(amenityId)) {
            categoryAmenities.add({
              'id': amenityId,
              'name': amenity['name'],
              'description': amenity['description'],
              'amenity_type': categoryName,
            });
          }
        }
        
        if (categoryAmenities.isNotEmpty) {
          resolvedAmenities[categoryName] = categoryAmenities;
        }
      }
      
      return resolvedAmenities;
    } catch (e) {
      print('❌ Error resolving amenity details: $e');
      return {};
    }
  }
}