import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hatlight/providers/bt_provider.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

class MapFragment extends StatefulWidget {
  @override
  _MapFragmentState createState() => _MapFragmentState();
}

class _MapFragmentState extends State<MapFragment> {
  Marker destinationMarker;
  Marker newDestinationMarker;
  Marker userLocationMarker;
  var mapController = MapController();
  var loc = Geolocator();

  Widget buttons(BTProvider bt) => Container(
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('go'),
              onPressed: () async {
                if (!bt.isConnected) {
                  print("Not connected!");
                  return;
                }
                if (newDestinationMarker != null) {
                  bt.targetLatLng = newDestinationMarker.point;
                  if (!await bt.startNavigationCompassTarget(bt.targetLatLng)) {
                    // Don't do anything with markers if it wasn't success
                    return;
                  }

                  // Swap with new marker, remove temporary marker
                  destinationMarker = Marker(
                    point: newDestinationMarker.point,
                    builder: (ctx) => Icon(
                      Icons.flag,
                      size: 60,
                      color: Colors.black,
                    ),
                    anchorPos: AnchorPos.exactly(Anchor(15, -25)),
                  );
                  newDestinationMarker = null;
                  setState(() {});
                } else {
                  print("No target!");
                }
              },
            ),
            RaisedButton(
              child: Text('stop'),
              onPressed: () {
                bt.goBlank();
                destinationMarker = null;
                newDestinationMarker = null;
                setState(() {});
              },
            )
          ],
        ),
      );

  void setupLocation() async {
    if ((await loc.checkGeolocationPermissionStatus()) ==
        GeolocationStatus.granted) {
      loc.getPositionStream().listen((event) {
        userLocationMarker = Marker(
            point: LatLng(event.latitude, event.longitude),
            builder: (ctx) =>
                Icon(Icons.radio_button_checked, color: Colors.blue));
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setupLocation();
  }

  @override
  Widget build(BuildContext context) {
    var bt = Provider.of<BTProvider>(context);
    return Container(
      child: Stack(
        children: <Widget>[
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
                center: LatLng(41.904088, 12.453005),
                maxZoom: 18.49,
                onTap: bt.isNavigating
                    ? null
                    : (tapPlace) {
                  bt.targetLatLng = tapPlace;
                  newDestinationMarker = Marker(
                      point: tapPlace,
                      builder: (ctx) =>
                          Icon(
                            Icons.location_on,
                            size: 40, color: Colors.black,
                          ),
                      anchorPos: AnchorPos.exactly(Anchor(10, -7))
                  );
                  setState(() {});
                }),
            layers: [
              TileLayerOptions(
                urlTemplate:
                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayerOptions(
                  markers: [
                userLocationMarker,
                destinationMarker,
                newDestinationMarker
              ].where((e) => e != null).toList())
            ],
          ),
          Container(
            alignment: Alignment.bottomRight,
            padding: EdgeInsets.all(24),
            child: FloatingActionButton(
              child: Icon(Icons.my_location),
              onPressed: () async {
                var pos = await loc.getCurrentPosition();
                mapController.move(LatLng(pos.latitude, pos.longitude), 16);
              },
            ),
          ),
          if(destinationMarker != null || newDestinationMarker != null)
            buttons(bt),
        ],
      ),
    );
  }
}
