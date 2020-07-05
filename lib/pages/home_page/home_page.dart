import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:foreground_service/foreground_service.dart';
import 'package:hatlight/foreground_service_utils.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

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

  void _initService() async {
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

  @override
  void initState() {
    super.initState();
    _permission();
    _initService();
  }

  @override
  Widget build(BuildContext context) {
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
                      padding: EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(
                            child: Text('init'),
                            onPressed: () => _initService(),
                          ),
                          RaisedButton(
                            child: Text('go'),
                            onPressed: () async {
                              // TODO: Send info where to go
                              ForegroundService.sendToPort({
                                'method': 'navigateToLatLngCompass',
                                'args': {
                                  'lat': markers[0].point.latitude,
                                  'lng': markers[0].point.longitude
                                }
                              });
                            },
                          ),
                          RaisedButton(
                            child: Text('set'),
                            onPressed: () async {
                              if (!await ForegroundService
                                  .isBackgroundIsolateSetupComplete() ||
                                  !ForegroundService
                                      .isIsolateCommunicationSetup) {
                                print('stuff is not set up!!');
                              } else {
                                ForegroundService.sendToPort(
                                    {'method': 'connectTo', 'args': {}});
                              }
                            },
                          ),
                          RaisedButton(
                            child: Text('stop'),
                            onPressed: () {
                              ForegroundService.sendToPort(
                                  {'method': 'stopService', 'args': {}});
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
