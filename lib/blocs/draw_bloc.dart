import 'package:bloc/bloc.dart';
import 'package:cg_tools/blocs/events/draw_events.dart';
import 'package:cg_tools/blocs/states/draw_states.dart';

class DrawBloc extends Bloc<DrawEvents, DrawStates> {
  @override
  DrawStates get initialState => ModalUnpressed();

  @override
  Stream<DrawStates> mapEventToState(
    DrawEvents event,
  ) async* {
    if (event is SelectModalButtonPressed) {
      yield ModalLoaded();
    }

    if (event is ItemModalButtonPressed) {
      yield ModalLoading();
      yield ItemModalSelected();
    }
  }
}
