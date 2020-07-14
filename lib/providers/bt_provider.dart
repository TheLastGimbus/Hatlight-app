import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foreground_service/foreground_service.dart';
import 'package:hatlight/foreground_service_utils.dart';
import 'package:latlong/latlong.dart';

/*
What I want with the bluetooth functionality:
 - i need only one device connected
 - i want it to be recovering connection itself as much as possible
 - this provider should contain all functions
 */

class BTProvider with ChangeNotifier {
  StreamController<Map> incomingMessagesCtrl = StreamController<Map>();
  bool _isConnected = false;

  LatLng targetLatLng;

  BTProvider() {
    incomingMessagesCtrl.stream.listen((event) {
      print("Received $event");
      switch (event['method']) {
        case 'isConnected':
          _isConnected = event['args']['response'];
          notifyListeners();
          break;
      }
    });
  }

  Future<bool> sendMessage(Map message) async {
    if (!await ForegroundService.isBackgroundIsolateSetupComplete() ||
        !ForegroundService.isIsolateCommunicationSetup) {
      return false;
    }
    await ForegroundService.sendToPort(message);
    return true;
  }

  void init() async {
    await ForegroundService.setServiceIntervalSeconds(1);

    await ForegroundService.setServiceFunctionAsync(false);
    await ForegroundService.startForegroundService(serviceFunction);
    while (!await ForegroundService.isBackgroundIsolateSetupComplete()) {
      print('isolate not done yet');
      await Future.delayed(Duration(milliseconds: 10));
    }
    await ForegroundService.setupIsolateCommunication((message) {
      if (!(message is Map)) {
        print('Message received from provider is not a Map!!!');
        print(message);
        return;
      }
      incomingMessagesCtrl.add(message);
    });
  }

  bool get isConnected => _isConnected;

  void refreshIsConnected() =>
      sendMessage({'method': 'isConnected', 'args': {}});

  void goBlank() => sendMessage({'method': 'setBlank', 'args': {}});

  // Send color in separate RGB ints instead of 32bit for compatibility stuff
  void setColor(Color color) => sendMessage({
        'method': 'setColor',
        'args': {
          'color': {
            'r': color.red,
            'g': color.green,
            'b': color.blue,
          },
        }
      });

  void startNavigationCompassTarget(LatLng target) => sendMessage({
        'method': 'navigateToLatLngCompass',
        'args': {'lat': target.latitude, 'lng': target.longitude}
      });

  void calibrateCompass() =>
      sendMessage({'method': 'calibrateCompass', 'args': {}});

  void stop() async {
    sendMessage({'method': 'stopService', 'args': {}});
  }

  void connect() async {
    sendMessage({'method': 'connectToHatAuto', 'args': {}});
  }
}
