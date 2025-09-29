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
    final month = DateTime.now().month;
    if(AppCache.instance.getMonthOfPrayerTimes() == month) {
      emit(
        state.copyWith(
          loading: false,
          error: false,
          prayerTimes: AppCache.instance.getPrayerTimes(),
          dateTime: DateTime.now(),
        ),
      );
      return;
    }
    final prayerTimes = await muezzinRepository.getPrayerTimesForMonth(
      year: DateTime.now().year,
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
          errorMessage: 'خطأ في تحميل الأذكار: ${l.message}',
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
        AppCache.instance.savePrayerTimes(data);
        // Schedule notifications for upcoming prayers this month
        NotificationService.cancelAllScheduled();
        NotificationService.scheduleToThisMonth(data);
      },
    );
  }
}
