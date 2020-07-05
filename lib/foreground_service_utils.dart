import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:foreground_service/foreground_service.dart';
import 'package:latlong/latlong.dart';

/// This class is only to use inside serviceFunction!!!
/// Don't use it anywhere else!
/// It basically manages everything because foreground_service plugin is
/// implemented very poorly :/
class _ForegroundServiceHandler {
  static const SERVICE_UUID = 'f344b002-83b5-4f2d-8b47-43b633299c8f';
  static const CHAR_UUID_SET_LED = '47dcc51e-f45d-4e33-964d-ec998b1f2700';
  final Future<void> Function(Map message) sendMessage;
  final Future<void> Function() onStop;
  var n = ForegroundService.notification;

  _ForegroundServiceHandler({this.sendMessage, this.onStop}) {
    n.setTitle('Waiting to connect to hat...');
//    connectToHatAuto()
//        .then((value) => n.setTitle(value ? 'Connected' : 'Not connected!'));
  }

  final bleManager = BleManager();

  void handleMessage(Map message) {
    switch (message['method']) {
      case 'stopService':
        stop();
        break;
      case 'connectToHatAuto':
        print('Connecting to hat ...');
        connectToHatAuto();
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

  Future<bool> connectToHatAuto() async {
    n.setTitle('Connecting...');
    Peripheral per;
    bleManager.startPeripheralScan(uuids: [SERVICE_UUID]).listen((event) {
      per = event.peripheral;
    });
    while (per == null);
    await per.connect();
    return per.isConnected();
  }

  void stop() async {
    await ForegroundService.stopForegroundService();
    onStop();
  }
}

var isRunning = false;

/// Okay, so this is how bt communication will work
/// All connection stuff must be done and managed from foreground service
/// Any communication is done through .sendToPort()
/// main idea is to send a Map with 'method' - which contains
/// what you want to do, and another Map 'args' which has all required arguments
/// Let's see how this will go...
void serviceFunction() async {
  if (isRunning) {
    print('Service is already running, return');
    return;
  }
  print('Foreground service start');
  isRunning = true;
  Future.delayed(Duration(seconds: 15))
      .then((value) {
    ForegroundService.stopForegroundService();
  });

  try {
    print('Setting up communication');
    final handler = _ForegroundServiceHandler(
      sendMessage: (message) => ForegroundService.sendToPort(message),
      onStop: () {
        isRunning = false;
        return ForegroundService.setupIsolateCommunication(
                (message) => print('Recevied message from stopped serivce!'));
      },
    );

    await ForegroundService.setupIsolateCommunication(
//          (message) => print(message));
            (message) => handler.receiveMessage(message));

    print('Foreground communication set up');
  } catch (e) {
    print("Can't setup communication!");
    print(e);
    await ForegroundService.stopForegroundService();
  }
}
