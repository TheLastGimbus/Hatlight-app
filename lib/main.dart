import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hatlight/pages/home_page/home_page.dart';
import 'package:hatlight/providers/bt_provider.dart';
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hatlight',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme:
          ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
      themeMode: ThemeMode.dark,
      // I need to replace it with something that will work in
      // foreground service
      home: HomePage(),
    );
  }
}
