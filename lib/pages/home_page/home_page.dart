import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hatlight/pages/home_page/connect_dialog.dart';
import 'package:hatlight/providers/bt_provider.dart';
import 'package:latlong/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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

  Widget hatStatusBar() {
    var bt = Provider.of<BTProvider>(context);
    return FutureBuilder(
      future: bt.isConnected(),
      initialData: false,
      builder: (ctx, AsyncSnapshot<bool> snapshot) {
        bool con() => (snapshot.hasData && snapshot.data);
        // TODO: This still sucks if hat disconnects by itself
        // But this is stuff that I will fix when i will do a complete rewrite
        // when I learn more how this stuff works
        var m = 'Hat status: ' +
            (snapshot.hasData
                ? snapshot.data ? 'connected' : 'not connected!'
                : 'checking...');
        return ListTile(
          title: Text(m),
          subtitle: con() ? null : Text('Tap to connect'),
          onTap: con()
              ? null
              : () => showDialog(
                    context: context,
                    builder: (context) =>
                        ChangeNotifierProvider<BTProvider>.value(
                      value: bt,
                      child: ConnectDialog(),
                    ),
                  ).then((value) => setState(() {})),
        );
      },
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            hatStatusBar(),
            Flexible(
              child: FlutterMap(
                options: MapOptions(center: LatLng(41.904088, 12.453005)),
                layers: [
                  TileLayerOptions(
                      urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: ['a', 'b', 'c'],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
      ),
    );
  }
}
