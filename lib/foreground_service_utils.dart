import 'dart:isolate';

import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:foreground_service/foreground_service.dart';

/// This class is only to use inside serviceFunction!!!
/// Don't use it anywhere else!
/// It basically manages everything because foreground_service plugin is
/// implemented very poorly :/
class _ForegroundServiceHandler {
  final Future<void> Function(Map message) sendMessage;
  final _bleManager = BleManager();

  _ForegroundServiceHandler(this.sendMessage) {
    var n = ForegroundService.notification;
    n.setTitle('Waiting to connect to hat...');
  }

  final bleManager = BleManager();

  void _handleMessage(Map message) {
    switch (message['method']) {
      case 'connectTo':
        print('Connecting to...');
        print('TODO'); // TODO
        break;
      case 'scanDevices':
        print('Scanning devices...');
        print('TODO'); // TODO
        break;
    }
  }

  void receiveMessage(dynamic message) {
    print('New message received in service: $message');
    assert(message is Map);
    _handleMessage(message);
  }
}

/// Okay, so this is how bt communication will work
/// All connection stuff must be done and managed from foreground service
/// Any communication is done through .sendToPort()
/// main idea is to send a Map with 'method' - which contains
/// what you want to do, and another Map 'args' which has all required arguments
/// Let's see how this will go...
void serviceFunction() async {
  print('Foreground service start');
  final handler = _ForegroundServiceHandler(
      (message) => ForegroundService.sendToPort(message));

  await ForegroundService.setupIsolateCommunication(
      (message) => handler.receiveMessage(message));

  await Future.delayed(Duration(seconds: 30));
  await ForegroundService.stopForegroundService();
  Isolate.current.kill(priority: Isolate.immediate);
}