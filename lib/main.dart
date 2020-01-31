import 'package:bloc/bloc.dart';
import 'package:cg_tools/blocs/draw_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cg_tools/pages/draw.dart';
import 'package:flutter/material.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
    print(error);
  }
}

void main() {
  BlocSupervisor.delegate = SimpleBlocDelegate();

  runApp(BlocProvider(
    create: (BuildContext context) => DrawBloc(),
    child: CGTools(),
  ));
}

class CGTools extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CG-TOOLS',
      debugShowCheckedModeBanner: false,
      home: DrawPage(),
    );
  }
}
