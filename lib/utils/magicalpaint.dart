import 'dart:math';
import 'package:cg_tools/utils/figura.dart';
import 'package:flutter/material.dart';

class MagicalPaint extends CustomPainter {
  List<Figura> figuras;
  MagicalPaint({this.figuras});

  @override
  void paint(Canvas canvas, Size size) {
    // Paint para alocar eixos
    Paint axisPaint = new Paint()
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..color = Colors.grey
      ..style = PaintingStyle.fill;

    canvas.drawLine(Offset(0, 2), Offset(50, 2), axisPaint);
    canvas.drawLine(Offset(2, 0), Offset(2, 50), axisPaint);
    Path xPath = Path();
    xPath.moveTo(50, 2);
    xPath.lineTo(50, 6);
    xPath.lineTo(56, 2);
    xPath.lineTo(50, 0);
    xPath.close();
    canvas.drawPath(xPath, axisPaint);

    Path yPath = Path();
    yPath.moveTo(2, 50);
    yPath.lineTo(6, 50);
    yPath.lineTo(2, 56);
    yPath.lineTo(0, 50);
    yPath.close();
    canvas.drawPath(yPath, axisPaint);

    TextSpan eixoX = TextSpan(
      style: TextStyle(
        color: Colors.grey,
        fontSize: 10,
      ),
      text: 'X',
    );
    TextPainter tp = TextPainter(
      text: eixoX,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(42, 4));

    TextSpan eixoY = TextSpan(
      style: TextStyle(
        color: Colors.grey,
        fontSize: 10,
      ),
      text: 'Y',
    );
    TextPainter tp2 = TextPainter(
      text: eixoY,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    tp2.layout();
    tp2.paint(canvas, Offset(4, 42));

    TextSpan zerinho = TextSpan(
      style: TextStyle(
        color: Colors.grey,
        fontSize: 10,
      ),
      text: '0',
    );
    TextPainter origem = TextPainter(
      text: zerinho,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    origem.layout();
    origem.paint(canvas, Offset(4, 4));

    // Paint para desenhar figuras
    Paint paint = new Paint()
      ..strokeWidth = 3.0
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
        canvas.drawLine(figuras[i].pontos[0], figuras[i].pontos[2], paint);
        canvas.drawLine(figuras[i].pontos[2], figuras[i].pontos[1], paint);
        canvas.drawLine(figuras[i].pontos[1], figuras[i].pontos[3], paint);
        canvas.drawLine(figuras[i].pontos[3], figuras[i].pontos[0], paint);
      }

      if (figuras[i].forma == Forma.triangulo) {
        canvas.drawLine(figuras[i].pontos[0], figuras[i].pontos[1], paint);
        canvas.drawLine(figuras[i].pontos[1], figuras[i].pontos[2], paint);
        canvas.drawLine(figuras[i].pontos[2], figuras[i].pontos[0], paint);
      }
      if (figuras[i].forma == Forma.circulo) {
        double delta =
            pow(figuras[i].pontos[1].dx - figuras[i].pontos[0].dx, 2) +
                pow(figuras[i].pontos[1].dy - figuras[i].pontos[0].dy, 2);
        double raio = sqrt(delta.abs());

        if (figuras[i].pontos.length == 6) figuras[i].pontos.removeAt(1);

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
