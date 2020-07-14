import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
      child: Column(
        children: <Widget>[
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
