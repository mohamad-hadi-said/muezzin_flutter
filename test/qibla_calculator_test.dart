import 'package:flutter_test/flutter_test.dart';
import 'package:muezzin_flutter/core/utils/qibla_calculator.dart';

void main() {
  group('QiblaCalculator Tests', () {
    test('Medina coordinates point roughly South (~177 degrees)', () {
      // Medina coordinates
      const medinaLat = 24.4672;
      const medinaLng = 39.6024;

      final bearing = QiblaCalculator.calculateQiblaBearing(medinaLat, medinaLng);
      // Bearing should be around 177 degrees
      expect(bearing, greaterThan(170));
      expect(bearing, lessThan(185));

      final dist = QiblaCalculator.calculateDistanceToKaabaKm(medinaLat, medinaLng);
      // Distance between Medina and Mecca is approx 330-350 km
      expect(dist, greaterThan(300));
      expect(dist, lessThan(400));
    });

    test('Cairo coordinates point South-East (~136 degrees)', () {
      const cairoLat = 30.0444;
      const cairoLng = 31.2357;

      final bearing = QiblaCalculator.calculateQiblaBearing(cairoLat, cairoLng);
      expect(bearing, greaterThan(130));
      expect(bearing, lessThan(142));
    });

    test('Angular difference handles 360 wrap around', () {
      expect(QiblaCalculator.getAngleDifference(359, 1), closeTo(2.0, 0.01));
      expect(QiblaCalculator.getAngleDifference(1, 359), closeTo(-2.0, 0.01));
      expect(QiblaCalculator.isFacingQibla(136.5, 136.0), isTrue);
      expect(QiblaCalculator.isFacingQibla(130.0, 136.0), isFalse);
    });
  });
}
