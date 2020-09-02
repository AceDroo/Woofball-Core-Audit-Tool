import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';

import 'search_bar.dart';
import 'survey.dart';

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Completer<GoogleMapController> _mapController = Completer();

  Future<void> _updateCamera(String input) async {
    var addresses = await Geocoder.local.findAddressesFromQuery(input);
    var coords = addresses.first.coordinates;
    print(
      'Query "$input" returned (${coords.longitude}, ${coords.latitude})'
    );
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(coords.latitude, coords.longitude),
                zoom: 15
            )
        )
    );
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
    if (_permission == PermissionStatus.denied){
      _permission = await _location.requestPermission();
      if (_permission != PermissionStatus.granted){
        return;
      }
    }

    _locationData = await _location.getLocation();
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(_locationData.latitude, _locationData.longitude),
                zoom: 15
            )
        )
    );


  }

  
  static final CameraPosition _wollongongCam = CameraPosition(
		bearing: 0,
		target: LatLng(-34.4278, 150.8931),
		zoom: 10  
  ); 

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      body: Stack(
        children: <Widget>[
          Container(
            child: GoogleMap(
              compassEnabled: false,
              zoomControlsEnabled: false,
              initialCameraPosition: _wollongongCam,
							onMapCreated: (GoogleMapController controller) {
								_mapController.complete(controller);
							}, 
            ),
          ),
          SearchBar(hintText: 'Wollongong, NSW 2560', callback:_updateCamera),
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
                      builder: (context) => Survey(), // Go to survey page
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
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
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom:20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FloatingActionButton(
              heroTag: 'newSurvey',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Survey(), // Go to survey page
                  ),
                );
              },
              child: Icon(Icons.add_circle)
            ),
            SizedBox(height:10),
            FloatingActionButton(
              heroTag: 'getLocation',
              onPressed: () {
                _updateLocation();
              },
              child: Icon(Icons.my_location)
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}
