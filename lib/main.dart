import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ocha/model/lang.dart' as lang;
import 'package:ocha/flash.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: lang.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FlashScreen(),
    );
  }
}
