import 'dart:math';

import 'package:cg_tools/utils/figura.dart';
import 'package:flutter/material.dart';

class MagicalPaint extends CustomPainter {
  List<Figura> figuras;
  MagicalPaint({this.figuras});

  bool desenhou = false;
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.black
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < figuras.length; i++) {
      if (figuras[i].forma == Forma.linha) {
        canvas.drawLine(figuras[i].pontos[0], figuras[i].pontos[1], paint);
      }

      if (figuras[i].forma == Forma.quadradro) {
        canvas.drawRect(
            Rect.fromPoints(figuras[i].pontos[0], figuras[i].pontos[1]), paint);
      }

      if (figuras[i].forma == Forma.triangulo) {
        canvas.drawLine(figuras[i].pontos[0], figuras[i].pontos[1], paint);
        canvas.drawLine(figuras[i].pontos[1], figuras[i].pontos[2], paint);
        canvas.drawLine(figuras[i].pontos[2], figuras[i].pontos[0], paint);
      }
      if (figuras[i].forma == Forma.circulo) {
        double raio = sqrt(
            pow(figuras[i].pontos[0].dx - figuras[i].pontos[1].dx, 2) -
                pow(figuras[i].pontos[0].dy - figuras[i].pontos[1].dy, 2));
        canvas.drawCircle(figuras[i].pontos[0], raio, paint);
      }
    }
  }

  @override
  bool shouldRepaint(MagicalPaint oldDelegate) => true;
}
