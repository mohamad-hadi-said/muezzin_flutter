import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:muezzin_flutter/core/cache/app_cache.dart';
import 'package:muezzin_flutter/core/services/notification_service.dart';
import 'package:muezzin_flutter/injection_container.dart';
import 'package:muezzin_flutter/src/logic/muezzin/muezzin_state.dart';
import 'package:muezzin_flutter/src/model/prayer_times_models.dart';
import 'package:muezzin_flutter/src/repositories/muezzin_repository_impl.dart';

part 'muezzin_event.dart';

class MuezzinBloc extends Bloc<MuezzinEvent, MuezzinState> {
  MuezzinBloc() : super(MuezzinState()) {
    on<LoadMuezzin>(_onLoadMuezzin);
  }

  final muezzinRepository = sl<MuezzinRepository>();

  Future<void> _onLoadMuezzin(
    LoadMuezzin event,
    Emitter<MuezzinState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: false));

    var prayerTimes = getPrayerTimesForToday();

    // If cache is empty, fetch from repository as fallback
    if (prayerTimes == null) {
      final userLocation = AppCache.instance.getUserLocation();
      final latitude = userLocation?.latitude ?? 36.478616;
      final longitude = userLocation?.longitude ?? 37.100935;
      final now = DateTime.now();

      final result = await muezzinRepository.getPrayerTimesForMonth(
        year: now.year,
        month: now.month,
        latitude: latitude,
        longitude: longitude,
        iso8601: true,
      );

      result.fold(
        (l) {
          emit(
            state.copyWith(
              loading: false,
              error: true,
              errorMessage: 'خطأ في تحميل مواقيت الصلاة: ${l.message}',
            ),
          );
        },
        (data) {
          AppCache.instance.saveMonthOfPrayerTimes(now.month);
          AppCache.instance.saveYearOfPrayerTimes(now.year);
          AppCache.instance.savePrayerTimes(data);
          unawaited(NotificationService.scheduleUpcomingPrayers(data));
          prayerTimes = getPrayerTimesForToday();
        },
      );
    }

    if (prayerTimes == null) {
      emit(
        state.copyWith(
          loading: false,
          error: true,
          errorMessage: 'خطأ في تحميل مواقيت الصلاة: لا توجد بيانات متاحة',
        ),
      );
      return;
    }

    final nextPrayerInfo = _computeNextPrayer(prayerTimes!);
    Duration? timeUntilNext;
    if (nextPrayerInfo != null) {
      final diff = nextPrayerInfo.value.difference(DateTime.now());
      timeUntilNext = diff.isNegative ? Duration.zero : diff;
    }

    emit(
      state.copyWith(
        loading: false,
        error: false,
        prayerTimes: prayerTimes,
        dateTime: DateTime.now(),
        nextPrayerKey: nextPrayerInfo?.key,
        nextPrayerTime: nextPrayerInfo?.value,
        timeUntilNext: timeUntilNext,
      ),
    );
  }

  PrayerTimesData? getPrayerTimesForToday() {
    final prayerTimesForThisMonth = AppCache.instance.getPrayerTimes();

    if (prayerTimesForThisMonth.isEmpty) {
      return null;
    }

    final now = DateTime.now();
    for (final element in prayerTimesForThisMonth) {
      final dayStr = element.date?.gregorian?.day;
      if (dayStr == null) continue;
      final dayNum = int.tryParse(dayStr.trim());
      if (dayNum == now.day) {
        return element;
      }
    }

    return null;
  }

  MapEntry<String, DateTime>? _computeNextPrayer(PrayerTimesData data) {
    final now = DateTime.now();
    final timings = data.timings;
    if (timings == null) return null;

    DateTime? parseLocal(String? iso) {
      if (iso == null) return null;
      try {
        return DateTime.parse(iso).toLocal();
      } catch (_) {
        return null;
      }
    }

    final ordered = <MapEntry<String, DateTime?>>[
      MapEntry('fajr', parseLocal(timings.fajr)),
      MapEntry('sunrise', parseLocal(timings.sunrise)),
      MapEntry('dhuhr', parseLocal(timings.dhuhr)),
      MapEntry('asr', parseLocal(timings.asr)),
      MapEntry('maghrib', parseLocal(timings.maghrib ?? timings.sunset)),
      MapEntry('isha', parseLocal(timings.isha)),
    ];

    // Pick first prayer time strictly after now
    for (final e in ordered) {
      final dt = e.value;
      if (dt != null && dt.isAfter(now)) {
        return MapEntry(e.key, dt);
      }
    }

    // If all passed, assume next is tomorrow's Fajr
    final fajr = ordered.first.value;
    if (fajr != null) {
      final tomorrowSameTime = DateTime(
        now.year,
        now.month,
        now.day,
        fajr.hour,
        fajr.minute,
        fajr.second,
        fajr.millisecond,
        fajr.microsecond,
      ).add(const Duration(days: 1));
      return MapEntry('fajr', tomorrowSameTime);
    }

    return null;
  }
}
