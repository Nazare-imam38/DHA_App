import 'dart:convert';
import 'dart:math';
import 'package:latlong2/latlong.dart';

class GeoJsonParser {
  /// Parse GeoJSON coordinates and return the center point as LatLng
  /// The st_asgeojson field contains coordinates in EPSG:32643 projection
  /// which needs to be converted to WGS84 (standard lat/lng)
  static LatLng? parsePlotCoordinates(String? geoJsonString) {
    if (geoJsonString == null || geoJsonString.isEmpty) {
      print('GeoJSON string is null or empty');
      return null;
    }

    try {
      final geoJson = json.decode(geoJsonString);
      final coordinates = geoJson['coordinates'];
      
      if (coordinates == null || coordinates is! List) {
        print('Invalid coordinates structure');
        return null;
      }

      // For MultiPolygon, get the first polygon's first ring
      List<List<dynamic>> firstRing;
      if (coordinates is List && coordinates.isNotEmpty) {
        if (coordinates[0] is List && coordinates[0][0] is List) {
          // MultiPolygon structure
          firstRing = List<List<dynamic>>.from(coordinates[0][0]);
        } else if (coordinates[0] is List) {
          // Polygon structure
          firstRing = List<List<dynamic>>.from(coordinates[0]);
        } else {
          print('Invalid polygon structure');
          return null;
        }
      } else {
        print('Empty coordinates');
        return null;
      }

      if (firstRing.isEmpty) {
        print('Empty first ring');
        return null;
      }

      // Calculate center point from all coordinates
      double sumX = 0;
      double sumY = 0;
      int count = 0;

      for (final coord in firstRing) {
        if (coord is List && coord.length >= 2) {
          sumX += coord[0].toDouble();
          sumY += coord[1].toDouble();
          count++;
        }
      }

      if (count == 0) {
        print('No valid coordinates found');
        return null;
      }

      final centerX = sumX / count;
      final centerY = sumY / count;

      print('Raw coordinates: X=$centerX, Y=$centerY');

      // Convert UTM coordinates to proper LatLng using UTM Zone 43N
      final latLng = _utmToLatLng(centerX, centerY, 43, northernHemisphere: true);
      
      print('Converted coordinates: Lat=${latLng.latitude}, Lng=${latLng.longitude}');
      return latLng;
    } catch (e) {
      print('Error parsing GeoJSON: $e');
      return null;
    }
  }


  /// Convert UTM coordinates to LatLng using proper UTM Zone 43N conversion
  static LatLng _utmToLatLng(double easting, double northing, int zoneNumber,
      {bool northernHemisphere = true}) {
    const double a = 6378137.0; // WGS84 major axis
    const double e = 0.081819191; // WGS84 eccentricity
    const double k0 = 0.9996;

    double x = easting - 500000.0; // remove 500,000 meter offset
    double y = northing;

    if (!northernHemisphere) {
      y -= 10000000.0; // adjust for southern hemisphere
    }

    double m = y / k0;
    double mu = m / (a * (1 - pow(e, 2) / 4 - 3 * pow(e, 4) / 64 - 5 * pow(e, 6) / 256));

    double e1 = (1 - sqrt(1 - pow(e, 2))) / (1 + sqrt(1 - pow(e, 2)));

    double j1 = (3 * e1 / 2 - 27 * pow(e1, 3) / 32);
    double j2 = (21 * pow(e1, 2) / 16 - 55 * pow(e1, 4) / 32);
    double j3 = (151 * pow(e1, 3) / 96);
    double j4 = (1097 * pow(e1, 4) / 512);

    double fp = mu +
        j1 * sin(2 * mu) +
        j2 * sin(4 * mu) +
        j3 * sin(6 * mu) +
        j4 * sin(8 * mu);

    double e2 = pow((e * a / (a * (1 - pow(e, 2)))), 2).toDouble();
    double c1 = e2 * pow(cos(fp), 2).toDouble();
    double t1 = pow(tan(fp), 2).toDouble();
    double r1 = a * (1 - pow(e, 2)) /
        pow(1 - pow(e, 2) * pow(sin(fp), 2), 1.5).toDouble();
    double n1 = a / sqrt(1 - pow(e, 2) * pow(sin(fp), 2));

    double d = x / (n1 * k0);

    double q1 = n1 * tan(fp) / r1;
    double q2 = (pow(d, 2) / 2);
    double q3 = (5 + 3 * t1 + 10 * c1 - 4 * pow(c1, 2) - 9 * e2) * pow(d, 4) / 24;
    double q4 = (61 + 90 * t1 + 298 * c1 + 45 * pow(t1, 2) - 3 * pow(c1, 2) - 252 * e2) * pow(d, 6) / 720;
    double lat = fp - q1 * (q2 - q3 + q4);

    double q5 = d;
    double q6 = (1 + 2 * t1 + c1) * pow(d, 3) / 6;
    double q7 = (5 - 2 * c1 + 28 * t1 - 3 * pow(c1, 2) + 8 * e2 + 24 * pow(t1, 2)) * pow(d, 5) / 120;
    double lng = (d - q6 + q7) / cos(fp);

    double lonOrigin = (zoneNumber - 1) * 6 - 180 + 3;

    lat = lat * (180 / pi);
    lng = lonOrigin + lng * (180 / pi);

    return LatLng(lat, lng);
  }

  /// Get bounding box from GeoJSON for map fitting
  static Map<String, double>? getBoundingBox(String? geoJsonString) {
    if (geoJsonString == null || geoJsonString.isEmpty) {
      return null;
    }

    try {
      final geoJson = json.decode(geoJsonString);
      final coordinates = geoJson['coordinates'];
      
      if (coordinates == null || coordinates is! List) {
        return null;
      }

      List<List<dynamic>> firstRing;
      if (coordinates is List && coordinates.isNotEmpty) {
        if (coordinates[0] is List && coordinates[0][0] is List) {
          firstRing = List<List<dynamic>>.from(coordinates[0][0]);
        } else if (coordinates[0] is List) {
          firstRing = List<List<dynamic>>.from(coordinates[0]);
        } else {
          return null;
        }
      } else {
        return null;
      }

      if (firstRing.isEmpty) {
        return null;
      }

      double minX = double.infinity;
      double maxX = double.negativeInfinity;
      double minY = double.infinity;
      double maxY = double.negativeInfinity;

      for (final coord in firstRing) {
        if (coord is List && coord.length >= 2) {
          final x = coord[0].toDouble();
          final y = coord[1].toDouble();
          
          minX = minX < x ? minX : x;
          maxX = maxX > x ? maxX : x;
          minY = minY < y ? minY : y;
          maxY = maxY > y ? maxY : y;
        }
      }

      return {
        'minX': minX,
        'maxX': maxX,
        'minY': minY,
        'maxY': maxY,
      };
    } catch (e) {
      print('Error parsing GeoJSON bounding box: $e');
      return null;
    }
  }
}
