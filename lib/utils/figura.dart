import 'dart:ui';

enum Forma { linha, quadradro, circulo, triangulo }

class Figura {
  Figura(this.pontos, this.forma);

  List<Offset> pontos;
  Forma forma;
}
