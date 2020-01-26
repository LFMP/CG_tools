import 'dart:math';

import 'package:cg_tools/blocs/draw_bloc.dart';
import 'package:cg_tools/blocs/events/draw_events.dart';
import 'package:cg_tools/blocs/states/draw_states.dart';
import 'package:cg_tools/utils/appstyle.dart';
import 'package:cg_tools/utils/figura.dart';
import 'package:cg_tools/utils/magicalpaint.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:vector_math/vector_math_64.dart' as math;
import 'package:vibration/vibration.dart';

enum opcoes { undo, redo, clear, selectAll }

class DrawPage extends StatefulWidget {
  @override
  _DrawPageState createState() => _DrawPageState();
}

class _DrawPageState extends State<DrawPage> {
  final commandController = TextEditingController();
  final rotateController = TextEditingController();
  final scaleXController = TextEditingController();
  final scaleYController = TextEditingController();
  List<Offset> _points = <Offset>[];
  List<Offset> zoomClickArea = <Offset>[];
  List<Offset> _localPosition = <Offset>[];
  List<Figura> objetos = <Figura>[];
  List<Figura> futuro = <Figura>[];
  List<double> viewport = <double>[];
  Forma formaSelecionada = Forma.linha;
  bool _clearSelected = false;

  void getLimites() {
    // viewport[0] = Xmin
    // viewport[1] = Ymin
    // viewport[2] = Xmax
    // viewport[3] = Ymax
    double delta;
    double raio;
    if (objetos[0].pontos[0].dx > objetos[0].pontos[1].dx) {
      viewport[0] = objetos[0].pontos[1].dx;
      viewport[2] = objetos[0].pontos[0].dx;
    } else {
      viewport[2] = objetos[0].pontos[1].dx;
      viewport[0] = objetos[0].pontos[0].dx;
    }
    if (objetos[0].pontos[0].dy > objetos[0].pontos[1].dy) {
      viewport[1] = objetos[0].pontos[1].dy;
      viewport[3] = objetos[0].pontos[0].dy;
    } else {
      viewport[3] = objetos[0].pontos[1].dy;
      viewport[1] = objetos[0].pontos[0].dy;
    }
    objetos.forEach(
      (Figura f) => {
        if (f.forma == Forma.linha ||
            f.forma == Forma.triangulo ||
            f.forma == Forma.quadradro)
          {
            f.pontos.forEach(
              (Offset coordinate) => {
                if (coordinate.dx < viewport[0])
                  {viewport[0] = coordinate.dx}
                else if (coordinate.dx > viewport[2])
                  {viewport[2] = coordinate.dx},
                if (coordinate.dy < viewport[1])
                  {viewport[1] = coordinate.dy}
                else if (coordinate.dy > viewport[3])
                  {viewport[3] = coordinate.dy},
              },
            ),
          },
        if (f.forma == Forma.circulo)
          {
            delta = pow(f.pontos[0].dx - f.pontos[1].dx, 2) -
                pow(f.pontos[0].dy - f.pontos[1].dy, 2),
            raio = delta < 0 ? sqrt(-delta) : sqrt(delta),
          },
      },
    );
  }

  void _selectModalSheet(BuildContext ancestralContext, List<Figura> objetos) {
    objetos.isEmpty
        ? showDialog<void>(
            context: ancestralContext,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Ops!'),
                content: Text('Voce ainda nao inseriu elementos na tela'),
                actions: <Widget>[
                  FlatButton(
                    child: const Text('Ok'),
                    onPressed: () {
                      print(rotateController.text);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          )
        : showModalBottomSheet(
            context: ancestralContext,
            builder: (ancestralContext) {
              return BlocBuilder<DrawBloc, DrawStates>(
                builder: (context, state) {
                  if (state is ModalLoading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (state is ModalLoaded) {
                    return ListView.builder(
                      itemCount: objetos.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(
                            objetos[index].forma.toString(),
                          ),
                          subtitle: Text(
                            objetos[index].pontos.toString(),
                          ),
                          trailing: Checkbox(
                            value: objetos[index].selected,
                            onChanged: (bool value) => {
                              setState(() {
                                objetos[index].selected = value;
                              }),
                            },
                          ),
                          onTap: () => {
                            BlocProvider.of<DrawBloc>(context)
                                .add(ItemModalButtonPressed()),
                            setState(() {
                              objetos[index].selected =
                                  !objetos[index].selected;
                            }),
                          },
                        );
                      },
                    );
                  }

                  if (state is ItemModalSelected) {
                    return ListView.builder(
                      itemCount: objetos.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(
                            objetos[index].forma.toString(),
                          ),
                          subtitle: Text(
                            objetos[index].pontos.toString(),
                          ),
                          trailing: Checkbox(
                            value: objetos[index].selected,
                            onChanged: (bool value) => {
                              setState(() {
                                objetos[index].selected = value;
                              }),
                            },
                          ),
                          onTap: () => {
                            BlocProvider.of<DrawBloc>(context)
                                .add(ItemModalButtonPressed()),
                            setState(
                              () {
                                objetos[index].selected =
                                    !objetos[index].selected;
                              },
                            ),
                          },
                        );
                      },
                    );
                  }
                  return null;
                },
              );
            },
          );
  }

