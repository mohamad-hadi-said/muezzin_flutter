part of 'muezzin_bloc.dart';

abstract class MuezzinEvent extends Equatable {
  const MuezzinEvent();

  @override
  List<Object> get props => [];
}

class LoadMuezzin extends MuezzinEvent {
  const LoadMuezzin();
}