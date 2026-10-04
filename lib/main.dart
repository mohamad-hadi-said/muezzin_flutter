import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:alarm/utils/alarm_set.dart';
import 'package:muezzin_flutter/core/theme/muezzin_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:muezzin_flutter/core/cache/app_cache.dart';
import 'package:muezzin_flutter/core/theme/app_text_theme.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:muezzin_flutter/core/services/notification_service.dart';
import 'package:muezzin_flutter/core/services/prayer_alarm_service.dart';
import 'package:muezzin_flutter/src/view/widgets/azan_ringing_dialog.dart';
import 'src/view/muezzin_screen.dart';
import 'injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await di.configureDependencies();


    // Initialize AppCache
    await AppCache.initializeCache();


    // Initialize Prayer Alarm Service for exact alarms, full audio & lock screen wake-up
    await PrayerAlarmService.initialize();

    // Initialize local notifications
    await NotificationService.initialize();

    // Run the app immediately so the UI is displayed without delay
    runApp(const MyApp());

    // Request permissions asynchronously without blocking the UI startup
    PrayerAlarmService.checkAndRequestPermissions();
    NotificationService.ensurePermission();

    // Consume initial notification action if the app was launched via notification
    await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: true);
  } catch (e) {
    // Handle initialization errors
    runApp(
      MaterialApp(
        theme: MuezzinTheme.lightTheme,
        darkTheme: MuezzinTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: Scaffold( 
          backgroundColor: MuezzinTheme.primaryBackground,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: MuezzinTheme.errorColor,
                    size: 72,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Initialization Error',
                    style: AppTextTheme.lightTextTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to initialize the app. Please try again later.\n\nError: $e',
                    textAlign: TextAlign.center,
                    style: AppTextTheme.lightTextTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      // Try to restart the app
                      main();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MuezzinTheme.accentColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Global navigator key for accessing context anywhere in the app
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Muezzin',
      theme: MuezzinTheme.lightTheme,
      darkTheme: MuezzinTheme.darkTheme,
      themeMode: ThemeMode.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'SY'), // Arabic Syria
        Locale('ar', ''), // Arabic
      ],
      locale: const Locale('ar', 'SY'),
      home: const _AppLifecycleWrapper(child: MuezzinScreen()),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0), // Prevent text scaling
            ),
            child: child!,
          ),
        );
      },
    );
  }
}

class _AppLifecycleWrapper extends StatefulWidget {
  final Widget child;
  const _AppLifecycleWrapper({required this.child});

  @override
  State<_AppLifecycleWrapper> createState() => _AppLifecycleWrapperState();
}

class _AppLifecycleWrapperState extends State<_AppLifecycleWrapper>
    with WidgetsBindingObserver {
  StreamSubscription<AlarmSet>? _ringingSubscription;
  bool _isDialogShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Listen to ringing alarms while the app is active
    _ringingSubscription = PrayerAlarmService.ringingStream.listen((AlarmSet? alarmSet) {
      if (alarmSet != null) {
        _checkAndShowRingingDialog(alarmSet);
      }
    });

    // Check immediately on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowRingingDialog(Alarm.ringing.value);
    });
  }

  void _checkAndShowRingingDialog(AlarmSet alarmSet) async {
    if (alarmSet.alarms.isNotEmpty && !_isDialogShowing) {
      final context = MyApp.navigatorKey.currentContext;
      if (context != null) {
        _isDialogShowing = true;
        final ringingAlarm = alarmSet.alarms.first;
        try {
          await AzanRingingDialog.show(context, ringingAlarm);
        } finally {
          _isDialogShowing = false;
        }
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final cachedTimes = AppCache.instance.getPrayerTimes();
      if (cachedTimes.isNotEmpty) {
        NotificationService.scheduleUpcomingPrayers(cachedTimes);
      }
      _checkAndShowRingingDialog(Alarm.ringing.value);
    }
  }

  @override
  void dispose() {
    _ringingSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

//https://aladhan.com/prayer-times-api
