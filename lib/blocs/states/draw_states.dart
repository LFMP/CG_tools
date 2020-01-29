import 'package:equatable/equatable.dart';

abstract class DrawStates extends Equatable {
  const DrawStates();

  @override
  List<Object> get props => [];
}

class ModalUnpressed extends DrawStates {}

class ModalLoading extends DrawStates {}

class ModalLoaded extends DrawStates {}

class ItemModalSelected extends DrawStates {}

class AjudaSelecionada extends DrawStates {}

class AjudaNaoSelecionada extends DrawStates {}
