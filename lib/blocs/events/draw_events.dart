import 'package:equatable/equatable.dart';

abstract class DrawEvents extends Equatable {
  @override
  List<Object> get props => [];
}

class SelectModalButtonPressed extends DrawEvents {}

class ItemModalButtonPressed extends DrawEvents {}

class AjudaModalButtonPressed extends DrawEvents {}

class CanvasModalButtonPressed extends DrawEvents {}
