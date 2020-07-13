import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hatlight/providers/bt_provider.dart';
import 'package:latlong/latlong.dart';
import 'package:provider/provider.dart';

class MapFragment extends StatefulWidget {
  @override
  _MapFragmentState createState() => _MapFragmentState();
}

class _MapFragmentState extends State<MapFragment> {
  List<Marker> markers = [];
  var mapController = MapController();

  @override
  Widget build(BuildContext context) {
    var bt = Provider.of<BTProvider>(context);
    return Container(
        child: FlutterMap(
          mapController: mapController,
          options: MapOptions(
              center: LatLng(41.904088, 12.453005),
              maxZoom: 18.49,
              onTap: (tapPlace) {
            bt.targetLatLng = tapPlace;
            markers = [
                  Marker(
                    point: tapPlace,
                    builder: (ctx) =>
                        Icon(Icons.location_on, size: 40, color: Colors.black),
                  )
                ];
                setState(() {});
              }),
          layers: [
            TileLayerOptions(
              urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              subdomains: ['a', 'b', 'c'],
            ),
            MarkerLayerOptions(markers: markers)
          ],
        ));
  }
}
