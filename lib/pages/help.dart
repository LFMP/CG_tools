import 'package:flutter/material.dart';

Widget ajudaContexto() {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(),
    ),
    child: ListView(
      children: <Widget>[
        ExpansionTile(
          title: Text('Desenhar formas'),
        ),
        ExpansionTile(
          title: Text('Selecionar objetos'),
        ),
        ExpansionTile(
          title: Text('Operacoes'),
        ),
        ExpansionTile(
          title: Text('Linha de comando'),
        ),
      ],
    ),
  );
}
