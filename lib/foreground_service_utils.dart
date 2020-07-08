import 'dart:typed_data';

import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:foreground_service/foreground_service.dart';
import 'package:latlong/latlong.dart';

class MODE {
  static const BLANK = 1;
  static const SET_COLOR_FILL = 2;
}

/// This class is only to use inside serviceFunction!!!
/// Don't use it anywhere else!
/// It basically manages everything because foreground_service plugin is
/// implemented very poorly :/
class _ForegroundServiceHandler {
  static const SERVICE_UUID = 'f344b002-83b5-4f2d-8b47-43b633299c8f';
  static const CHAR_UUID_MODE = '47dcc51e-f45d-4e33-964d-ec998b1f2700';
  static const CHAR_UUID_COLOR_GENERAL = "cd6aaefa-29d8-42ae-bd8c-fd4f654e7c66";

  final Future<void> Function(Map message) sendMessage;
  final Future<void> Function() onStop;
  var n = ForegroundService.notification;

  _ForegroundServiceHandler({this.sendMessage, this.onStop}) {
    n.setTitle('Waiting to connect to hat...');
    bleManager.createClient();
  }

  final bleManager = BleManager();
  Peripheral per;

  Future<bool> get isConnected => per?.isConnected() ?? false;

  void handleMessage(Map message) {
    switch (message['method']) {
      case 'stopService':
        stop();
        break;
      case 'connectToHatAuto':
        print('Connecting to hat ...');
        n.setTitle('Connecting...');
        connectToHatAuto().then(
                (value) => n.setTitle(value ? 'Connected' : 'Not connected!'));
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
      case 'isConnected':
        handleIsConnectedRequest();
        break;
      case 'setColor':
        var c = message['args']['color'];
        setColor(c['r'], c['b'], c['b']);
        break;
    }
  }

  /// This sets the MODE of hat to COLOR_FILL and sends color
  Future<bool> setColor(int r, int g, int b) async {
    if (!await isConnected) return false;
    await per.writeCharacteristic(SERVICE_UUID, CHAR_UUID_MODE,
        Uint8List.fromList([MODE.SET_COLOR_FILL]), false);
    // TODO: Figure out if this .fromList is doing okay
    await per.writeCharacteristic(SERVICE_UUID, CHAR_UUID_COLOR_GENERAL,
        Uint8List.fromList([r, g, b]), false);
    return true;
  }

  void handleIsConnectedRequest() async => sendMessage({
    'method': 'isConnected',
    'args': {'response': await isConnected}
  });

  void receiveMessage(dynamic message) {
    print('New message received in service: $message');
    assert(message is Map);
    handleMessage(message);
  }

  Future<bool> connectToHatAuto() async {
    Future<ScanResult> firstScanFuture;
    firstScanFuture = bleManager
        .startPeripheralScan(
        scanMode: ScanMode.balanced, uuids: [SERVICE_UUID])
        .first;
    ScanResult firstScan = await Future.any(
      [firstScanFuture, Future.delayed(Duration(seconds: 15), () => null)],
    );
    if (firstScan == null) {
      print("No peripheral found!");
      return false;
    }
    per = firstScan.peripheral;
    per.observeConnectionState(
        emitCurrentValue: true, completeOnDisconnect: true).listen((event) {
      print("observed: ");
      print(event);
      sendMessage({
        'method': 'isConnected',
        'args': {'response': event == PeripheralConnectionState.connected}
      });
    });
    await per.connect();
    await per.discoverAllServicesAndCharacteristics();
    return per.isConnected();
  }

  void stop() async {
    await per?.disconnectOrCancelConnection();
    per = null;
    await bleManager.destroyClient();
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
    //print('Service is already running, return');
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
