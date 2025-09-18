import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:muezzin_flutter/src/logic/muezzin/muezzin_state.dart';
import 'package:muezzin_flutter/src/model/azkar_model.dart';

part 'muezzin_event.dart';


class MuezzinBloc extends Bloc<MuezzinEvent, MuezzinState> {
  MuezzinBloc() : super(MuezzinState()) {
    on<LoadMuezzin>(_onLoadMuezzin);
  }

  Future<void> _onLoadMuezzin(LoadMuezzin event, Emitter<MuezzinState> emit) async {
    emit(state.copyWith(loading: true, error: false));
  }


}
