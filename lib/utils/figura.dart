import 'dart:ui';

enum Forma { linha, quadradro, circulo, triangulo }

class Figura {
  Figura(this.pontos, this.forma, this.selected);

  List<Offset> pontos;
  Forma forma;
  bool selected;
}
