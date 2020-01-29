import 'package:cg_tools/utils/appstyle.dart';
import 'package:flutter/material.dart';

Widget ajudaContexto() {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(),
    ),
    child: ListView(
      padding: EdgeInsets.only(left: 8.0, right: 8.0),
      children: <Widget>[
        ExpansionTile(
          title: Text('Desenhar formas'),
          children: <Widget>[
            Text('Linha'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('aaaaaaaaaa'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Triangulo'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('aaaaaaaaaa'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Quadrado'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('aaaaaaaaaa'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Circulo'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('aaaaaaaaaa'),
          ],
        ),
        ExpansionTile(
          title: Text('Selecionar objetos'),
          children: <Widget>[
            Text('Selecionar todos'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('aaaaaaaaaa'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Selecao individual'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('aaaaaaaaaa'),
          ],
        ),
        ExpansionTile(
          title: Text('Operacoes'),
          children: <Widget>[
            Text('Rotacao 90 graus'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('aaaaaaaaaa'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Rotacao'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('aaaaaaaaaa'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Translacao'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('aaaaaaaaaa'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Mudanca de escala'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('aaaaaaaaaa'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Limpar tela'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('aaaaaaaaaa'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Desfazer'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('aaaaaaaaaa'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Refazer'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('aaaaaaaaaa'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('Excluir selecionados'),
            Divider(
              thickness: 2.0,
              color: AppStyle.primary,
            ),
            Text('aaaaaaaaaa'),
          ],
        ),
        ExpansionTile(
          title: Text('Linha de comando'),
        ),
      ],
    ),
  );
}
