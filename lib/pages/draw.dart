import 'package:cg_tools/utils/appstyle.dart';
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
        elevation: 8.0,
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
              onPressed: () => _points.clear(),
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
              setState(() {
                RenderBox object = context.findRenderObject();
                Offset _localPosition = object.localToGlobal(details.localPosition);
                    //object.globalToLocal(details.globalPosition);
                _points = List.from(_points)..add(_localPosition);
              });
              print(_points);
            },
            onTapCancel: () => _points.add(null),
            child: CustomPaint(
              painter: MagicalPaint(points: _points),
              size: Size.infinite,
            ),
          ),
        ),
      ),
    );
  }
}
