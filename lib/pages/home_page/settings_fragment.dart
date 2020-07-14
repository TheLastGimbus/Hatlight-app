import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:foreground_service/foreground_service.dart';
import 'package:hatlight/providers/bt_provider.dart';
import 'package:provider/provider.dart';

class SettingsFragment extends StatefulWidget {
  @override
  _SettingsFragmentState createState() => _SettingsFragmentState();
}

class _SettingsFragmentState extends State<SettingsFragment> {
  @override
  Widget build(BuildContext context) {
    var bt = Provider.of<BTProvider>(context);
    return Container(
      padding: EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          RaisedButton(
            child: Text('init'),
            onPressed: () => bt.init(),
          ),
          RaisedButton(
            child: Text('connect'),
            onPressed: () {
              bt.connect();
            },
          ),
          RaisedButton(
            child: Text('stop'),
            onPressed: () {
              bt.stop();
            },
            onLongPress: () {
              ForegroundService.stopForegroundService();
            },
          ),
          RaisedButton(
            child: Text("Calibrate"),
            onPressed: () {
              bt.calibrateCompass();
            },
          ),
        ],
      ),
    );
  }
}
