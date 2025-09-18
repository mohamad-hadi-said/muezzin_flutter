import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:muezzin_flutter/src/model/azkar_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AppCache is a singleton class that provides a centralized way to store and retrieve
/// data from SharedPreferences. It abstracts away the direct use of SharedPreferences
/// and provides a more convenient API for common operations.
class AppCache {
  // Cache keys
  static const String _tokenKey = 'token';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userScoreKey = 'user_score';
  static const String _azkarKey = 'azkar';
  static const String _adPointsKey = 'ad_points';
  static const String _timesPlayedKey = 'times_played';
  static const String _bestWinKey = 'best_win';
  // Daily ad tracking
  static const String _adDailyCountKey = 'ad_daily_count';
  static const String _adDailyDateKey = 'ad_daily_date';

  // Singleton instance
  static final AppCache _instance = AppCache._internal();
  late SharedPreferences _prefs;
  static bool _initialized = false;

  /// Get the singleton instance of AppCache
  static AppCache get instance => _instance;

  factory AppCache() {
    return _instance;
  }
  
  AppCache._internal();

  /// Initialize the cache. This should be called only once when the app starts.
  /// Returns true if initialization was performed, false if already initialized.
  Future<bool> init() async {
    if (_initialized) return false;
    
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
    return true;
  }
  
  /// Static method to initialize the cache when the app starts.
  /// This should be called from main.dart before runApp().
  static Future<void> initializeCache() async {
    await _instance.init();
    debugPrint('AppCache initialized successfully');
  }

  /// Check if the cache is initialized
  bool get isInitialized => _initialized;

  /// Save a token to the cache
  Future<bool> saveToken(String token) async {
    _checkInitialized();
    return await _prefs.setString(_tokenKey, token);
  }

  /// Get the token from the cache
  String? getToken() {
    _checkInitialized();
    return _prefs.getString(_tokenKey);
  }

  /// Remove the token from the cache
  Future<bool> removeToken() async {
    _checkInitialized();
    return await _prefs.remove(_tokenKey);
  }

  /// Save user data to the cache
  Future<bool> saveUserData(Map<String, dynamic> userData) async {
    _checkInitialized();
    return await _prefs.setString(_userKey, jsonEncode(userData));
  }

  /// Get user data from the cache
  Map<String, dynamic>? getUserData() {
    _checkInitialized();
    final userDataString = _prefs.getString(_userKey);
    if (userDataString == null) return null;
    
    try {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error decoding user data: $e');
      return null;
    }
  }

  /// Remove user data from the cache
  Future<bool> removeUserData() async {
    _checkInitialized();
    return await _prefs.remove(_userKey);
  }


  /// Save user score to the cache
  Future<bool> saveUserScore(int score) async {
    _checkInitialized();
    return await _prefs.setInt(_userScoreKey, score);
  }

  // ===== Ad Points =====
  /// Get accumulated ad points (increments whenever user watches an ad)
  int getAdPoints() {
    _checkInitialized();
    return _prefs.getInt(_adPointsKey) ?? 0;
  }

  /// Increment ad points by [by] (default 1). Returns the new total.
  Future<int> incrementAdPoints({int by = 1}) async {
    _checkInitialized();
    final current = _prefs.getInt(_adPointsKey) ?? 0;
    final updated = current + by;
    await _prefs.setInt(_adPointsKey, updated);
    return updated;
  }

  // ===== Daily Ads (Cap) =====
  /// Normalize stored daily date/count to today if needed and return today's count.
  int getAdsWatchedToday({int limit = 30}) {
    _checkInitialized();
    final todayStr = _formatDate(DateTime.now());
    final storedDate = _prefs.getString(_adDailyDateKey);
    if (storedDate != todayStr) {
      // New day: reset counter and set date
      _prefs.setString(_adDailyDateKey, todayStr);
      _prefs.setInt(_adDailyCountKey, 0);
      return 0;
    }
    return _prefs.getInt(_adDailyCountKey) ?? 0;
  }