  void _deleteSelected() {
    futuro.clear();
    futuro.addAll(objetos.where((Figura f) => f.selected == true));
    objetos.removeWhere((Figura f) => f.selected == true);
  }

  void _rotate(double degrees) {
    final double cosseno = cos(math.radians(degrees));
    final double seno = sin(math.radians(degrees));
    math.Matrix3 resultLine;
    math.Matrix4 resultLineSquare;
    objetos.where((Figura fig) => fig.selected == true).forEach(
          (Figura f) => {
            if (f.forma == Forma.linha || f.forma == Forma.circulo)
              {
                resultLine = math.Matrix3.columns(
                  math.Vector3(cosseno, seno, 0),
                  math.Vector3(-seno, cosseno, 0),
                  math.Vector3(
                    (f.pontos[0].dy * seno) -
                        (f.pontos[0].dx * cosseno) +
                        f.pontos[0].dx,
                    -(f.pontos[0].dx * seno) -
                        (f.pontos[0].dy * cosseno) +
                        f.pontos[0].dy,
                    1,
                  ),
                ),
                resultLine.multiply(
                  math.Matrix3.columns(
                    math.Vector3(f.pontos[0].dx, f.pontos[0].dy, 1),
                    math.Vector3(f.pontos[1].dx, f.pontos[1].dy, 1),
                    math.Vector3(0, 0, 0),
                  ),
                ),
                f.pontos[0] = Offset(
                  resultLine.getColumn(0)[0],
                  resultLine.getColumn(0)[1],
                ),
                f.pontos[1] = Offset(
                  resultLine.getColumn(1)[0],
                  resultLine.getColumn(1)[1],
                ),
              },
            if (f.forma == Forma.triangulo)
              {
                resultLine = math.Matrix3.columns(
                  math.Vector3(cosseno, seno, 0),
                  math.Vector3(-seno, cosseno, 0),
                  math.Vector3(
                    (f.pontos[0].dy * seno) -
                        (f.pontos[0].dx * cosseno) +
                        f.pontos[0].dx,
                    -(f.pontos[0].dx * seno) -
                        (f.pontos[0].dy * cosseno) +
                        f.pontos[0].dy,
                    1,
                  ),
                ),
                resultLine.multiply(
                  math.Matrix3.columns(
                    math.Vector3(f.pontos[0].dx, f.pontos[0].dy, 1),
                    math.Vector3(f.pontos[1].dx, f.pontos[1].dy, 1),
                    math.Vector3(f.pontos[2].dx, f.pontos[2].dy, 1),
                  ),
                ),
                f.pontos[0] = Offset(
                  resultLine.getColumn(0)[0],
                  resultLine.getColumn(0)[1],
                ),
                f.pontos[1] = Offset(
                  resultLine.getColumn(1)[0],
                  resultLine.getColumn(1)[1],
                ),
                f.pontos[2] = Offset(
                  resultLine.getColumn(2)[0],
                  resultLine.getColumn(2)[1],
                ),
              },
            if (f.forma == Forma.quadradro)
              {
                resultLineSquare = math.Matrix4.columns(
                  math.Vector4(cosseno, seno, 0, 0),
                  math.Vector4(-seno, cosseno, 0, 0),
                  math.Vector4(
                      (f.pontos[0].dy * seno) -
                          (f.pontos[0].dx * cosseno) +
                          f.pontos[0].dx,
                      -(f.pontos[0].dx * seno) -
                          (f.pontos[0].dy * cosseno) +
                          f.pontos[0].dy,
                      1,
                      0),
                  math.Vector4(0, 0, 0, 0),
                ),
                resultLineSquare.multiply(
                  math.Matrix4.columns(
                    math.Vector4(f.pontos[0].dx, f.pontos[0].dy, 1, 0),
                    math.Vector4(f.pontos[1].dx, f.pontos[1].dy, 1, 0),
                    math.Vector4(f.pontos[2].dx, f.pontos[2].dy, 1, 0),
                    math.Vector4(f.pontos[3].dx, f.pontos[3].dy, 1, 0),
                  ),
                ),
                f.pontos[0] = Offset(
                  resultLineSquare.getColumn(0)[0],
                  resultLineSquare.getColumn(0)[1],
                ),
                f.pontos[1] = Offset(
                  resultLineSquare.getColumn(1)[0],
                  resultLineSquare.getColumn(1)[1],
                ),
                f.pontos[2] = Offset(
                  resultLineSquare.getColumn(2)[0],
                  resultLineSquare.getColumn(2)[1],
                ),
                f.pontos[3] = Offset(
                  resultLineSquare.getColumn(3)[0],
                  resultLineSquare.getColumn(3)[1],
                ),
              },
          },
        );
  }

