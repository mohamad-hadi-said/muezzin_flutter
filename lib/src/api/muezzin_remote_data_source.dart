import 'dart:developer' as dev;

import 'package:muezzin_flutter/core/errors/exceptions.dart';
import 'package:dio/dio.dart';
import 'package:muezzin_flutter/src/model/prayer_times_models.dart';

abstract class MuezzinRemoteDataSource {
  Future<PrayerTimesData> getPrayerTimesByDate({
    required String date, // e.g., '01-01-2025' or 'today'
    required double latitude,
    required double longitude,
    int method = 3, // Muslim World League by default
    String? timezone,
    bool iso8601 = false,
  });
}

class MuezzinRemoteDataSourceImpl implements MuezzinRemoteDataSource {
  final Dio _dio;

  MuezzinRemoteDataSourceImpl(this._dio);



  @override
  Future<PrayerTimesData> getPrayerTimesByDate({
    required String date,
    required double latitude,
    required double longitude,
    int method = 3,
    String? timezone,
    bool iso8601 = false,
  }) async {
    try {
      final response = await _dio.get(
        '/timings/$date',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': method,
          if (timezone != null) 'timezonestring': timezone,
          'iso8601': iso8601,
        },
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw ServerException('Unexpected response type');
      }

      final parsed = PrayerTimesResponse.fromJson(data);
      dev.log('Prayer times fetched with status: ${parsed.status}');
      return parsed.data!;
    } catch (e) {
      dev.log('Error fetching prayer times: $e');
      throw ServerException(e.toString());
    }
  }
}
