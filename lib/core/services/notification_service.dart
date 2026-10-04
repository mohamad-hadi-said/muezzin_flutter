import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:muezzin_flutter/core/services/prayer_alarm_service.dart';
import 'package:muezzin_flutter/core/theme/muezzin_theme.dart';
import 'package:muezzin_flutter/src/model/prayer_times_models.dart';

class NotificationService {
  static const String _channelKey = 'prayer_general_channel';
  static const String _channelName = 'تنبيهات عامة لمواقيت الصلاة';
  static const String _channelDescription = 'إشعارات وتذكيرات التطبيق';

  static Future<void> initialize() async {
    // Attempt to remove legacy channels if present
    try {
      await AwesomeNotifications().removeChannel('prayer_channel_v3');
      await AwesomeNotifications().removeChannel('prayer_channel_v2');
      await AwesomeNotifications().removeChannel('prayer_channel');
      await cancelAllScheduled();
    } catch (_) {}

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
          playSound: false,
          enableVibration: true,
          channelShowBadge: true,
          defaultPrivacy: NotificationPrivacy.Public,
        ),
      ],
      debug: false,
    );
  }

  static Future<bool> ensurePermission() async {
    try {
      final isAllowed = await AwesomeNotifications().isNotificationAllowed();
      if (!isAllowed) {
        return await AwesomeNotifications().requestPermissionToSendNotifications(
          channelKey: _channelKey,
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

  /// Schedule upcoming prayers using PrayerAlarmService (ensuring full audio playback and lock screen wake-up)
  static Future<void> scheduleUpcomingPrayers(
    List<PrayerTimesData> monthData, {
    int daysAhead = 1,
  }) async {
    // Cancel legacy AwesomeNotifications schedules
    await cancelAllScheduled();

    // Delegate to PrayerAlarmService for native exact alarm clock, full audio & lock screen wake-up
    await PrayerAlarmService.scheduleUpcomingPrayers(monthData, daysAhead: daysAhead);
  }

  /// Backward compatible alias
  static Future<void> scheduleToThisMonth(List<PrayerTimesData> monthData) async {
    await scheduleUpcomingPrayers(monthData);
  }
}

