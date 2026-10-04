import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:muezzin_flutter/core/cache/app_cache.dart';
import 'package:muezzin_flutter/core/utils/offline_cities.dart';

class LocationHelper {
  static final Geocoding _geocoding = Geocoding(locale: const Locale('ar'));
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'User-Agent': 'MuezzinFlutterApp/1.0 (Android; Arabic)',
        'Accept': 'application/json',
      },
    ),
  );

  /// Resolves the human-readable city and country name in Arabic from GPS coordinates.
  /// NEVER returns raw coordinates (latitude/longitude) to the user.
  static Future<String> resolveAndSaveCityName(double latitude, double longitude) async {
    // 1. Instant offline resolution fallback candidate
    final String? offlineMatch = OfflineCitiesHelper.findNearestCity(latitude, longitude);

    // 2. Try online reverse geocoding via BigDataCloud (fast, Arabic)
    try {
      final response = await _dio.get(
        'https://api.bigdatacloud.net/data/reverse-geocode-client',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'localityLanguage': 'ar',
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final city = (data['city'] ?? data['locality'] ?? data['principalSubdivision'])?.toString().trim();
        final country = data['countryName']?.toString().trim();

        String displayName = '';
        if (city != null && city.isNotEmpty) {
          if (country != null && country.isNotEmpty && city != country) {
            displayName = '$city، $country';
          } else {
            displayName = city;
          }
        } else if (country != null && country.isNotEmpty) {
          displayName = country;
        }

        if (displayName.isNotEmpty && !_isCoordinateString(displayName)) {
          await AppCache.instance.saveUserCityName(displayName);
          return displayName;
        }
      }
    } catch (e) {
      debugPrint('BigDataCloud geocoder error: $e');
    }

    // 3. Try Native Android/iOS Geocoder (direct from OS)
    try {
      final List<Placemark> placemarks = await _geocoding.placemarkFromCoordinates(
        latitude,
        longitude,
        locale: const Locale('ar'),
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;

        final String? locality = (place.locality?.trim().isNotEmpty == true)
            ? place.locality!.trim()
            : ((place.subAdministrativeArea?.trim().isNotEmpty == true)
                ? place.subAdministrativeArea!.trim()
                : place.administrativeArea?.trim());

        final String? country = place.country?.trim();

        String displayName = '';
        if (locality != null && locality.isNotEmpty) {
          if (country != null && country.isNotEmpty && locality != country) {
            displayName = '$locality، $country';
          } else {
            displayName = locality;
          }
        } else if (country != null && country.isNotEmpty) {
          displayName = country;
        }

        if (displayName.isNotEmpty && !_isCoordinateString(displayName)) {
          await AppCache.instance.saveUserCityName(displayName);
          return displayName;
        }
      }
    } catch (e) {
      debugPrint('Native geocoder error: $e');
    }

    // 4. If offline match is available, use it immediately
    if (offlineMatch != null && offlineMatch.isNotEmpty) {
      await AppCache.instance.saveUserCityName(offlineMatch);
      return offlineMatch;
    }

    // 5. Fallback: Previously cached name if it does not contain coordinates
    final cached = AppCache.instance.getUserCityName();
    if (cached != null && cached.isNotEmpty && !_isCoordinateString(cached) && cached != 'الموقع الحالي') {
      return cached;
    }

    // 6. Safe user-friendly default (strictly NO coordinates)
    const fallback = 'الموقع الحالي';
    await AppCache.instance.saveUserCityName(fallback);
    return fallback;
  }

  /// Get cached city name or a sensible offline fallback (never coordinates)
  static String getCachedCityName() {
    final cached = AppCache.instance.getUserCityName();
    if (cached != null &&
        cached.isNotEmpty &&
        !_isCoordinateString(cached) &&
        cached != 'الموقع الحالي') {
      return cached;
    }

    final position = AppCache.instance.getUserLocation();
    if (position != null) {
      final offlineCity = OfflineCitiesHelper.findNearestCity(position.latitude, position.longitude);
      if (offlineCity != null) {
        return offlineCity;
      }
    }

    return 'الموقع الحالي';
  }

  static bool _isCoordinateString(String str) {
    return str.contains('خط عرض') ||
        str.contains('خط طول') ||
        str.contains('°') ||
        RegExp(r'^\d+(\.\d+)?$').hasMatch(str);
  }
}
