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
      if (figuras[i] != null && figuras[i].forma == Forma.linha) {
        canvas.drawLine(figuras[i].pontos[0], figuras[i].pontos[1], paint);
        desenhou = true;
      } else if (figuras[i] != null && figuras[i].forma == Forma.quadradro) {
        canvas.drawRect(
            Rect.fromPoints(figuras[i].pontos[0], figuras[i].pontos[1]), paint);
      }
      if (figuras[i] != null && figuras[i].forma == Forma.triangulo) {
        canvas.drawLine(figuras[i].pontos[0], figuras[i].pontos[1], paint);
        canvas.drawLine(figuras[i].pontos[1], figuras[i].pontos[2], paint);
        canvas.drawLine(figuras[i].pontos[2], figuras[i].pontos[0], paint);
        desenhou = true;
      }
    }
  }

  @override
  bool shouldRepaint(MagicalPaint oldDelegate) => true;
}
