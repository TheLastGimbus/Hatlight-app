import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
          ColorPicker(
            pickerColor: _color,
            onColorChanged: (color) async {
              _color = color;
              setState(() {});
              if (_sending) return;
              _sending = true;
              bt.setColor(_color);
              await Future.delayed(Duration(milliseconds: 30));
              _sending = false;
            },
            enableAlpha: false,
            pickerAreaHeightPercent: 0.8,
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
