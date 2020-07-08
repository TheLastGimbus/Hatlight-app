import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_circle_color_picker/flutter_circle_color_picker.dart';
import 'package:hatlight/providers/bt_provider.dart';
import 'package:provider/provider.dart';

class ColorsFragment extends StatefulWidget {
  @override
  _ColorsFragmentState createState() => _ColorsFragmentState();
}

class _ColorsFragmentState extends State<ColorsFragment> {
  var _color = Colors.white;
  var _sending = false;

  @override
  Widget build(BuildContext context) {
    var bt = Provider.of<BTProvider>(context);
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          CircleColorPicker(
            onChanged: (color) async {
              _color = color;
              if (_sending) return;
              _sending = true;
              bt.setColor(_color);
              await Future.delayed(Duration(milliseconds: 30));
              _sending = false;
            },
          ),
          RaisedButton(
            child: Text('Send'),
            onPressed: () {
              bt.setColor(_color);
            },
          ),
        ],
      ),
    );
  }
}
