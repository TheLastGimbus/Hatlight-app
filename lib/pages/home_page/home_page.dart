import 'package:flutter/material.dart';
import 'package:hatlight/pages/home_page/colors_fragment.dart';
import 'package:hatlight/pages/home_page/connection_app_bar.dart';
import 'package:hatlight/pages/home_page/map_fragment.dart';
import 'package:hatlight/pages/home_page/settings_fragment.dart';
import 'package:hatlight/providers/bt_provider.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _picked = 0;
  var loc = Location();
  var currentIndex = 0;

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
      appBar: connectionAppBar(context),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Flexible(
              child: Stack(
                children: <Widget>[
                  IndexedStack(
                    index: currentIndex,
                    children: <Widget>[
                      MapFragment(),
                      ColorsFragment(),
                      SettingsFragment(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.map), title: Text('Map')),
          BottomNavigationBarItem(
            icon: Icon(Icons.color_lens),
            title: Text('Colors'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            title: Text('Settings'),
          ),
        ],
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
      ),
    );
  }
}
