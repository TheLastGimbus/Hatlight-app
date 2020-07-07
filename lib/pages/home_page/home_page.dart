import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:foreground_service/foreground_service.dart';
import 'package:hatlight/providers/bt_provider.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Marker> markers = [];
  int _picked = 0;
  var mapController = MapController();
  var loc = Location();

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
            Flexible(
              child: Stack(
                children: <Widget>[
                  FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                        center: LatLng(41.904088, 12.453005),
                        maxZoom: 18.49,
                        onTap: (tapPlace) {
                          markers = [
                            Marker(
                              point: tapPlace,
                              builder: (ctx) => Icon(Icons.location_on,
                                  size: 40, color: Colors.black),
                            )
                          ];
                          setState(() {});
                        }),
                    layers: [
                      TileLayerOptions(
                        urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayerOptions(markers: markers)
                    ],
                  ),
                  if (markers.length > 0)
                    Container(
                      alignment: Alignment.bottomCenter,
                      padding:
                          EdgeInsets.symmetric(vertical: 80, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(
                            child: Text('init'),
                            onPressed: () => bt.init(),
                          ),
                          RaisedButton(
                            child: Text('go'),
                            onPressed: () async {
                              // TODO
                            },
                          ),
                          RaisedButton(
                            child: Text('connect'),
                            onPressed: () async {
                              bt.connect();
                            },
                          ),
                          RaisedButton(
                            child: Text('stop'),
                            onPressed: () {
                              bt.stop();
                            },
                            onLongPress: () {
                              ForegroundService.stopForegroundService();
                            },
                          ),
                        ],
                      ),
                    )
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.gps_fixed),
        onPressed: () async {
          var data = await loc.getLocation();
          mapController.move(LatLng(data.latitude, data.longitude), 15);
        },
      ),
    );
  }
}
