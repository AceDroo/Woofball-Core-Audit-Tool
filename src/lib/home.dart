import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';

import 'search_bar.dart';
import 'survey.dart';
import 'settings.dart';

class Home extends StatefulWidget {
  Home();
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Completer<GoogleMapController> _mapController = Completer();
  GoogleMapController controller;

  void loadMapStyle(String file) async {
    rootBundle.loadString(file).then((x) => {_mapStyle = x});
  }

  Future<void> _updateCamera(String input) async {
    var addresses = await Geocoder.local.findAddressesFromQuery(input);
    var coords = addresses.first.coordinates;
    print('Query "$input" returned (${coords.longitude}, ${coords.latitude})');
    controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(coords.latitude, coords.longitude), zoom: 15)));
  }

  _updateLocation() async {
    Location _location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permission;
    LocationData _locationData;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permission = await _location.hasPermission();
    if (_permission == PermissionStatus.denied) {
      _permission = await _location.requestPermission();
      if (_permission != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await _location.getLocation();
    controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(_locationData.latitude, _locationData.longitude),
        zoom: 15)));
  }

  Future<void> _updateMap() async {
    controller = await _mapController.future;
    setState(() {
      if (Settings.mapTheme == 'night') {
        loadMapStyle('assets/mapstyles/night.json');
        controller.setMapStyle(_mapStyle);
      } else {
        _mapStyle = '[]';
        controller.setMapStyle(_mapStyle);
      }

      if (Settings.mapType == 'satellite') {
        _currentMapType = MapType.hybrid;
      } else if (Settings.mapType == 'terrain') {
        _currentMapType = MapType.terrain;
      } else {
        _currentMapType = MapType.normal;
      }
    });
  }

  static final CameraPosition _wollongongCam =
      CameraPosition(bearing: 0, target: LatLng(-34.4278, 150.8931), zoom: 10);

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  MapType _currentMapType = MapType.normal;
  String _mapStyle;

  Widget build(BuildContext context) {
    _updateMap();
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      body: Stack(
        children: <Widget>[
          Container(
            child: GoogleMap(
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              zoomControlsEnabled: false,
              initialCameraPosition: _wollongongCam,
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
                controller.setMapStyle(_mapStyle);
              },
              mapType: _currentMapType,
            ),
          ),
          SearchBar(hintText: 'Wollongong, NSW 2560', callback: _updateCamera),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                //_scaffoldKey.currentState.openDrawer();
                showModalBottomSheet<void>(
                  isScrollControlled: true,
                  /*shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(25))),*/ //uncomment to enable rounded corners
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      child: ListView(
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.account_circle),
                            title: Text('Login'),
                            onTap: () {
                              // Do something
                              Navigator.pop(context);
                            },
                          ),
                          ListTile(
                            leading: Icon(Icons.add_circle_outline),
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
                          ),
                          ListTile(
                            leading: Icon(Icons.collections_bookmark),
                            title: Text("View Drafts"),
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
                          ),
                          ListTile(
                            leading: Icon(Icons.settings),
                            title: Text('Settings'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Settings(this
                                        ._updateMap)), // Go to settings page
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FloatingActionButton(
                heroTag: 'newSurvey',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Survey(
                              page: 0,
                              editMode: false,
                            )), // Go to survey page
                  );
                },
                child: Icon(Icons.add_circle)),
            SizedBox(height: 10),
            FloatingActionButton(
                heroTag: 'getLocation',
                onPressed: () {
                  _updateLocation();
                },
                child: Icon(Icons.my_location)),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
