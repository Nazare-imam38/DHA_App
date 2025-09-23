import 'package:latlong2/latlong.dart';

class MonumentData {
  final String id;
  final String name;
  final String description;
  final LatLng position;
  final String category;
  final String icon;
  final String status;

  MonumentData({
    required this.id,
    required this.name,
    required this.description,
    required this.position,
    required this.category,
    required this.icon,
    required this.status,
  });
}

class MonumentsRepository {
  static List<MonumentData> getIslamabadMonuments() {
    return [
      MonumentData(
        id: '1',
        name: 'Faisal Mosque',
        description: 'National Mosque of Pakistan, one of the largest mosques in the world',
        position: const LatLng(33.7294, 73.0386),
        category: 'Religious',
        icon: 'mosque',
        status: 'Available',
      ),
      MonumentData(
        id: '2',
        name: 'Pakistan Monument',
        description: 'National monument representing the four provinces of Pakistan',
        position: const LatLng(33.6889, 73.0644),
        category: 'Historical',
        icon: 'monument',
        status: 'Available',
      ),
      MonumentData(
        id: '3',
        name: 'Daman-e-Koh',
        description: 'Scenic viewpoint offering panoramic views of Islamabad',
        position: const LatLng(33.7167, 73.0500),
        category: 'Recreation',
        icon: 'viewpoint',
        status: 'Available',
      ),
      MonumentData(
        id: '4',
        name: 'Rawal Lake',
        description: 'Artificial reservoir providing water to Islamabad and Rawalpindi',
        position: const LatLng(33.6667, 73.0833),
        category: 'Recreation',
        icon: 'lake',
        status: 'Available',
      ),
      MonumentData(
        id: '5',
        name: 'Lok Virsa Museum',
        description: 'National Institute of Folk and Traditional Heritage',
        position: const LatLng(33.7000, 73.0833),
        category: 'Cultural',
        icon: 'museum',
        status: 'Available',
      ),
      MonumentData(
        id: '6',
        name: 'Centaurus Mall',
        description: 'Premier shopping and entertainment complex',
        position: const LatLng(33.6844, 73.0479),
        category: 'Commercial',
        icon: 'shopping',
        status: 'Available',
      ),
      MonumentData(
        id: '7',
        name: 'Islamabad Zoo',
        description: 'Family-friendly zoo with various animal species',
        position: const LatLng(33.6667, 73.1000),
        category: 'Recreation',
        icon: 'zoo',
        status: 'Available',
      ),
      MonumentData(
        id: '8',
        name: 'Margalla Hills National Park',
        description: 'Protected area with hiking trails and wildlife',
        position: const LatLng(33.7500, 73.0167),
        category: 'Nature',
        icon: 'park',
        status: 'Available',
      ),
    ];
  }

  static List<MonumentData> getRawalpindiMonuments() {
    return [
      MonumentData(
        id: '9',
        name: 'Rawalpindi Railway Station',
        description: 'Historic railway station connecting major cities',
        position: const LatLng(33.6000, 73.0667),
        category: 'Transport',
        icon: 'station',
        status: 'Available',
      ),
      MonumentData(
        id: '10',
        name: 'Ayub National Park',
        description: 'Large public park with recreational facilities',
        position: const LatLng(33.5833, 73.0500),
        category: 'Recreation',
        icon: 'park',
        status: 'Available',
      ),
      MonumentData(
        id: '11',
        name: 'Raja Bazaar',
        description: 'Historic market area with traditional shops',
        position: const LatLng(33.5833, 73.0333),
        category: 'Commercial',
        icon: 'market',
        status: 'Available',
      ),
      MonumentData(
        id: '12',
        name: 'Rawalpindi Cricket Stadium',
        description: 'International cricket venue',
        position: const LatLng(33.6167, 73.0833),
        category: 'Sports',
        icon: 'stadium',
        status: 'Available',
      ),
      MonumentData(
        id: '13',
        name: 'Army Museum',
        description: 'Military history and artifacts museum',
        position: const LatLng(33.6167, 73.0500),
        category: 'Cultural',
        icon: 'museum',
        status: 'Available',
      ),
      MonumentData(
        id: '14',
        name: 'Liaquat Bagh',
        description: 'Public park named after Pakistan\'s first Prime Minister',
        position: const LatLng(33.6000, 73.0167),
        category: 'Historical',
        icon: 'park',
        status: 'Available',
      ),
    ];
  }

  static List<MonumentData> getAllMonuments() {
    return [
      ...getIslamabadMonuments(),
      ...getRawalpindiMonuments(),
    ];
  }
}
