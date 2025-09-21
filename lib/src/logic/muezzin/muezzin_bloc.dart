import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:muezzin_flutter/src/logic/muezzin/muezzin_state.dart';
import 'package:muezzin_flutter/injection_container.dart';
import 'package:muezzin_flutter/src/repositories/muezzin_repository_impl.dart';

part 'muezzin_event.dart';

class MuezzinBloc extends Bloc<MuezzinEvent, MuezzinState> {
  MuezzinBloc() : super(MuezzinState()) {
    on<LoadMuezzin>(_onLoadMuezzin);
  }

  final muezzinRepository = sl<MuezzinRepository>();

  String _formatDateDDMMYYYY(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    return '$dd-$mm-$yyyy';
  }

  Future<void> _onLoadMuezzin(
    LoadMuezzin event,
    Emitter<MuezzinState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: false));
    final prayerTimes = await muezzinRepository.getPrayerTimesByDate(
      date: _formatDateDDMMYYYY(DateTime.now()),
      latitude: 36.478616,
      longitude: 37.100935,
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
        emit(state.copyWith(
          loading: false,
          error: false,
          prayerTimes: data,
          dateTime: DateTime.now(),
        ));
        // After loading, compute next prayer
        calculateNextPrayerTime();
      },
    );
  }

  calculateNextPrayerTime() {
    final now = DateTime.now();
    final timings = state.prayerTimes?.timings;
    if (timings == null) return;

    DateTime? _parseLocal(String? iso) {
      if (iso == null) return null;
      try {
        return DateTime.parse(iso).toLocal();
      } catch (_) {
        return null;
      }
    }

    final ordered = <MapEntry<String, DateTime?>>[
      MapEntry('fajr', _parseLocal(timings.fajr)),
      MapEntry('sunrise', _parseLocal(timings.sunrise)),
      MapEntry('dhuhr', _parseLocal(timings.dhuhr)),
      MapEntry('asr', _parseLocal(timings.asr)),
      MapEntry('maghrib', _parseLocal(timings.maghrib ?? timings.sunset)),
      MapEntry('isha', _parseLocal(timings.isha)),
    ];

    // Pick first prayer time strictly after now
    MapEntry<String, DateTime?>? next;
    for (final e in ordered) {
      final dt = e.value;
      if (dt != null && dt.isAfter(now)) {
        next = e;
        break;
      }
    }

    // If all passed, assume next is tomorrow's Fajr using today's fajr time-of-day
    if (next == null) {
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
        next = MapEntry('fajr', tomorrowSameTime);
      }
    }

    if (next?.value != null) {
      final remaining = next!.value!.difference(now);
      emit(state.copyWith(
        nextPrayerKey: next.key,
        nextPrayerTime: next.value,
        timeUntilNext: remaining.isNegative ? Duration.zero : remaining,
      ));
    }
  }
}
