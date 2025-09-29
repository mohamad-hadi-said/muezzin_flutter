import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:muezzin_flutter/src/model/prayer_times_models.dart';

part 'home_state.freezed.dart';

@freezed
abstract class HomeState with _$HomeState {
  factory HomeState({
    @Default(false) bool loading,
    @Default(false) bool error,
    String? errorMessage,
    List<PrayerTimesData>? prayerTimes,
    DateTime? dateTime,
  }) = _HomeState;

}
