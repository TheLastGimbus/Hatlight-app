import 'package:flutter/foundation.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';

class BTProvider with ChangeNotifier {
  var _manager = BleManager();

  BTProvider() {
    _manager.createClient();
  }

  void connect() async {
    _manager.startPeripheralScan(scanMode: ScanMode.lowLatency).listen((
        event) async {
      // It works !!!
      print('New scan: ${event.advertisementData.localName}');
    });
  }

  @override
  void dispose() {
    _manager.destroyClient();
    super.dispose();
  }
}
