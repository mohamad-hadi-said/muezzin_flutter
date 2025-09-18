import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:muezzin_flutter/core/cache/app_cache.dart';

/// AdMobService
/// A small utility wrapper around google_mobile_ads to:
/// - Initialize MobileAds
/// - Create Banner ads
/// - Load/Show Interstitial ads
/// - Load/Show Rewarded ads
///
/// References:
/// - google_mobile_ads example (pub.dev > Example)
/// - https://pub.dev/packages/google_mobile_ads
class AdMobService {
  AdMobService._();

  // Enable/disable internal logging
  static bool enableLogging = true;

  // ===== Configurable Ad Unit IDs (set these from your app) =====
  // Leave empty to fallback to AdMob sample/test unit IDs.
  static String bannerAdUnitIdAndroid = '';
  static String interstitialAdUnitIdAndroid = '';
  static String rewardedInterstitialAdUnitIdAndroid = '';
  static String appOpenAdUnitIdAndroid = '';
  static String nativeAdUnitIdAndroid = ''; 

  // Getters with platform-aware fallback to AdMob test IDs
  static String get bannerUnitId => bannerAdUnitIdAndroid.isNotEmpty ? bannerAdUnitIdAndroid : testBannerUnitId;

  static String get interstitialUnitId => interstitialAdUnitIdAndroid.isNotEmpty ? interstitialAdUnitIdAndroid : testInterstitialUnitId;

  static String get rewardedInterstitialUnitId => rewardedInterstitialAdUnitIdAndroid.isNotEmpty ? rewardedInterstitialAdUnitIdAndroid : testRewardedUnitId;

  static String get appOpenUnitId => appOpenAdUnitIdAndroid.isNotEmpty ? appOpenAdUnitIdAndroid : testAppOpenUnitId;
  static String get nativeUnitId => nativeAdUnitIdAndroid.isNotEmpty ? nativeAdUnitIdAndroid : testNativeUnitId;

  // Optional bulk configuration helper
  static void configure({
    String? androidBanner,
    String? androidInterstitial,
    String? androidRewardedInterstitial,
    String? androidAppOpen,
    String? androidNative,
  }) {
    if (androidBanner != null) bannerAdUnitIdAndroid = androidBanner;
    if (androidInterstitial != null) interstitialAdUnitIdAndroid = androidInterstitial;
    if (androidRewardedInterstitial != null) rewardedInterstitialAdUnitIdAndroid = androidRewardedInterstitial;
    if (androidAppOpen != null) appOpenAdUnitIdAndroid = androidAppOpen;
    if (androidNative != null) nativeAdUnitIdAndroid = androidNative;
    _log(Level.info, 'AdMobService configured');
  }

  // Logger configured similarly to SupabaseService
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static void _log(Level level, dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (!enableLogging) return;
    // Respect kDebugMode to avoid noisy logs in release
    if (kDebugMode) {
      _logger.log(level, message, error: error, stackTrace: stackTrace);
    }
  }

  // Call once at app start (before showing ads)
  static Future<InitializationStatus> initialize() {
    _log(Level.info, 'Initializing MobileAds');
    return MobileAds.instance.initialize();
  }

  // Optionally configure test devices during development
  // static void setTestDeviceIds(List<String> ids) {
  //   final reqConfig = RequestConfiguration(testDeviceIds: ids);
  //   MobileAds.instance.updateRequestConfiguration(reqConfig);
  // }

  // ===== Banner =====

  /// Create a BannerAd instance. You must call .load() on the returned instance
  /// and dispose it when no longer used.
  static BannerAd createBanner({
    required String adUnitId,
    AdSize size = AdSize.banner,
    AdRequest request = const AdRequest(),
    BannerAdListener? listener,
  }) {
    _log(Level.debug, 'Creating BannerAd unitId=$adUnitId, size=$size');
    return BannerAd(
      size: size,
      adUnitId: adUnitId,
      listener: listener ?? const BannerAdListener(),
      request: request,
    );
  }

  // ===== Interstitial =====

