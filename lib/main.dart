import 'package:cg_tools/pages/draw.dart';
import 'package:flutter/material.dart';

void main() => runApp(CGTools());

class CGTools extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: DrawPage(),
    );
  }
}
