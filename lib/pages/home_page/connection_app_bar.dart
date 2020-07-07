import 'package:flutter/material.dart';
import 'package:hatlight/providers/bt_provider.dart';
import 'package:provider/provider.dart';

AppBar connectionAppBar(BuildContext ctx) {
  var bt = Provider.of<BTProvider>(ctx);
  return AppBar(
    title: Text(bt.isConnected ? "Connected" : "Not connected"),
  );
}
