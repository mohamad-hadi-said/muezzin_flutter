import 'package:muezzin_flutter/src/logic/home/home_state.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'home_event.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeState()) {
    on<LoadHome>(_onLoadHome);
  }

  Future<void> _onLoadHome(LoadHome event, Emitter<HomeState> emit) async {}
}
