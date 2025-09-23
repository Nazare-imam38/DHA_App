import 'dart:math';
import 'package:latlong2/latlong.dart';

/// Optimized UTM to LatLng converter for DHA plots
/// Uses the provided implementation for maximum performance
class OptimizedUtmConverter {
  /// Convert UTM coordinates to LatLng using the optimized implementation
  /// This is the clean Dart method provided for maximum performance
  static LatLng utmToLatLng(double easting, double northing, int zoneNumber,
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

  /// Batch convert multiple UTM coordinates for better performance
  static List<LatLng> batchConvertUtmToLatLng(List<List<double>> utmCoordinates, int zoneNumber,
      {bool northernHemisphere = true}) {
    final results = <LatLng>[];
    
    for (final coord in utmCoordinates) {
      if (coord.length >= 2) {
        final latLng = utmToLatLng(coord[0], coord[1], zoneNumber, northernHemisphere: northernHemisphere);
        results.add(latLng);
      }
    }
    
    return results;
  }

  /// Test the conversion with known coordinates
  static void testConversion() {
    print('OptimizedUtmConverter: Testing UTM conversion...');
    
    // Test with known UTM coordinates for Islamabad area
    final testCases = [
      {'easting': 500000.0, 'northing': 3700000.0, 'expectedLat': 33.7, 'expectedLng': 73.0},
      {'easting': 300000.0, 'northing': 3700000.0, 'expectedLat': 33.7, 'expectedLng': 72.0},
      {'easting': 700000.0, 'northing': 3700000.0, 'expectedLat': 33.7, 'expectedLng': 74.0},
    ];
    
    for (final testCase in testCases) {
      final result = utmToLatLng(
        testCase['easting'] as double,
        testCase['northing'] as double,
        43,
        northernHemisphere: true,
      );
      
      print('OptimizedUtmConverter: UTM(${testCase['easting']}, ${testCase['northing']}) -> LatLng(${result.latitude}, ${result.longitude})');
      
      final expectedLat = testCase['expectedLat'] as double;
      final expectedLng = testCase['expectedLng'] as double;
      
      if ((result.latitude - expectedLat).abs() < 1.0 && (result.longitude - expectedLng).abs() < 1.0) {
        print('OptimizedUtmConverter: ✅ Test PASSED');
      } else {
        print('OptimizedUtmConverter: ❌ Test FAILED - Expected around ($expectedLat, $expectedLng)');
      }
    }
  }
}
