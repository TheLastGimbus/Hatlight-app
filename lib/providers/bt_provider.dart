import 'package:flutter/foundation.dart';
import 'package:foreground_service/foreground_service.dart';
import 'package:hatlight/foreground_service_utils.dart';

/*
What I want with the bluetooth functionality:
 - i need only one device connected
 - i want it to be recovering connection itself as much as possible
 - this provider should contain all functions
 */

class BTProvider with ChangeNotifier {
  BTProvider();

  void init() async {
    await ForegroundService.setServiceIntervalSeconds(1);

    await ForegroundService.setServiceFunctionAsync(false);
    await ForegroundService.startForegroundService(serviceFunction);
    while (!await ForegroundService.isBackgroundIsolateSetupComplete()) {
      print('isolate not done yet');
      await Future.delayed(Duration(milliseconds: 10));
    }
    await ForegroundService.setupIsolateCommunication(
        (message) => print(message));
  }

  void stop() async {
    ForegroundService.sendToPort({'method': 'stopService', 'args': {}});
  }

  void connect() async {
    ForegroundService.sendToPort({'method': 'connectToHatAuto', 'args': {}});
  }
}
