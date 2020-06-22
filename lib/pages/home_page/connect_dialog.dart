import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:hatlight/providers/bt_provider.dart';
import 'package:provider/provider.dart';

class ConnectDialog extends StatefulWidget {
  @override
  _ConnectDialogState createState() => _ConnectDialogState();
}

class _ConnectDialogState extends State<ConnectDialog> {
  List<ScanResult> results = [];

  Widget devicesList(BuildContext context, List<ScanResult> devices) {
    var bt = Provider.of<BTProvider>(context);
    return Flexible(
      child: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, x) => ListTile(
          title: Text(devices[x].advertisementData.localName),
          subtitle: Text(devices[x].peripheral.identifier),
          onTap: () async {
            await bt.stopScan();
            await bt.connectToPeripheral(devices[x].peripheral);
            if (await bt.isConnected()) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var bt = Provider.of<BTProvider>(context);
    return Dialog(
      child: Column(
        children: <Widget>[
          RaisedButton(
              child: Text('Scan'),
              onPressed: () {
                bt.scanForDevices().listen((event) {
                  for (var res in results) {
                    if (res.peripheral.identifier ==
                        event.peripheral.identifier) {
                      return;
                    }
                  }
                  results.add(event);
                  setState(() {});
                });
              }),
          devicesList(context, results),
        ],
      ),
    );
  }
}
