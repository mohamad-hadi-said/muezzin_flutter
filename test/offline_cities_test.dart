import 'package:flutter_test/flutter_test.dart';
import 'package:muezzin_flutter/core/utils/offline_cities.dart';

void main() {
  group('OfflineCitiesHelper Tests', () {
    test('Correctly identifies Tel Rifaat from coordinates', () {
      final city = OfflineCitiesHelper.findNearestCity(36.4786, 37.1009);
      expect(city, equals('تل رفعت، حلب'));
    });

    test('Correctly identifies Aleppo center', () {
      final city = OfflineCitiesHelper.findNearestCity(36.2021, 37.1343);
      expect(city, equals('حلب، سوريا'));
    });

    test('Correctly identifies Damascus', () {
      final city = OfflineCitiesHelper.findNearestCity(33.5138, 36.2765);
      expect(city, equals('دمشق، سوريا'));
    });

    test('Correctly identifies Mecca', () {
      final city = OfflineCitiesHelper.findNearestCity(21.4225, 39.8262);
      expect(city, equals('مكة المكرمة، السعودية'));
    });
  });
}