  /// Load an InterstitialAd. Returns the loaded ad or null if failed.
  static Future<InterstitialAd?> loadInterstitial({
    required String adUnitId,
    AdRequest request = const AdRequest(),
    void Function(LoadAdError error)? onFailed,
  }) async {
    _log(Level.debug, 'Loading InterstitialAd unitId=$adUnitId');
    // google_mobile_ads uses callback-based loading for InterstitialAd (returns void).
    // Wrap with a Completer to expose Future<InterstitialAd?> similar to Rewarded.
    final completer = Completer<InterstitialAd?>();

    try {
      await InterstitialAd.load(
        adUnitId: adUnitId,
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _log(Level.debug, 'Interstitial loaded');
            completer.complete(ad);
          },
          onAdFailedToLoad: (LoadAdError error) {
            _log(Level.error, 'Interstitial failed to load', error);
            onFailed?.call(error);
            completer.complete(null);
          },
        ),
      );
    } catch (e, stackTrace) {
      if (!completer.isCompleted) {
        _log(Level.error, 'Interstitial load threw', e, stackTrace);
        onFailed?.call(
          LoadAdError(0, 'LOAD_FAILED', 'Failed to load interstitial', null),
        );
        completer.complete(null);
      }
    }

    return completer.future;
  }

  /// Show an interstitial and handle lifecycle. Disposes the ad automatically.
  static Future<void> showInterstitial(
    InterstitialAd? ad, {
    VoidCallback? onDismissed,
    void Function(AdError error)? onFailedToShow,
  }) async {
    if (ad == null) {
      onFailedToShow?.call(
        AdError(0, 'NULL_AD', 'Interstitial is null'),
      );
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _log(Level.debug, 'Interstitial dismissed');
        ad.dispose();
        // Count as watched
        try {
          AppCache.instance.incrementAdPoints();
        } catch (e, st) {
          _log(Level.warning, 'Failed to increment ad points (interstitial)', e, st);
        }
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _log(Level.error, 'Interstitial failed to show', error);
        ad.dispose();
        onFailedToShow?.call(error);
      },
    );

    // Optional immersive mode (like examples)
    ad.setImmersiveMode(true);
    _log(Level.debug, 'Showing Interstitial');
    await ad.show();
  }

  // ===== Rewarded =====

  /// Load a RewardedInterstitialAd. Returns the loaded ad or null if failed.
  static Future<RewardedInterstitialAd?> loadRewardedInterstitial({
    required String adUnitId,
    AdRequest request = const AdRequest(),
    void Function(LoadAdError error)? onFailed,
  }) async {
    // Gate by daily limit
    try {
      if (!AppCache.instance.canShowAdToday(limit: 30)) {
        _log(Level.info, 'Rewarded load blocked by daily cap');
        return null;
      }
    } catch (_) {}
    _log(Level.debug, 'Loading RewardedInterstitialAd unitId=$adUnitId');
    // google_mobile_ads 6.0.0 uses callback-based loading for RewardedAd (returns void).
    // Wrap it in a Completer to expose a Future<RewardedAd?> similar to Interstitial.
    final completer = Completer<RewardedInterstitialAd?>();

    try {
      await RewardedInterstitialAd.load(
        adUnitId: adUnitId,
        request: request,
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (RewardedInterstitialAd ad) {
            _log(Level.debug, 'Rewarded loaded');
            completer.complete(ad);
          },
          onAdFailedToLoad: (LoadAdError error) {
            _log(Level.error, 'Rewarded failed to load', error);
            onFailed?.call(error);
            completer.complete(null);
          },
        ),
      );
    } catch (e, stackTrace) {
      if (!completer.isCompleted) {
        _log(Level.error, 'Rewarded load threw', e, stackTrace);
        onFailed?.call(
          LoadAdError(0, 'LOAD_FAILED', 'Failed to load rewarded', null),
        );
        completer.complete(null);
      }
    }

    return completer.future;
  }

  /// Show a rewarded interstitial ad and handle reward/lifecycle. Disposes the ad automatically.
  static Future<void> showRewardedInterstitial(
    RewardedInterstitialAd? ad, {
    required void Function(AdWithoutView ad, RewardItem reward) onUserEarnedReward,
    VoidCallback? onDismissed,
    void Function(AdError error)? onFailedToShow,
  }) async {
    if (ad == null) {
      onFailedToShow?.call(
        AdError(0, 'NULL_AD', 'Rewarded is null'),
      );
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _log(Level.debug, 'Rewarded dismissed');
        ad.dispose();
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _log(Level.error, 'Rewarded failed to show', error);
        ad.dispose();
        onFailedToShow?.call(error);
      },
    );

    _log(Level.debug, 'Showing Rewarded');
    await ad.show(onUserEarnedReward: (adv, reward) {
      // Count as watched (only when reward is granted)
      try {
        AppCache.instance.incrementAdPoints();
        AppCache.instance.incrementAdsWatchedToday();
      } catch (e, st) {
        _log(Level.warning, 'Failed to increment ad points (rewarded)', e, st);
      }
      onUserEarnedReward(adv, reward);
    });
  }

  // ===== Test IDs helper (optional) =====

  /// AdMob sample/test unit IDs (for development).
  static String get testBannerUnitId =>
      Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';

  static String get testInterstitialUnitId =>
      Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';

  static String get testRewardedUnitId =>
      Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313';

  static String get testAppOpenUnitId =>
      Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/3419835294'
          : 'ca-app-pub-3940256099942544/5662855259';

  static String get testNativeUnitId =>
      Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/2247696110'
          : 'ca-app-pub-3940256099942544/3986624511';

  // ===== Native (Advanced) =====

  /// Create and load a NativeAd. You must dispose it when no longer used.
  /// Note: Requires a NativeAdFactory registered on Android with the given factoryId.
  static NativeAd createAndLoadNative({
    String? adUnitId,
    String factoryId = 'listTile',
    AdRequest request = const AdRequest(),
    NativeAdListener? listener,
  }) {
    final unit = adUnitId ?? nativeUnitId;
    _log(Level.debug, 'Creating NativeAd unitId=' + unit + ' factoryId=' + factoryId);
    final ad = NativeAd(
      adUnitId: unit,
      factoryId: factoryId,
      request: request,
      listener: listener ?? NativeAdListener(),
    );
    ad.load();
    return ad;
  }

  // ===== App Open Ad (Android) =====

  static AppOpenAd? _appOpenAd;
  static DateTime? _appOpenLoadTime;
  static bool _isShowingAppOpenAd = false;
  static const Duration _maxCacheDuration = Duration(hours: 4);

  static bool get _isAppOpenAdAvailable => _appOpenAd != null;

  static bool _isAdFresh() {
    if (_appOpenLoadTime == null) return false;
    return DateTime.now().difference(_appOpenLoadTime!) < _maxCacheDuration;
  }

  /// Loads an App Open Ad if none available or stale.
  static Future<void> loadAppOpen({String? adUnitId}) async {
    if (_isAppOpenAdAvailable && _isAdFresh()) {
      _log(Level.debug, 'AppOpen already loaded and fresh');
      return;
    }

    _log(Level.debug, 'Loading AppOpenAd unitId=${adUnitId ?? appOpenUnitId}');
    await AppOpenAd.load(
      adUnitId: adUnitId ?? appOpenUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _log(Level.debug, 'AppOpen loaded');
          _appOpenAd = ad;
          _appOpenLoadTime = DateTime.now();
        },
        onAdFailedToLoad: (error) {
          _log(Level.error, 'AppOpen failed to load', error);
          _appOpenAd = null;
        },
      ),
    );
  }

  /// Shows App Open Ad if available. Returns true if shown.
  static Future<bool> showAppOpenIfAvailable({VoidCallback? onDismissed}) async {
    if (!_isAppOpenAdAvailable) {
      _log(Level.debug, 'No AppOpenAd available to show');
      return false;
    }
    if (_isShowingAppOpenAd) {
      _log(Level.debug, 'AppOpen is already showing');
      return false;
    }
    if (!_isAdFresh()) {
      _log(Level.debug, 'AppOpenAd is stale, discarding and reloading');
      _appOpenAd?.dispose();
      _appOpenAd = null;
      await loadAppOpen();
      return false;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _log(Level.debug, 'AppOpen showed');
        _isShowingAppOpenAd = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        _log(Level.debug, 'AppOpen dismissed');
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
        // Count as watched
        try {
          AppCache.instance.incrementAdPoints();
        } catch (e, st) {
          _log(Level.warning, 'Failed to increment ad points (app-open)', e, st);
        }
        onDismissed?.call();
        // Preload the next one
        loadAppOpen();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _log(Level.error, 'AppOpen failed to show', error);
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
        // Try preloading next
        loadAppOpen();
      },
    );

    _log(Level.debug, 'Showing AppOpen');
    _appOpenAd!.show();
    return true;
  }
}