  /// Increment today's watched ads counter and return the new value.
  Future<int> incrementAdsWatchedToday() async {
    _checkInitialized();
    // Normalize date first
    getAdsWatchedToday();
    final current = _prefs.getInt(_adDailyCountKey) ?? 0;
    final updated = current + 1;
    await _prefs.setInt(_adDailyCountKey, updated);
    return updated;
  }

  /// Remaining ads available for today given [limit].
  int getRemainingAdsToday(int limit) {
    _checkInitialized();
    final watched = getAdsWatchedToday(limit: limit);
    return math.max(0, limit - watched);
  }

  /// Whether user can show an ad today under the daily [limit].
  bool canShowAdToday({int limit = 30}) {
    return getRemainingAdsToday(limit) > 0;
  }

  // ===== Times Played =====
  /// Total times user started a game
  int getTimesPlayed() {
    _checkInitialized();
    return _prefs.getInt(_timesPlayedKey) ?? 0;
  }

  /// Increment times played, return new total
  Future<int> incrementTimesPlayed() async {
    _checkInitialized();
    final current = _prefs.getInt(_timesPlayedKey) ?? 0;
    final updated = current + 1;
    await _prefs.setInt(_timesPlayedKey, updated);
    return updated;
  }

  // ===== Best Win =====
  /// Highest cash prize the user has achieved
  int getBestWin() {
    _checkInitialized();
    return _prefs.getInt(_bestWinKey) ?? 0;
  }

  /// Save best win only if [amount] is higher than stored
  Future<int> saveBestWinIfHigher(int amount) async {
    _checkInitialized();
    final current = _prefs.getInt(_bestWinKey) ?? 0;
    if (amount > current) {
      await _prefs.setInt(_bestWinKey, amount);
      return amount;
    }
    return current;
  }

  /// Get user score from the cache
  int getUserScore() {
    _checkInitialized();
    return _prefs.getInt(_userScoreKey) ?? 0;
  }

  Future<bool> saveMuezzin(List<MuezzinModel> azkar) async {
    _checkInitialized();
    return await _prefs.setStringList(_azkarKey, azkar.map((question) =>jsonEncode(question.toJson())).toList());
  }

  List<MuezzinModel> getMuezzin() {
    _checkInitialized();
    final azkarStringList = _prefs.getStringList(_azkarKey);
    if (azkarStringList == null) return [];
    
    try {
      return azkarStringList.map((questionString) => MuezzinModel.fromJson(jsonDecode(questionString))).toList();
    } catch (e) {
      debugPrint('Error decoding azkar: $e');
      return [];
    }
  }

  /// Save login status to the cache
  Future<bool> saveIsLoggedIn(bool isLoggedIn) async {
    _checkInitialized();
    return await _prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  /// Get login status from the cache
  bool isLoggedIn() {
    _checkInitialized();
    return _prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Clear all data from the cache
  Future<bool> clearAll() async {
    _checkInitialized();
    return await _prefs.clear();
  }

  /// Check if the cache is initialized and throw an exception if not
  void _checkInitialized() {
    if (!_initialized) {
      throw Exception('AppCache is not initialized. Call AppCache.initializeCache() first.');
    }
  }

  Future<bool> setString(String key, String value) async {
    _checkInitialized();
    return await _prefs.setString(key, value);
  }

  String? getString(String key) {
    _checkInitialized();
    return _prefs.getString(key);
  }

  Future<bool> setBool(String key, bool value) async {
    _checkInitialized();
    return await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    _checkInitialized();
    return _prefs.getBool(key);
  }

  Future<bool> setInt(String key, int value) async {
    _checkInitialized();
    return await _prefs.setInt(key, value);
  }

  int? getInt(String key) {
    _checkInitialized();
    return _prefs.getInt(key);
  }

  Future<bool> setObject(String key, Map<String, dynamic> value) async {
    _checkInitialized();
    return await _prefs.setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? getObject(String key) {
    _checkInitialized();
    String? data = _prefs.getString(key);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  Future<bool> remove(String key) async {
    _checkInitialized();
    return await _prefs.remove(key);
  }

  Future<bool> clear() async {
    _checkInitialized();
    return await _prefs.clear();
  }




}

// ===== Helpers =====
String _formatDate(DateTime dt) {
  // yyyy-MM-dd
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
