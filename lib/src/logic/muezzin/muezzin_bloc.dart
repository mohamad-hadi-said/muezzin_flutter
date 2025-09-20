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
      },
    );
  }
}
