import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:hatlight/providers/bt_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ScanResult> results = [];
  int _picked = 0;

  void _permission() async {
    var status = await Permission.locationAlways.status;
    if (!status.isGranted) {
      Permission.locationAlways.request();
    }
  }

  @override
  void initState() {
    super.initState();
    _permission();
  }

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
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var bt = Provider.of<BTProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Home page"),
      ),
      body: Container(
        padding: EdgeInsets.all(25),
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
              },
            ),
            devicesList(context, results),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
      ),
    );
  }
}
