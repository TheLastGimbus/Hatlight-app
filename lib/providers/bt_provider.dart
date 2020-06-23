import 'package:flutter/foundation.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*
What I want with the bluetooth functionality:
 - i need only one device connected
 - i want it to be recovering connection itself as much as possible
 - this provider should contain all functions
 */

class BTProvider with ChangeNotifier {
  static const SERVICE_UUID = 'f344b002-83b5-4f2d-8b47-43b633299c8f';
  static const CHAR_UUID_SET_LED = '47dcc51e-f45d-4e33-964d-ec998b1f2700';
  static const PREF_PER_ID = 'bt.peripheral.identifier';
  var _manager = BleManager();
  Peripheral _per;

  BTProvider() {
    _manager.createClient();
  }

  Stream<ScanResult> scanForDevices() {
    return _manager.startPeripheralScan(uuids: [SERVICE_UUID]);
  }

  Future<void> stopScan() => _manager.stopPeripheralScan();

  Future<bool> _connectToPer() async {
    if (_per == null) return false;
    if (await _per.isConnected()) return true;
    await _per.connect();
    await _per.discoverAllServicesAndCharacteristics();
    return _per.isConnected();
  }

  Future<void> connectToPeripheral(Peripheral peripheral) async {
    _per = peripheral;
    await _connectToPer();
    var sp = await SharedPreferences.getInstance();
    await sp.setString(PREF_PER_ID, _per.identifier);
  }

  Future<Peripheral> savedPeripheral() async {
    var sp = await SharedPreferences.getInstance();
    var id = sp.getString(PREF_PER_ID);
    if (id == null || id.isEmpty) return null;
    var known = await _manager.knownPeripherals([id]);
    if (known.length > 0)
      return known[0];
    else
      return null;
  }

  Future<bool> connectToSaved() async {
    _per = await savedPeripheral();
    return _connectToPer();
  }

  Future<bool> isConnected() => _per?.isConnected() ?? Future.value(false);

  @override
  void dispose() {
    _manager.destroyClient();
    super.dispose();
  }
}
