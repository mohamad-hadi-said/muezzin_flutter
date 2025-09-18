import 'package:muezzin_flutter/core/cache/app_cache.dart';
import 'package:muezzin_flutter/src/logic/home/home_state.dart';
import 'package:muezzin_flutter/src/repositories/quiz_repository_impl.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:muezzin_flutter/injection_container.dart';

part 'home_event.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState()) {
    on<LoadHome>(_onLoadHome);
  }

  final azkarRepository = sl<MuezzinRepository>();

  Future<void> _onLoadHome(LoadHome event, Emitter<HomeState> emit) async {
    emit(state.copyWith(loading: true, error: false));

    final azkar = await azkarRepository.getAllMuezzin();
    azkar.fold(
      (l) => emit(
        state.copyWith(
          loading: false,
          error: true,
          errorMessage: 'خطأ في تحميل الأذكار: ${l.message}',
        ),
      ),
      (r) {
        if (r.isEmpty) {
          AppCache.instance.saveMuezzin(r);
          emit(
            state.copyWith(
              loading: false,
              error: true,
              errorMessage: 'لا توجد أذكار متاحة',
            ),
          );
          return;
        }
        emit(
          state.copyWith(
            loading: false,
            error: false
          ),
        );
      },
    );
  }
}
