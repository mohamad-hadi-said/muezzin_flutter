import 'dart:math' as math;

/// Utility class to calculate Qibla direction and distance to the Kaaba
class QiblaCalculator {
  /// Holy Kaaba coordinates in Mecca, Saudi Arabia
  static const double kaabaLatitude = 21.422487;
  static const double kaabaLongitude = 39.826206;

  /// Calculate the Qibla bearing in degrees (0 to 360, clockwise from True North)
  static double calculateQiblaBearing(double userLat, double userLng) {
    final double phi1 = userLat * (math.pi / 180.0);
    final double phi2 = kaabaLatitude * (math.pi / 180.0);
    final double deltaLambda = (kaabaLongitude - userLng) * (math.pi / 180.0);

    final double y = math.sin(deltaLambda) * math.cos(phi2);
    final double x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    final double bearingRad = math.atan2(y, x);
    final double bearingDeg = (bearingRad * (180.0 / math.pi) + 360.0) % 360.0;
    return bearingDeg;
  }

  /// Calculate great-circle distance to Kaaba in kilometers
  static double calculateDistanceToKaabaKm(double userLat, double userLng) {
    const double earthRadiusKm = 6371.0;
    final double dLat = (kaabaLatitude - userLat) * (math.pi / 180.0);
    final double dLng = (kaabaLongitude - userLng) * (math.pi / 180.0);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(userLat * (math.pi / 180.0)) *
            math.cos(kaabaLatitude * (math.pi / 180.0)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Calculate the signed shortest angular difference between device heading and Qibla (-180..+180)
  static double getAngleDifference(double heading, double qiblaBearing) {
    double diff = (qiblaBearing - heading) % 360.0;
    if (diff > 180.0) diff -= 360.0;
    if (diff < -180.0) diff += 360.0;
    return diff;
  }

  /// Check if the user is pointing towards the Qibla within the specified tolerance
  static bool isFacingQibla(double heading, double qiblaBearing, {double tolerance = 3.5}) {
    return getAngleDifference(heading, qiblaBearing).abs() <= tolerance;
  }
}
