import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:muezzin_flutter/src/model/prayer_times_models.dart';

part 'muezzin_state.freezed.dart';

@freezed
abstract class MuezzinState with _$MuezzinState {
  factory MuezzinState({
    @Default(false) bool loading,
    @Default(false) bool error,
    String? errorMessage,
    PrayerTimesData? prayerTimes,
    DateTime? dateTime,
  }) = _MuezzinState;

}
