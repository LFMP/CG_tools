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
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10.0;

    for (int i = 0; i < figuras.length; i++) {
      if (figuras[i] != null && figuras[i].forma == Forma.linha) {
        canvas.drawLine(figuras[i].pontos[0], figuras[i].pontos[1], paint);
        desenhou = true;
      }
    }
  }

  @override
  bool shouldRepaint(MagicalPaint oldDelegate) => true;
}
