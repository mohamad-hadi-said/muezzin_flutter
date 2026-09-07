import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:muezzin_flutter/core/theme/muezzin_theme.dart';
import 'package:muezzin_flutter/src/model/prayer_times_models.dart';

class NotificationService {
  static const String _channelKey = 'prayer_channel_v2';
  static const String _channelName = 'إشعارات مواقيت الصلاة';
  static const String _channelDescription = 'تنبيهات دخول أوقات الصلوات الخمس';

  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      null, // resource://mipmap/ic_launcher
      [
        NotificationChannel(
          channelKey: _channelKey,
          channelName: _channelName,
          channelDescription: _channelDescription,
          defaultColor: MuezzinTheme.primaryColor,
          ledColor: MuezzinTheme.primaryColor,
          importance: NotificationImportance.High,
          playSound: true,
          soundSource: 'resource://raw/ahmad_alkordi',
          enableVibration: true,
          channelShowBadge: true,
        ),
      ],
      debug: false,
    );
  }

  static bool _isScheduling = false;

  static Future<bool> ensurePermission() async {
    try {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        return await AwesomeNotifications().requestPermissionToSendNotifications();
      }
      return true;
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
      return false;
    }
  }

  static Future<void> cancelAllScheduled() async {
    try {
      await AwesomeNotifications().cancelAllSchedules().timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('Error or timeout canceling notifications: $e');
    }
  }

  static int _idFor(DateTime dt, int idx) =>
      ((dt.year * 10000) + (dt.month * 100) + dt.day) * 10 + idx;

  /// Schedule upcoming prayers for today and the next [daysAhead] days (default 1 day = today + tomorrow).
  /// This prevents UI freezes, adheres to OS notification quotas, and complies with Android policies.
  static Future<void> scheduleUpcomingPrayers(
    List<PrayerTimesData> monthData, {
    int daysAhead = 1,
  }) async {
    if (monthData.isEmpty) return;
    if (_isScheduling) return;
    _isScheduling = true;

    try {
      // Await cancellation with timeout first to prevent SQLite database lock
      await cancelAllScheduled();

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

      const namesAr = {
        'fajr': 'الفجر',
        'dhuhr': 'الظهر',
        'asr': 'العصر',
        'maghrib': 'المغرب',
        'isha': 'العشاء',
      };

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
            try {
              await AwesomeNotifications().createNotification(
                content: NotificationContent(
                  id: id,
                  channelKey: _channelKey,
                  title: 'حان الآن وقت صلاة ${namesAr[e.key] ?? ''}',
                  body: 'دخل وقت الصلاة الآن. نسأل الله القبول.',
                  notificationLayout: NotificationLayout.BigText,
                  category: NotificationCategory.Alarm,
                  wakeUpScreen: true,
                  autoDismissible: true,
                  badge: 1,
                  color: MuezzinTheme.primaryColor,
                ),
                actionButtons: [
                  NotificationActionButton(
                    key: 'OPEN_MUEZZIN',
                    label: 'فتح المواقيت',
                  ),
                ],
                schedule: NotificationCalendar(
                  year: dt.year,
                  month: dt.month,
                  day: dt.day,
                  hour: dt.hour,
                  minute: dt.minute,
                  second: 0,
                  millisecond: 0,
                  preciseAlarm: true,
                  allowWhileIdle: true,
                ),
              );
              scheduledCount++;
              // Yield briefly to ensure UI loop remains silky smooth
              await Future.delayed(const Duration(milliseconds: 10));
            } catch (e) {
              debugPrint('Error scheduling notification: $e');
            }
          }
          idx++;
        }
      }
      debugPrint('✅ Scheduled $scheduledCount prayer notifications for upcoming days');
    } finally {
      _isScheduling = false;
    }
  }

  /// Backward compatible alias
  static Future<void> scheduleToThisMonth(List<PrayerTimesData> monthData) async {
    await scheduleUpcomingPrayers(monthData);
  }
}
