import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:muezzin_flutter/src/model/prayer_times_models.dart';

class PrayerAlarmService {
  static bool _isScheduling = false;

  /// Initialize the Alarm system
  static Future<void> initialize() async {
    try {
      await Alarm.init();
      debugPrint('✅ PrayerAlarmService initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing PrayerAlarmService: $e');
    }
  }

  /// Request permissions for exact alarms and notifications
  static Future<bool> checkAndRequestPermissions() async {
    try {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications(
          permissions: const [
            NotificationPermission.Alert,
            NotificationPermission.Sound,
            NotificationPermission.Badge,
            NotificationPermission.Vibration,
            NotificationPermission.Light,
            NotificationPermission.PreciseAlarms,
            NotificationPermission.FullScreenIntent,
          ],
        );
      } else {
        // Ensure precise alarms permission is granted for Android 12+
        final granted = await AwesomeNotifications().checkPermissionList(
          permissions: const [NotificationPermission.PreciseAlarms],
        );
        if (!granted.contains(NotificationPermission.PreciseAlarms)) {
          await AwesomeNotifications().requestPermissionToSendNotifications(
            permissions: const [NotificationPermission.PreciseAlarms],
          );
        }
      }
      return true;
    } catch (e) {
      debugPrint('Error checking alarm permissions: $e');
      return false;
    }
  }

  /// Unique 32-bit integer ID for an alarm based on date and prayer index
  static int _idFor(DateTime dt, int idx) =>
      ((dt.year % 100) * 10000 + dt.month * 100 + dt.day) * 10 + (idx + 1);

  /// Arabic prayer names map
  static const Map<String, String> prayerNamesAr = {
    'fajr': 'الفجر',
    'dhuhr': 'الظهر',
    'asr': 'العصر',
    'maghrib': 'المغرب',
    'isha': 'العشاء',
  };

  /// Schedule upcoming prayers for today and the next [daysAhead] days
  static Future<void> scheduleUpcomingPrayers(
    List<PrayerTimesData> monthData, {
    int daysAhead = 1,
  }) async {
    if (monthData.isEmpty) return;
    if (_isScheduling) return;
    _isScheduling = true;

    try {
      // Clear previously scheduled alarms to avoid duplicates
      await Alarm.stopAll();

      final now = DateTime.now();
      final maxDate = DateTime(now.year, now.month, now.day + daysAhead, 23, 59, 59);
      int scheduledCount = 0;

      DateTime? parseLocal(String? iso) {
        if (iso == null) return null;
        try {
          return DateTime.parse(iso).toLocal();
        } catch (_) {
          return null;
        }
      }

      for (final dayData in monthData) {
        final timings = dayData.timings;
        if (timings == null) continue;

        final entries = <MapEntry<String, DateTime?>>[
          MapEntry('fajr', parseLocal(timings.fajr)),
          MapEntry('dhuhr', parseLocal(timings.dhuhr)),
          MapEntry('asr', parseLocal(timings.asr)),
          MapEntry('maghrib', parseLocal(timings.maghrib ?? timings.sunset)),
          MapEntry('isha', parseLocal(timings.isha)),
        ];

        int idx = 0;
        for (final e in entries) {
          final dt = e.value;
          if (dt == null) {
            idx++;
            continue;
          }

          // Only schedule if the prayer time is in the future AND within our target window
          if (dt.isAfter(now) && dt.isBefore(maxDate)) {
            final id = _idFor(dt, idx);
            final prayerName = prayerNamesAr[e.key] ?? 'الصلاة';

            try {
              final alarmSettings = AlarmSettings(
                id: id,
                dateTime: dt,
                assetAudioPath: 'assets/audio/ahmad-alkordi.mp3',
                loopAudio: false,
                vibrate: true,
                androidFullScreenIntent: true,
                androidStopAlarmOnTermination: false,
                volumeSettings: const VolumeSettings.fixed(
                  volume: 1.0,
                  volumeEnforced: false,
                ),
                notificationSettings: NotificationSettings(
                  title: 'حان الآن وقت صلاة $prayerName',
                  body: 'دخل وقت الصلاة الآن. نسأل الله القبول.',
                  stopButton: 'إيقاف الأذان',
                  androidStopAlarmOnDismiss: true,
                ),
              );

              await Alarm.set(alarmSettings: alarmSettings);
              scheduledCount++;
            } catch (e) {
              debugPrint('Error setting alarm for $prayerName at $dt: $e');
            }
          }
          idx++;
        }
      }
      debugPrint('✅ Successfully scheduled $scheduledCount full Azan alarms');
    } catch (e) {
      debugPrint('❌ Error in scheduleUpcomingPrayers: $e');
    } finally {
      _isScheduling = false;
    }
  }

  /// Stop a specific alarm by ID
  static Future<bool> stopAlarm(int id) async {
    return await Alarm.stop(id);
  }

  /// Stop all currently ringing or scheduled alarms
  static Future<void> stopAll() async {
    await Alarm.stopAll();
  }

  /// Stream of ringing alarms
  static Stream<AlarmSet> get ringingStream => Alarm.ringing;

  /// Check if a specific alarm is currently ringing
  static bool isRinging(int id) {
    return Alarm.ringing.value.containsId(id);
  }

  /// Check if any alarm is currently ringing
  static bool get isAnyRinging => Alarm.ringing.value.alarms.isNotEmpty;
}
