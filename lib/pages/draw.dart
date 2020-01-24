import 'package:cg_tools/utils/appstyle.dart';
import 'package:cg_tools/utils/figura.dart';
import 'package:cg_tools/utils/magicalpaint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

enum opcoes { undo, redo, opcao3 }

class DrawPage extends StatefulWidget {
  @override
  _DrawPageState createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  List<Offset> _points = <Offset>[];
  List<Figura> objetos = <Figura>[];
  List<Figura> futuro = <Figura>[];
  Forma formaSelecionada = Forma.linha;
  List<Offset> _localPosition = <Offset>[];
  LocalKey sizedBoxKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyle.primary,
        title: Center(
          child: Text('CG tools'),
        ),
        actions: <Widget>[
          PopupMenuButton<opcoes>(
            onSelected: (opcoes result) {
              if (result == opcoes.undo && objetos.isNotEmpty) {
                setState(() {
                  futuro.add(objetos.removeLast());
                });
              } else if (result == opcoes.redo && futuro.isNotEmpty) {
                setState(() {
                  objetos.add(futuro.removeLast());
                });
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<opcoes>>[
              const PopupMenuItem<opcoes>(
                value: opcoes.undo,
                child: Text('Desfazer'),
              ),
              const PopupMenuItem<opcoes>(
                value: opcoes.redo,
                child: Text('Refazer'),
              ),
              const PopupMenuItem<opcoes>(
                value: opcoes.opcao3,
                child: Text('Opcao 3'),
              ),
            ],
          )
        ],
      ),
      floatingActionButton: SpeedDial(
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        closeManually: false,
        overlayOpacity: 0.5,
        animatedIcon: AnimatedIcons.menu_arrow,
        animatedIconTheme: IconThemeData(size: 22.0),
        tooltip: 'Speed Dial',
        heroTag: 'speed-dial-hero-tag',
        shape: CircleBorder(),
        backgroundColor: AppStyle.primary,
        children: [
          SpeedDialChild(
            backgroundColor: AppStyle.triadic1,
            child: Icon(MdiIcons.minus),
            onTap: () => formaSelecionada = Forma.linha,
          ),
          SpeedDialChild(
            backgroundColor: AppStyle.triadic1,
            child: Icon(MdiIcons.triangleOutline),
            onTap: () => formaSelecionada = Forma.triangulo,
          ),
          SpeedDialChild(
            backgroundColor: AppStyle.triadic1,
            child: Icon(MdiIcons.squareOutline),
            onTap: () => formaSelecionada = Forma.quadradro,
          ),
          SpeedDialChild(
            backgroundColor: AppStyle.triadic1,
            child: Icon(MdiIcons.circleOutline),
            onTap: () => formaSelecionada = Forma.circulo,
          ),
          SpeedDialChild(
            backgroundColor: AppStyle.triadic1,
            child: Icon(Icons.remove_circle_outline),
            onTap: () => objetos.clear(),
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
          ),
        ),
        child: Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          child: GestureDetector(
            onTapDown: (TapDownDetails details) {
              RenderBox object = context.findRenderObject();
              Offset coordenadas = object.localToGlobal(details.localPosition);
              _localPosition.add(coordenadas);
              _points = List.from(_points)..add(coordenadas);
              if (formaSelecionada == Forma.linha &&
                  _localPosition.length == 2) {
                setState(() {
                  objetos.add(
                    Figura(_localPosition, Forma.linha),
                  );
                  _localPosition = [];
                });
              }

              if (formaSelecionada == Forma.quadradro &&
                  _localPosition.length == 2) {
                setState(() {
                  objetos.add(
                    Figura(_localPosition, Forma.quadradro),
                  );
                  _localPosition = [];
                  futuro.clear();
                });
              }

              if (formaSelecionada == Forma.triangulo &&
                  _localPosition.length == 3) {
                setState(() {
                  objetos.add(
                    Figura(_localPosition, Forma.triangulo),
                  );
                  _localPosition = [];
                  futuro.clear();
                });
              }

              if (formaSelecionada == Forma.circulo &&
                  _localPosition.length == 2) {
                setState(() {
                  objetos.add(
                    Figura(_localPosition, Forma.circulo),
                  );
                  _localPosition = [];
                  futuro.clear();
                });
              }
            },
            child: CustomPaint(
              isComplex: false,
              painter: MagicalPaint(figuras: objetos),
              size: MediaQuery.of(context).size,
            ),
          ),
        ),
      ),
    );
  }
}
