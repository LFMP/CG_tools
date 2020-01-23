import 'package:cg_tools/utils/appstyle.dart';
import 'package:cg_tools/utils/figura.dart';
import 'package:cg_tools/utils/magicalpaint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

enum opcoes { opcao1, opcao2, opcao3 }

class DrawPage extends StatefulWidget {
  @override
  _DrawPageState createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  List<Offset> _points = <Offset>[];
  List<Figura> objetos = <Figura>[];
  Forma formaSelecionada = Forma.linha;
  List<Offset> _localPosition = <Offset>[];

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
              print(result);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<opcoes>>[
              const PopupMenuItem<opcoes>(
                value: opcoes.opcao1,
                child: Text('Opcao 1'),
              ),
              const PopupMenuItem<opcoes>(
                value: opcoes.opcao2,
                child: Text('Opcao 2'),
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
            child: Icon(
              MdiIcons.minus,
              color: AppStyle.white,
            ),
          ),
          SpeedDialChild(
            backgroundColor: AppStyle.triadic1,
            child: Icon(
              MdiIcons.triangleOutline,
              color: AppStyle.white,
            ),
          ),
          SpeedDialChild(
            backgroundColor: AppStyle.triadic1,
            child: Icon(
              MdiIcons.squareOutline,
              color: AppStyle.white,
            ),
          ),
          SpeedDialChild(
            backgroundColor: AppStyle.triadic1,
            child: Icon(
              MdiIcons.circleOutline,
              color: AppStyle.white,
            ),
          ),
          SpeedDialChild(
            backgroundColor: AppStyle.triadic1,
            child: IconButton(
              icon: Icon(Icons.remove_circle_outline),
              color: AppStyle.white,
              onPressed: () => objetos.clear(),
            ),
          ),
        ],
      ),
      body: Container(
        height: 700,
        width: 400,
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
          ),
        ),
        child: SizedBox.expand(
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
            },
            onTapCancel: () => objetos.add(null),
            child: CustomPaint(
              painter: MagicalPaint(figuras: objetos),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }
}
