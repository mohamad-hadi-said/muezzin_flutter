import 'package:flutter_test/flutter_test.dart';
import 'package:muezzin_flutter/src/model/prayer_times_models.dart';

void main() {
  group('Prayer Times Parsing and Matching Tests', () {
    test('Correctly matches day formatted with leading zero like "07" with integer day 7', () {
      final sampleData = [
        PrayerTimesData(
          date: DateInfo(
            gregorian: GregorianInfo(day: '01'),
          ),
        ),
        PrayerTimesData(
          date: DateInfo(
            gregorian: GregorianInfo(day: '07'),
          ),
        ),
        PrayerTimesData(
          date: DateInfo(
            gregorian: GregorianInfo(day: '15'),
          ),
        ),
      ];

      const targetDay = 7;
      PrayerTimesData? found;
      for (final element in sampleData) {
        final dayStr = element.date?.gregorian?.day;
        if (dayStr == null) continue;
        final dayNum = int.tryParse(dayStr.trim());
        if (dayNum == targetDay) {
          found = element;
          break;
        }
      }

      expect(found, isNotNull);
      expect(found?.date?.gregorian?.day, equals('07'));
    });

    test('Filters prayers within upcoming 2-day window properly', () {
      final now = DateTime(2026, 9, 7, 10, 0);
      final maxDate = DateTime(now.year, now.month, now.day + 2, 23, 59, 59);

      final prayerTimes = [
        DateTime(2026, 9, 7, 4, 30), // Past
        DateTime(2026, 9, 7, 12, 30), // Today future
        DateTime(2026, 9, 8, 12, 30), // Tomorrow
        DateTime(2026, 9, 9, 12, 30), // Day after tomorrow (day + 2)
        DateTime(2026, 9, 10, 12, 30), // Day + 3 (should be excluded)
      ];

      final filtered = prayerTimes.where((dt) => dt.isAfter(now) && dt.isBefore(maxDate)).toList();

      expect(filtered.length, equals(3));
      expect(filtered.contains(DateTime(2026, 9, 7, 12, 30)), isTrue);
      expect(filtered.contains(DateTime(2026, 9, 8, 12, 30)), isTrue);
      expect(filtered.contains(DateTime(2026, 9, 9, 12, 30)), isTrue);
      expect(filtered.contains(DateTime(2026, 9, 10, 12, 30)), isFalse);
    });
  });
}
