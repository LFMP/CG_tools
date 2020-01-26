import 'dart:math';
import 'package:vector_math/vector_math.dart';
import 'package:cg_tools/utils/figura.dart';
import 'package:flutter/material.dart';

class MagicalPaint extends CustomPainter {
  List<Figura> figuras;
  MagicalPaint({this.figuras});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < figuras.length; i++) {
      if (figuras[i].selected) {
        paint.color = Colors.red;
      } else {
        paint.color = Colors.black;
      }
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
        double delta = pow(figuras[i].pontos[0].dx - figuras[i].pontos[1].dx, 2) -
                pow(figuras[i].pontos[0].dy - figuras[i].pontos[1].dy, 2);
        double raio = delta < 0 ? sqrt(-delta) : sqrt(delta);
        canvas.drawCircle(figuras[i].pontos[0], raio, paint);
      }
    }
  }

  @override
  bool hitTest(Offset position) {
    return super.hitTest(position);
  }

  @override
  bool shouldRepaint(MagicalPaint oldDelegate) => true;
}
