import 'package:muezzin_flutter/core/theme/muezzin_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:muezzin_flutter/core/cache/app_cache.dart';
import 'package:muezzin_flutter/core/services/ad_mob_service.dart';
import 'package:muezzin_flutter/core/theme/app_text_theme.dart';
import 'core/services/supabase_service.dart';
import 'src/view/welcome_page.dart';
import 'injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await di.configureDependencies();

    // Initialize Supabase
    // SupabaseService();

    // Initialize AppCache
    await AppCache.initializeCache();

    AdMobService.configure(
      androidInterstitial: 'ca-app-pub-9647507547970609/4982116288',
      androidRewardedInterstitial: 'ca-app-pub-9647507547970609/2164381257',
      androidAppOpen: 'ca-app-pub-9647507547970609/9340179606',
      androidNative: 'ca-app-pub-9647507547970609/4519081851',
    );

    // Initialize AdMob
    AdMobService.initialize();

    // Run the app
    runApp(const MyApp());
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
      title: 'أذكاري حياتي',
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
      home: const _AppLifecycleWrapper(child: WelcomePage()),
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Try to show App Open ad when user returns to the app
      AdMobService.showAppOpenIfAvailable();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

//https://aladhan.com/prayer-times-api
