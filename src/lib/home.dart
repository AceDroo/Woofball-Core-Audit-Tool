import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';
import 'package:location/location.dart';

import 'survey.dart';

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static LatLng london = LatLng(51.5, -0.09);

  MapController mapController = MapController();

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      //appBar: AppBar(title: const Text('Search here?')),
      extendBody: true,
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: LatLng(-34.405, 150.8785),
              zoom: 10.0,
              minZoom: 2.0,
            ),
            layers: [
              TileLayerOptions(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c']),
              MarkerLayerOptions(
                markers: [
                  Marker(
                    point: LatLng(-34.405, 150.8785),
                    builder: (ctx) => Container(
                      child: Icon(Icons.location_on),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text('Login'),
              onTap: () {
                // Do something
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Settings'),
              onTap: () {
                // Do something
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text("Create Audit"),
              onTap: () {
                Navigator.pop(context); // Closes drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Survey(
                        page: 0,
                        editMode: false,
                      )), // Go to survey page
                );
              },
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                _scaffoldKey.currentState.openDrawer();
              },
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                mapController.move(london, 18.0);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            updateLocation();
          },
          child: Icon(Icons.my_location)),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  updateLocation() async{
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    mapController.move(LatLng(_locationData.latitude, _locationData.longitude), 16.0);
  }
}