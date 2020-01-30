import 'dart:math';

import 'package:cg_tools/blocs/draw_bloc.dart';
import 'package:cg_tools/blocs/events/draw_events.dart';
import 'package:cg_tools/blocs/states/draw_states.dart';
import 'package:cg_tools/pages/help.dart';
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
  final dxController = TextEditingController();
  final dyController = TextEditingController();
  List<Offset> _points = <Offset>[];
  List<Offset> zoomClickArea = <Offset>[];
  List<Offset> _localPosition = <Offset>[];
  List<Figura> objetos = <Figura>[];
  List<Figura> futuro = <Figura>[];
  List<Figura> selecionados = <Figura>[];
  List<double> viewport = <double>[0, 0, 0, 0];
  Forma formaSelecionada = Forma.linha;
  bool _clearSelected = false;
  bool _ajudaSelecionada = false;
  bool operacaoSelected = false;
  final GlobalKey cardKey = GlobalKey();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void zoom({Offset p1, Offset p2}) {
    double xMin;
    double yMin;
    double xMax;
    double yMax;
    double sX;
    double sY;
    if (p1 == null || p2 == null) {
      getLimites();
      xMin = min(viewport[0], viewport[2]);
      yMin = min(viewport[1], viewport[3]);
      xMax = max(viewport[0], viewport[2]);
      yMax = max(viewport[1], viewport[3]);
    } else {
      xMin = min(p1.dx, p2.dx);
      yMin = min(p1.dy, p2.dy);
      xMax = max(p1.dx, p2.dx);
      yMax = max(p1.dy, p2.dy);
    }

    double screenRatio = (cardKey.currentContext.size.width) /
        (cardKey.currentContext.size.height);
    double viewPortRatio = ((xMax - xMin) / (yMax - yMin));
    sX = (cardKey.currentContext.size.width) / (xMax - xMin);
    sY = (cardKey.currentContext.size.height) / (yMax - yMin);
    math.Matrix3 matrixAux;
    if (screenRatio > viewPortRatio) {
      double yMaxNovo = (screenRatio / (xMax - xMin)) + yMin;
      setState(() {
        objetos.forEach(
          (Figura fig) => {
            for (int i = 0; i < fig.pontos.length; i++)
              {
                matrixAux = math.Matrix3.columns(
                  math.Vector3(1, 0, 0),
                  math.Vector3(0, 1, 0),
                  math.Vector3(0, (yMax - yMaxNovo) / 2, 0),
                ),
                matrixAux.multiply(
                  math.Matrix3.columns(
                    math.Vector3(sX, 0, 0),
                    math.Vector3(0, sY, 0),
                    math.Vector3(-sX * xMin, -sY * yMin, 0),
                  ),
                ),
                matrixAux.multiply(
                  math.Matrix3.columns(
                    math.Vector3(fig.pontos[i].dx, fig.pontos[i].dy, 1),
                    math.Vector3(0, 0, 0),
                    math.Vector3(0, 0, 0),
                  ),
                ),
                fig.pontos[i] = Offset(
                    matrixAux.getColumn(0)[0].ceil().toDouble(),
                    matrixAux.getColumn(0)[1].ceil().toDouble()),
              },
          },
        );
      });
    } else {
      double xMaxNovo = (screenRatio * (yMax - yMin)) + xMin;
      setState(() {
        objetos.forEach(
          (Figura fig) => {
            for (int i = 0; i < fig.pontos.length; i++)
              {
                matrixAux = math.Matrix3.columns(
                  math.Vector3(1, 0, 0),
                  math.Vector3(0, 1, 0),
                  math.Vector3((xMax - xMaxNovo) / 2, 0, 0),
                ),
                matrixAux.multiply(
                  math.Matrix3.columns(
                    math.Vector3(sX, 0, 0),
                    math.Vector3(0, sY, 0),
                    math.Vector3(-sX * xMin, -sY * yMin, 0),
                  ),
                ),
                matrixAux.multiply(
                  math.Matrix3.columns(
                    math.Vector3(fig.pontos[i].dx, fig.pontos[i].dy, 1),
                    math.Vector3(0, 0, 0),
                    math.Vector3(0, 0, 0),
                  ),
                ),
                fig.pontos[i] = Offset(
                  matrixAux.getColumn(0)[0].ceil().toDouble(),
                  matrixAux.getColumn(0)[1].ceil().toDouble(),
                ),
              },
          },
        );
      });
    }
  }

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
        f.pontos.forEach(
          (Offset coordinate) => {
            if (coordinate.dx < viewport[0]) {viewport[0] = coordinate.dx},
            if (coordinate.dx > viewport[2]) {viewport[2] = coordinate.dx},
            if (coordinate.dy < viewport[1]) {viewport[1] = coordinate.dy},
            if (coordinate.dy > viewport[3]) {viewport[3] = coordinate.dy},
          },
        ),
        if (f.forma == Forma.circulo)
          {
            delta = pow(f.pontos[1].dx - f.pontos[0].dx, 2) +
                pow(f.pontos[1].dy - f.pontos[0].dy, 2),
            raio = sqrt(delta.abs()),
            if (f.pontos[0].dx - raio < viewport[0])
              {viewport[0] = f.pontos[0].dx - raio},
            if (f.pontos[0].dx + raio > viewport[2])
              {viewport[2] = f.pontos[0].dx + raio},
            if (f.pontos[0].dy - raio < viewport[1])
              {viewport[1] = f.pontos[0].dy - raio},
            if (f.pontos[0].dy + raio > viewport[3])
              {viewport[3] = f.pontos[0].dy + raio},
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
                              BlocProvider.of<DrawBloc>(context)
                                  .add(ItemModalButtonPressed()),
                              setState(() {
                                objetos[index].selected =
                                    !objetos[index].selected;
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

  void _rotate(double degrees, {Offset pontoRotacao}) {
    final double cosseno = cos(math.radians(degrees));
    final double seno = sin(math.radians(degrees));
    math.Matrix3 resultLine;
    math.Matrix4 resultLineSquare;
    double dx;
    double dy;
    objetos.where((Figura fig) => fig.selected == true).forEach(
          (Figura f) => {
            if (pontoRotacao == null)
              {dx = f.pontos[0].dx, dy = f.pontos[0].dy}
            else
              {dx = pontoRotacao.dx, dy = pontoRotacao.dy},
            if (f.forma == Forma.linha || f.forma == Forma.circulo)
              {
                resultLine = math.Matrix3.columns(
                  math.Vector3(cosseno, seno, 0),
                  math.Vector3(-seno, cosseno, 0),
                  math.Vector3(
                    (dy * seno) - (dx * cosseno) + dx,
                    -(dx * seno) - (dy * cosseno) + dy,
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
                    (dy * seno) - (dx * cosseno) + dx,
                    -(dx * seno) - (dy * cosseno) + dy,
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
                  math.Vector4((dy * seno) - (dx * cosseno) + dx,
                      -(dx * seno) - (dy * cosseno) + dy, 1, 0),
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
    math.Matrix4 resultLineSquare;
    objetos.where((Figura fig) => fig.selected == true).forEach(
          (Figura f) => {
            if (f.forma == Forma.linha || f.forma == Forma.circulo)
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
            if (f.forma == Forma.quadradro)
              {
                resultLineSquare = math.Matrix4.columns(
                  math.Vector4(scaleX, 0, 0, 0),
                  math.Vector4(0, scaleY, 0, 0),
                  math.Vector4((f.pontos[0].dx - (f.pontos[0].dx * scaleX)),
                      (f.pontos[0].dy - (f.pontos[0].dy * scaleY)), 1, 0),
                  math.Vector4(0, 0, 0, 0),
                ),
                resultLineSquare.multiply(
                  math.Matrix4.columns(
                    math.Vector4(f.pontos[0].dx, f.pontos[0].dy, 1, 0),
                    math.Vector4(f.pontos[1].dx, f.pontos[1].dy, 1, 0),
                    math.Vector4(0, 0, 0, 0),
                    math.Vector4(0, 0, 0, 0),
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
                  resultLineSquare.getColumn(1)[0],
                  resultLineSquare.getColumn(0)[1],
                ),
                f.pontos[3] = Offset(
                  resultLineSquare.getColumn(0)[0],
                  resultLineSquare.getColumn(1)[1],
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

  SnackBar createSnack(String text) {
    return SnackBar(
      content: Text(text),
      backgroundColor: AppStyle.triadic1,
      duration: Duration(milliseconds: 1200),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DrawBloc, DrawStates>(
        builder: (BuildContext context, DrawStates state) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: AppStyle.primary,
          centerTitle: true,
          title: Text('CG tools'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.help),
              onPressed: () => _ajudaSelecionada
                  ? {
                      BlocProvider.of<DrawBloc>(context)
                          .add(CanvasModalButtonPressed()),
                      _ajudaSelecionada = false,
                    }
                  : {
                      BlocProvider.of<DrawBloc>(context)
                          .add(AjudaModalButtonPressed()),
                      _ajudaSelecionada = true,
                    },
            ),
            IconButton(
              icon: Icon(Icons.zoom_in),
              onPressed: () => objetos.isNotEmpty
                  ? {
                      formaSelecionada = Forma.nenhuma,
                      _scaffoldKey.currentState.showSnackBar(
                        createSnack(
                            "Selecione o primeiro ponto para fazer o zoom"),
                      ),
                    }
                  : showDialog<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Ops!'),
                          content:
                              Text('Voce ainda nao inseriu elementos na tela'),
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
                    ),
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
                  if (operacaoSelected) {
                    setState(() {
                      objetos = [];
                      objetos.addAll(futuro);
                      futuro.clear();
                      operacaoSelected = false;
                    });
                  } else if (_clearSelected) {
                    setState(() {
                      objetos.addAll(futuro);
                      futuro.clear();
                      _clearSelected = false;
                    });
                  } else if (objetos.isNotEmpty && !operacaoSelected) {
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
                tooltip: 'Rotacionar 90',
                enableFeedback: true,
                icon: Icon(Icons.rotate_90_degrees_ccw),
                color: AppStyle.white,
                onPressed: () => objetos.isNotEmpty
                    ? {
                        setState(() {
                          futuro.clear();
                          futuro.addAll(objetos);
                          operacaoSelected = true;
                        }),
                        _rotate(90),
                      }
                    : showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Ops!'),
                            content: Text(
                                'Voce ainda nao inseriu elementos na tela'),
                            actions: <Widget>[
                              FlatButton(
                                child: const Text('Ok'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      ),
              ),
              IconButton(
                tooltip: 'Rotacionar',
                enableFeedback: true,
                icon: Icon(Icons.rotate_right),
                color: AppStyle.white,
                onPressed: () => objetos.isNotEmpty
                    ? showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title:
                                Text('Digite quantos graus deseja rotacionar'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                    'Selecione a partir de qual ponto rotacionar'),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 100,
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          labelText: 'X',
                                        ),
                                        keyboardType: TextInputType.number,
                                        controller: dxController,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 40,
                                    ),
                                    SizedBox(
                                      width: 100,
                                      child: TextFormField(
                                        decoration: InputDecoration(
                                          labelText: 'Y',
                                        ),
                                        keyboardType: TextInputType.number,
                                        controller: dyController,
                                      ),
                                    ),
                                  ],
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: rotateController,
                                  decoration: InputDecoration(
                                    labelText: 'Angulo',
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
                                onPressed: () => {
                                  operacaoSelected = true,
                                  futuro.clear(),
                                  futuro.addAll(objetos),
                                  _rotate(
                                    num.parse(rotateController.text).toDouble(),
                                    pontoRotacao: Offset(
                                      num.parse(dxController.text).toDouble(),
                                      num.parse(dyController.text).toDouble(),
                                    ),
                                  ),
                                  Navigator.of(context).pop(),
                                },
                              ),
                            ],
                          );
                        },
                      )
                    : showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Ops!'),
                            content: Text(
                                'Voce ainda nao inseriu elementos na tela'),
                            actions: <Widget>[
                              FlatButton(
                                child: const Text('Ok'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      ),
              ),
              IconButton(
                tooltip: 'Linha de comando',
                enableFeedback: true,
                icon: Icon(Icons.chevron_right),
                color: AppStyle.white,
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    String string;
                    List<String> splitted;
                    return AlertDialog(
                      title: Text('Informe a operação desejada'),
                      content: TextFormField(
                        decoration: InputDecoration(
                            hintText:
                                'operacao [valor1 valor2 valor 3 valor 4]'),
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
                          onPressed: () => {
                            string = commandController.text,
                            splitted = string.split(" "),
                            if (splitted[0] == 'rotate')
                              {
                                splitted.length > 2
                                    ? _rotate(
                                        num.parse(splitted[1]).toDouble(),
                                        pontoRotacao: Offset(
                                          num.parse(splitted[2]).toDouble(),
                                          num.parse(splitted[3]).toDouble(),
                                        ),
                                      )
                                    : _rotate(
                                        num.parse(splitted[1]).toDouble()),
                                Navigator.of(context).pop(),
                              }
                            else if (splitted[0] == 'translate')
                              {
                                _translate(num.parse(splitted[1]).toDouble(),
                                    num.parse(splitted[2]).toDouble()),
                                Navigator.of(context).pop(),
                              }
                            else if (splitted[0] == 'scale')
                              {
                                _scale(num.parse(splitted[1]).toDouble(),
                                    num.parse(splitted[2]).toDouble()),
                                Navigator.of(context).pop(),
                              }
                            else if (splitted[0] == 'zoom')
                              {
                                splitted[1] == '0'
                                    ? zoom()
                                    : zoom(
                                        p1: Offset(
                                          num.parse(splitted[1]).toDouble(),
                                          num.parse(splitted[2]).toDouble(),
                                        ),
                                        p2: Offset(
                                          num.parse(splitted[3]).toDouble(),
                                          num.parse(splitted[4]).toDouble(),
                                        ),
                                      ),
                              }
                            else if (splitted[0] == 'select')
                              {
                                objetos[num.parse(splitted[1]).toInt()]
                                        .selected =
                                    !objetos[num.parse(splitted[1]).toInt()]
                                        .selected,
                              }
                            else if (splitted[0] == 'selectall')
                              {
                                futuro.clear(),
                                futuro.addAll(objetos),
                                for (int i = 0; i < objetos.length; i++)
                                  {objetos[i].selected = true}
                              }
                            else
                              {
                                AlertDialog(
                                  title: Text('Operacao não reconhecida'),
                                ),
                              },
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
                onPressed: () => objetos.isNotEmpty
                    ? {
                        formaSelecionada = Forma.translacao,
                        _scaffoldKey.currentState.showSnackBar(
                          createSnack(
                              "Selecione o primeiro ponto para fazer a translação"),
                        ),
                      }
                    : showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Ops!'),
                            content: Text(
                                'Voce ainda nao inseriu elementos na tela'),
                            actions: <Widget>[
                              FlatButton(
                                child: const Text('Ok'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      ),
              ),
              IconButton(
                tooltip: 'Mudar escala',
                enableFeedback: true,
                icon: Icon(Icons.crop),
                color: AppStyle.white,
                onPressed: () => objetos.isNotEmpty
                    ? showDialog<void>(
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
                                  operacaoSelected = true;
                                  futuro.clear();
                                  futuro.addAll(objetos);
                                  _scale(
                                      num.parse(scaleXController.text)
                                          .toDouble(),
                                      num.parse(scaleYController.text)
                                          .toDouble());
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      )
                    : showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Ops!'),
                            content: Text(
                                'Voce ainda nao inseriu elementos na tela'),
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
                      ),
              ),
              IconButton(
                tooltip: 'Zoom extend',
                enableFeedback: true,
                icon: Icon(Icons.zoom_out_map),
                color: AppStyle.white,
                onPressed: () => objetos.isNotEmpty
                    ? {
                        operacaoSelected = true,
                        futuro.clear(),
                        futuro.addAll(objetos),
                        zoom(),
                      }
                    : showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Ops!'),
                            content: Text(
                                'Voce ainda nao inseriu elementos na tela'),
                            actions: <Widget>[
                              FlatButton(
                                child: const Text('Ok'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      ),
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
              label: 'Linha',
              backgroundColor: AppStyle.triadic1,
              child: Icon(MdiIcons.minus),
              onTap: () => formaSelecionada = Forma.linha,
            ),
            SpeedDialChild(
              label: 'Triangulo',
              backgroundColor: AppStyle.triadic1,
              child: Icon(MdiIcons.triangleOutline),
              onTap: () => formaSelecionada = Forma.triangulo,
            ),
            SpeedDialChild(
              label: 'Quadrado',
              backgroundColor: AppStyle.triadic1,
              child: Icon(MdiIcons.squareOutline),
              onTap: () => formaSelecionada = Forma.quadradro,
            ),
            SpeedDialChild(
              label: 'Circulo',
              backgroundColor: AppStyle.triadic1,
              child: Icon(MdiIcons.circleOutline),
              onTap: () => formaSelecionada = Forma.circulo,
            ),
            SpeedDialChild(
              label: 'Deletar',
              backgroundColor: AppStyle.triadic1,
              child: Icon(Icons.delete),
              onTap: () => {
                _deleteSelected(),
              },
            ),
          ],
        ),
        body: state is AjudaSelecionada
            ? ajudaContexto()
            : Card(
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
                      Offset coordenadas =
                          object.localToGlobal(details.localPosition);
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
                        Offset p2 =
                            Offset(_localPosition[1].dx, _localPosition[0].dy);
                        Offset p3 =
                            Offset(_localPosition[0].dx, _localPosition[1].dy);
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
                        double delta = pow(
                                _localPosition[1].dx - _localPosition[0].dx,
                                2) +
                            pow(_localPosition[1].dy - _localPosition[0].dy, 2);
                        double raio = sqrt(delta.abs());

                        Offset xMin = Offset(
                            _localPosition[0].dx - raio, _localPosition[0].dy);
                        Offset yMin = Offset(
                            _localPosition[0].dx, _localPosition[0].dy - raio);
                        Offset xMax = Offset(
                            _localPosition[0].dx + raio, _localPosition[0].dy);
                        Offset yMax = Offset(
                            _localPosition[0].dx, _localPosition[0].dy + raio);

                        _localPosition.add(xMin);
                        _localPosition.add(yMin);
                        _localPosition.add(xMax);
                        _localPosition.add(yMax);
                        setState(() {
                          objetos.add(
                            Figura(_localPosition, Forma.circulo, false),
                          );
                          _localPosition = [];
                          futuro.clear();
                        });
                      }

                      if (formaSelecionada == Forma.nenhuma &&
                          _localPosition.length == 1 &&
                          objetos.isNotEmpty) {
                        _scaffoldKey.currentState.showSnackBar(createSnack(
                            "Selecione o segundo ponto para fazer o zoom"));
                      }

                      if (formaSelecionada == Forma.nenhuma &&
                          _localPosition.length == 2) {
                        setState(() {
                          futuro.clear();
                          futuro.addAll(objetos);
                          operacaoSelected = true;
                          zoomClickArea = _localPosition;
                          zoom(p1: zoomClickArea[0], p2: zoomClickArea[1]);
                          _localPosition = [];
                        });
                      }

                      if (formaSelecionada == Forma.translacao &&
                          _localPosition.length == 1) {
                        _scaffoldKey.currentState.showSnackBar(createSnack(
                            "Selecione o segundo ponto para fazer a translação"));
                      }

                      if (formaSelecionada == Forma.translacao &&
                          _localPosition.length == 2) {
                        double dx =
                            (_localPosition[0].dx - _localPosition[1].dx).abs();
                        double dy =
                            (_localPosition[0].dy - _localPosition[1].dy).abs();

                        double x;
                        double y;

                        if (_localPosition[0].dx < _localPosition[1].dx) {
                          x = objetos[0].pontos[0].dx + dx;
                        } else {
                          x = objetos[0].pontos[0].dx - dx;
                        }

                        if (_localPosition[0].dy < _localPosition[1].dy) {
                          y = objetos[0].pontos[0].dy + dy;
                        } else {
                          y = objetos[0].pontos[0].dy - dy;
                        }

                        setState(() {
                          operacaoSelected = true;
                          _translate(x, y);
                          _localPosition = [];
                        });
                        formaSelecionada = objetos[objetos.length - 1].forma;
                      }
                    },
                    child: CustomPaint(
                      isComplex: false,
                      key: cardKey,
                      painter: MagicalPaint(figuras: objetos),
                    ),
                  ),
                ),
              ),
      );
    });
  }
}
