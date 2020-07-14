import 'package:flutter/material.dart';
import 'package:hatlight/providers/bt_provider.dart';
import 'package:provider/provider.dart';

AppBar connectionAppBar(BuildContext ctx) {
  var bt = Provider.of<BTProvider>(ctx);
  return AppBar(
    backgroundColor: bt.isConnected
        ? bt.isNavigating ? Colors.green : Theme.of(ctx).primaryColor
        : Colors.red,
    title: Text(bt.isConnected
        ? bt.isNavigating ? "Navigating" : "Connected"
        : "Not connected"),
  );
}
