import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:muezzin_flutter/core/theme/muezzin_theme.dart';
import 'package:muezzin_flutter/src/model/prayer_times_models.dart';

class NotificationService {
  static const String _channelKey = 'prayer_channel_v2';
  static const String _channelName = 'إشعارات مواقيت الصلاة';
  static const String _channelDescription = 'تنبيهات دخول أوقات الصلوات الخمس';

  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      // null => Default app icon
      null,
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

  static Future<void> ensurePermission() async {
    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  static Future<void> cancelAllScheduled() async {
    try {
      await AwesomeNotifications().cancelAllSchedules();
    } catch (_) {}
  }

  static Future<void> sendTestNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 999999,
        channelKey: _channelKey,
        title: 'اختبار الإشعار',
        body: 'هذا إشعار تجريبي للتحقق من صوت الأذان',
        notificationLayout: NotificationLayout.BigText,
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
        autoDismissible: true,
        badge: 1,
        color: MuezzinTheme.primaryColor,
      ),
    );
  }

  static int _idFor(DateTime dt, int idx) =>
      ((dt.year * 10000) + (dt.month * 100) + dt.day) * 10 + idx;

  static Future<void> scheduleToday(PrayerTimings? timings) async {
    if (timings == null) return;

    final now = DateTime.now();

    DateTime? _parseLocal(String? iso) {
      if (iso == null) return null;
      try {
        return DateTime.parse(iso).toLocal();
      } catch (_) {
        return null;
      }
    }

    final entries = <MapEntry<String, DateTime?>>[
      MapEntry('fajr', _parseLocal(timings.fajr)),
      MapEntry('dhuhr', _parseLocal(timings.dhuhr)),
      MapEntry('asr', _parseLocal(timings.asr)),
      MapEntry('maghrib', _parseLocal(timings.maghrib ?? timings.sunset)),
      MapEntry('isha', _parseLocal(timings.isha)),
    ];

    const namesAr = {
      'fajr': 'الفجر',
      'dhuhr': 'الظهر',
      'asr': 'العصر',
      'maghrib': 'المغرب',
      'isha': 'العشاء',
    };

    // Schedule upcoming prayers only
    int idx = 0;
    int scheduledCount = 0;
    for (final e in entries) {
      final dt = e.value;
      if (dt == null) {
        idx++;
        continue;
      }
      if (dt.isAfter(now)) {
        final id = _idFor(dt, idx);
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: id,
            channelKey: _channelKey,
            title: 'حان الآن وقت صلاة ${namesAr[e.key] ?? ''}',
            body: 'دخل وقت الصلاة الآن. نسأل الله القبول.',
            notificationLayout: NotificationLayout.BigText,
            category: NotificationCategory.Reminder,
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
      }
      idx++;
    }

    // If all prayers have passed today, schedule tomorrow's Fajr using today's time-of-day
    if (scheduledCount == 0) {
      final fajr = entries.first.value;
      if (fajr != null) {
        final tomorrowFajr = DateTime(
          now.year,
          now.month,
          now.day,
          fajr.hour,
          fajr.minute,
        ).add(const Duration(days: 1));
        final id = _idFor(tomorrowFajr, 0);
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: id,
            channelKey: _channelKey,
            title: 'حان الآن وقت صلاة ${namesAr['fajr']}',
            body: 'دخل وقت الصلاة الآن. نسأل الله القبول.',
            notificationLayout: NotificationLayout.BigText,
            category: NotificationCategory.Reminder,
            wakeUpScreen: true,
            autoDismissible: true,
            badge: 1,
            // smallIcon: 'resource://mipmap/ic_launcher',
            color: MuezzinTheme.primaryColor,
          ),
          actionButtons: [
            NotificationActionButton(
              key: 'OPEN_MUEZZIN',
              label: 'فتح المواقيت',
              // buttonType: ActionButtonType.Default,
            ),
          ],
          schedule: NotificationCalendar(
            year: tomorrowFajr.year,
            month: tomorrowFajr.month,
            day: tomorrowFajr.day,
            hour: tomorrowFajr.hour,
            minute: tomorrowFajr.minute,
            second: 0,
            millisecond: 0,
            preciseAlarm: true,
            allowWhileIdle: true,
          ),
        );
      }
    }
  }
}