  void _translate(double x, double y) {
    math.Matrix3 resultLine;
    math.Matrix4 resultLineSquare;
    objetos.where((Figura fig) => fig.selected == true).forEach(
          (Figura f) => {
            if (f.forma == Forma.linha || f.forma == Forma.circulo)
              {
                resultLine = math.Matrix3.columns(
                  math.Vector3(1, 0, 0),
                  math.Vector3(0, 1, 0),
                  math.Vector3((x - f.pontos[0].dx), (y - f.pontos[0].dy), 1),
                ),
                resultLine.multiply(
                  math.Matrix3.columns(
                    math.Vector3(f.pontos[0].dx, f.pontos[0].dy, 1),
                    math.Vector3(f.pontos[1].dx, f.pontos[1].dy, 1),
                    math.Vector3(0, 0, 0),
                  ),
                ),
                f.pontos[0] = Offset(
                  resultLine.getColumn(0)[0],
                  resultLine.getColumn(0)[1],
                ),
                f.pontos[1] = Offset(
                  resultLine.getColumn(1)[0],
                  resultLine.getColumn(1)[1],
                ),
              },
            if (f.forma == Forma.triangulo)
              {
                resultLine = math.Matrix3.columns(
                  math.Vector3(1, 0, 0),
                  math.Vector3(0, 1, 0),
                  math.Vector3((x - f.pontos[0].dx), (y - f.pontos[0].dy), 1),
                ),
                resultLine.multiply(
                  math.Matrix3.columns(
                    math.Vector3(f.pontos[0].dx, f.pontos[0].dy, 1),
                    math.Vector3(f.pontos[1].dx, f.pontos[1].dy, 1),
                    math.Vector3(f.pontos[2].dx, f.pontos[2].dy, 1),
                  ),
                ),
                f.pontos[0] = Offset(
                  resultLine.getColumn(0)[0],
                  resultLine.getColumn(0)[1],
                ),
                f.pontos[1] = Offset(
                  resultLine.getColumn(1)[0],
                  resultLine.getColumn(1)[1],
                ),
                f.pontos[2] = Offset(
                  resultLine.getColumn(2)[0],
                  resultLine.getColumn(2)[1],
                ),
              },
            if (f.forma == Forma.quadradro)
              {
                resultLineSquare = math.Matrix4.columns(
                  math.Vector4(1, 0, 0, 0),
                  math.Vector4(0, 1, 0, 0),
                  math.Vector4(
                      (x - f.pontos[0].dx), (y - f.pontos[0].dy), 1, 0),
                  math.Vector4(0, 0, 0, 0),
                ),
                resultLineSquare.multiply(
                  math.Matrix4.columns(
                    math.Vector4(f.pontos[0].dx, f.pontos[0].dy, 1, 0),
                    math.Vector4(f.pontos[1].dx, f.pontos[1].dy, 1, 0),
                    math.Vector4(f.pontos[2].dx, f.pontos[2].dy, 1, 0),
                    math.Vector4(f.pontos[3].dx, f.pontos[3].dy, 1, 0),
                  ),
                ),
                f.pontos[0] = Offset(
                  resultLineSquare.getColumn(0)[0],
                  resultLineSquare.getColumn(0)[1],
                ),
                f.pontos[1] = Offset(
                  resultLineSquare.getColumn(1)[0],
                  resultLineSquare.getColumn(1)[1],
                ),
                f.pontos[2] = Offset(
                  resultLineSquare.getColumn(2)[0],
                  resultLineSquare.getColumn(2)[1],
                ),
                f.pontos[3] = Offset(
                  resultLineSquare.getColumn(3)[0],
                  resultLineSquare.getColumn(3)[1],
                ),
              },
          },
        );
  }

