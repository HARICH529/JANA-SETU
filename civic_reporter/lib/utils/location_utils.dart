import 'dart:math';

class LatLngBounds {
  final double latMin;
  final double latMax;
  final double lonMin;
  final double lonMax;

  LatLngBounds({
    required this.latMin,
    required this.latMax,
    required this.lonMin,
    required this.lonMax,
  });

  @override
  String toString() {
    return 'Lat: [$latMin, $latMax], Lon: [$lonMin, $lonMax]';
  }
}

LatLngBounds getBoundingBox(double lat, double lon, double radiusMeters) {
  const double earthRadius = 6378137.0; // in meters

  // Latitude: 1° ≈ 111,320 m
  double deltaLat = (radiusMeters / 111320.0);

  // Longitude: depends on latitude
  double deltaLon = radiusMeters / (111320.0 * cos(lat * pi / 180));

  return LatLngBounds(
    latMin: lat - deltaLat,
    latMax: lat + deltaLat,
    lonMin: lon - deltaLon,
    lonMax: lon + deltaLon,
  );
}

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6378137.0; // in meters
  
  double dLat = (lat2 - lat1) * pi / 180;
  double dLon = (lon2 - lon1) * pi / 180;
  
  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(lat1 * pi / 180) * cos(lat2 * pi / 180) *
      sin(dLon / 2) * sin(dLon / 2);
  
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  
  return earthRadius * c;
}
