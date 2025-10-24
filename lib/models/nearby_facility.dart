import 'package:latlong2/latlong.dart';

class NearbyFacility {
  final String name;
  final String category;
  final LatLng coordinates;
  final String? address;
  final String? description;

  const NearbyFacility({
    required this.name,
    required this.category,
    required this.coordinates,
    this.address,
    this.description,
  });

  factory NearbyFacility.fromJson(Map<String, dynamic> json) {
    return NearbyFacility(
      name: json['name'] ?? 'Unknown Facility',
      category: json['category'] ?? 'other',
      coordinates: LatLng(
        json['lat'] ?? 0.0,
        json['lng'] ?? 0.0,
      ),
      address: json['address'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'lat': coordinates.latitude,
      'lng': coordinates.longitude,
      'address': address,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'NearbyFacility(name: $name, category: $category, coordinates: $coordinates)';
  }
}
