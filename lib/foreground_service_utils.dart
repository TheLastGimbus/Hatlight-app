import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:foreground_service/foreground_service.dart';
import 'package:latlong/latlong.dart';

/// This class is only to use inside serviceFunction!!!
/// Don't use it anywhere else!
/// It basically manages everything because foreground_service plugin is
/// implemented very poorly :/
class _ForegroundServiceHandler {
  final Future<void> Function(Map message) sendMessage;

  _ForegroundServiceHandler(this.sendMessage) {
    var n = ForegroundService.notification;
    n.setTitle('Waiting to connect to hat...');
  }

  final bleManager = BleManager();

  void handleMessage(Map message) {
    switch (message['method']) {
      case 'stopService':
        stop();
        break;
      case 'connectToHatAuto':
        print('Connecting to hat ...');
        print('TODO'); // TODO
        break;
      case 'navigateToLatLngCompass':
        var destination =
            LatLng(message['args']['lat'], message['args']['lng']);
        print('Navigating to: $destination');
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
    handleMessage(message);
  }

  void stop() async {
    await ForegroundService.stopForegroundService();
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

  await Future.delayed(Duration(minutes: 3));
  await ForegroundService.stopForegroundService();
}
