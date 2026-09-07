import 'dart:async';
import 'package:muezzin_flutter/core/cache/app_cache.dart';
import 'package:muezzin_flutter/injection_container.dart';
import 'package:muezzin_flutter/src/logic/home/home_state.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:muezzin_flutter/src/repositories/muezzin_repository_impl.dart';
import 'package:muezzin_flutter/core/services/notification_service.dart';

part 'home_event.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState()) {
    on<LoadHome>(_onLoadHome);
  }

  final muezzinRepository = sl<MuezzinRepository>();

  Future<void> _onLoadHome(LoadHome event, Emitter<HomeState> emit) async {
    emit(state.copyWith(loading: true, error: false));
    final userLocation = AppCache.instance.getUserLocation();
    final latitude = userLocation?.latitude ?? 36.478616;
    final longitude = userLocation?.longitude ?? 37.100935;
    final now = DateTime.now();
    final month = now.month;
    final year = now.year;

    if (AppCache.instance.getMonthOfPrayerTimes() == month &&
        AppCache.instance.getYearOfPrayerTimes() == year) {
      final cachedTimes = AppCache.instance.getPrayerTimes();
      if (cachedTimes.isNotEmpty) {
        emit(
          state.copyWith(
            loading: false,
            error: false,
            prayerTimes: cachedTimes,
            dateTime: now,
          ),
        );
        // Refresh upcoming prayer notifications smoothly in the background
        unawaited(NotificationService.scheduleUpcomingPrayers(cachedTimes));
        return;
      }
    }

    final prayerTimes = await muezzinRepository.getPrayerTimesForMonth(
      year: year,
      month: month,
      latitude: latitude,
      longitude: longitude,
      iso8601: true,
    );
    prayerTimes.fold(
      (l) => emit(
        state.copyWith(
          loading: false,
          error: true,
          errorMessage: 'خطأ في تحميل مواقيت الصلاة: ${l.message}',
        ),
      ),
      (data) {
        emit(
          state.copyWith(
            loading: false,
            error: false,
            prayerTimes: data,
            dateTime: DateTime.now(),
          ),
        );
        AppCache.instance.saveMonthOfPrayerTimes(month);
        AppCache.instance.saveYearOfPrayerTimes(year);
        AppCache.instance.savePrayerTimes(data);
        // Schedule notifications for upcoming prayers (next 2-3 days) safely
        unawaited(NotificationService.scheduleUpcomingPrayers(data));
      },
    );
  }
}