  void _scale(double scaleX, double scaleY) {
    math.Matrix3 resultLine;
    objetos.where((Figura fig) => fig.selected == true).forEach(
          (Figura f) => {
            if (f.forma == Forma.linha ||
                f.forma == Forma.circulo ||
                f.forma == Forma.quadradro)
              {
                resultLine = math.Matrix3.columns(
                  math.Vector3(scaleX, 0, 0),
                  math.Vector3(0, scaleY, 0),
                  math.Vector3((f.pontos[0].dx - (f.pontos[0].dx * scaleX)),
                      (f.pontos[0].dy - (f.pontos[0].dy * scaleY)), 1),
                ),
                resultLine.multiply(
                  math.Matrix3.columns(
                    math.Vector3(f.pontos[0].dx, f.pontos[0].dy, 1),
                    math.Vector3(f.pontos[1].dx, f.pontos[1].dy, 1),
                    math.Vector3(0, 0, 0),
                  ),
                ),
                f.pontos[0] = Offset(
                  resultLine.getColumn(0)[0],
                  resultLine.getColumn(0)[1],
                ),
                f.pontos[1] = Offset(
                  resultLine.getColumn(1)[0],
                  resultLine.getColumn(1)[1],
                ),
              },
            if (f.forma == Forma.triangulo)
              {
                resultLine = math.Matrix3.columns(
                  math.Vector3(scaleX, 0, 0),
                  math.Vector3(0, scaleY, 0),
                  math.Vector3((f.pontos[0].dx - (f.pontos[0].dx * scaleX)),
                      (f.pontos[0].dy - (f.pontos[0].dy * scaleY)), 1),
                ),
                resultLine.multiply(
                  math.Matrix3.columns(
                    math.Vector3(f.pontos[0].dx, f.pontos[0].dy, 1),
                    math.Vector3(f.pontos[1].dx, f.pontos[1].dy, 1),
                    math.Vector3(f.pontos[2].dx, f.pontos[2].dy, 1),
                  ),
                ),
                f.pontos[0] = Offset(
                  resultLine.getColumn(0)[0],
                  resultLine.getColumn(0)[1],
                ),
                f.pontos[1] = Offset(
                  resultLine.getColumn(1)[0],
                  resultLine.getColumn(1)[1],
                ),
                f.pontos[2] = Offset(
                  resultLine.getColumn(2)[0],
                  resultLine.getColumn(2)[1],
                ),
              }
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppStyle.primary,
        centerTitle: true,
        title: Text('CG tools'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.zoom_in),
            onPressed: () => print('zooooooooooom'),
          ),
          IconButton(
            icon: Icon(Icons.select_all),
            color: AppStyle.white,
            onPressed: () {
              BlocProvider.of<DrawBloc>(context)
                  .add(SelectModalButtonPressed());
              _selectModalSheet(context, objetos);
            },
          ),
          PopupMenuButton<opcoes>(
            onSelected: (opcoes result) {
              if (result == opcoes.undo) {
                if (_clearSelected) {
                  setState(() {
                    objetos.addAll(futuro);
                    futuro.clear();
                    _clearSelected = false;
                  });
                } else if (objetos.isNotEmpty) {
                  setState(() {
                    futuro.add(objetos.removeLast());
                    _clearSelected = false;
                  });
                }
              } else if (result == opcoes.redo && futuro.isNotEmpty) {
                setState(() {
                  objetos.add(futuro.removeLast());
                });
              } else if (result == opcoes.clear) {
                setState(() {
                  futuro.addAll(objetos);
                  objetos.clear();
                  _clearSelected = true;
                });
              } else if (result == opcoes.selectAll) {
                setState(() {
                  futuro.clear();
                  futuro.addAll(objetos);
                  for (int i = 0; i < objetos.length; i++) {
                    objetos[i].selected = true;
                  }
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
                value: opcoes.clear,
                child: Text('Limpar tela'),
              ),
              const PopupMenuItem<opcoes>(
                value: opcoes.selectAll,
                child: Text('Selecionar tudo'),
              ),
            ],
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomAppBar(
        color: AppStyle.primary,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.rotate_90_degrees_ccw),
              color: AppStyle.white,
              onPressed: () => _rotate(90),
            ),
            IconButton(
              icon: Icon(Icons.rotate_right),
              color: AppStyle.white,
              onPressed: () => showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Digite quantos graus deseja rotacionar'),
                    content: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: rotateController,
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: const Text('Cancelar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: const Text('Confirmar'),
                        onPressed: () {
                          setState(() {});
                          _rotate(num.parse(rotateController.text).toDouble());
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right),
              color: AppStyle.white,
              onPressed: () => showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Informe a operação desejada'),
                    content: TextFormField(
                      decoration: InputDecoration(
                        hintText: 'operacao valor1 valor2'
                      )
                      keyboardType: TextInputType.text,
                      controller: commandController,
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: const Text('Cancelar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: const Text('Confirmar'),
                        onPressed: () {
                          setState(() {});
                          var string = commandController.toString(),
                          var splitted = string.split(" "),
                          if(splitted[0] == "rotate"){
                            _rotate(num.parse(splitted[1]).toDouble());
                            Navigator.of(context).pop();
                          }else if(splitted[0] == "translate"){
                            _translate(num.parse(splitted[1).toDouble, num.parse(splitted[2].toDouble));
                            Navigator.of(context).pop();
                          }else if(splitted[0] == "scale"){
                            _scale(num.parse(splitted[1).toDouble, num.parse(splitted[2].toDouble));
                            Navigator.of(context).pop();
                          }else{
                            return AlertDialog(
                              title: Text('Operacao não reconhecida')
                            ),
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            IconButton(
              icon: Icon(MdiIcons.arrowAll),
              color: AppStyle.white,
              onPressed: () => showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Digite o ponto para Translacao'),
                    content: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                width: 80,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'X',
                                    alignLabelWithHint: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  controller: scaleXController,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                width: 80,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Y',
                                    alignLabelWithHint: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  controller: scaleYController,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: const Text('Cancelar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: const Text('Confirmar'),
                        onPressed: () {
                          _translate(
                              num.parse(scaleXController.text).toDouble(),
                              num.parse(scaleYController.text).toDouble());
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.crop),
              color: AppStyle.white,
              onPressed: () => showDialog<void>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Digite a escala'),
                    content: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                width: 80,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'X',
                                    alignLabelWithHint: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  controller: scaleXController,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                width: 80,
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Y',
                                    alignLabelWithHint: true,
                                  ),
                                  keyboardType: TextInputType.number,
                                  controller: scaleYController,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: const Text('Cancelar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: const Text('Confirmar'),
                        onPressed: () {
                          _scale(num.parse(scaleXController.text).toDouble(),
                              num.parse(scaleYController.text).toDouble());
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.zoom_out_map),
              color: AppStyle.white,
              onPressed: () => print('Zoom extend'),
            ),
          ],
        ),
      ),
      floatingActionButton: SpeedDial(
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        closeManually: false,
        visible: true,
        overlayOpacity: 0.5,
        elevation: 8.0,
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
            child: Icon(Icons.delete),
            onTap: () => {
              _deleteSelected(),
            },
          ),
        ],
      ),
      body: Card(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
            ),
          ),
          child: GestureDetector(
            onTapDown: (TapDownDetails details) {
              if (Vibration.hasVibrator() != null) {
                Vibration.vibrate(
                  duration: 70,
                );
              }
              RenderBox object = context.findRenderObject();
              Offset coordenadas = object.localToGlobal(details.localPosition);
              _localPosition.add(coordenadas);
              _points = List.from(_points)..add(coordenadas);
              if (formaSelecionada == Forma.linha &&
                  _localPosition.length == 2) {
                setState(() {
                  objetos.add(
                    Figura(_localPosition, Forma.linha, false),
                  );
                  _localPosition = [];
                });
              }

              if (formaSelecionada == Forma.quadradro &&
                  _localPosition.length == 2) {
                Offset p2 = Offset(_localPosition[1].dx, _localPosition[0].dy);
                Offset p3 = Offset(_localPosition[0].dx, _localPosition[1].dy);
                setState(() {
                  _localPosition.add(p2);
                  _localPosition.add(p3);
                  objetos.add(
                    Figura(_localPosition, Forma.quadradro, false),
                  );
                  _localPosition = [];
                  futuro.clear();
                });
              }

              if (formaSelecionada == Forma.triangulo &&
                  _localPosition.length == 3) {
                setState(() {
                  objetos.add(
                    Figura(_localPosition, Forma.triangulo, false),
                  );
                  _localPosition = [];
                  futuro.clear();
                });
              }

              if (formaSelecionada == Forma.circulo &&
                  _localPosition.length == 2) {
                setState(() {
                  objetos.add(
                    Figura(_localPosition, Forma.circulo, false),
                  );
                  _localPosition = [];
                  futuro.clear();
                });
              }

              if (formaSelecionada == Forma.nenhuma &&
                  _localPosition.length == 2) {
                setState(() {
                  zoomClickArea = _localPosition;
                  _localPosition = [];
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
