import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'search_bar.dart';
import 'settings.dart';
import 'survey.dart';

class Home extends StatefulWidget {
  Home({Key key, this.title}) : super(key: key);

  final String title;

  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Completer<GoogleMapController> _mapController = Completer();
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  bool _showNewSurvey = false;
  LatLng _curPos;
  String _addr;
  String _mapStyle;
  MapType _currentMapType = MapType.normal;

  BitmapDescriptor surveyNew;
  BitmapDescriptor surveyComplete;

  void loadMapStyle(String file) async {
    rootBundle.loadString(file).then((x) => {_mapStyle = x});
  }

  @override
  void initState() {
    super.initState();
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration(size: Size(48, 48)), 'assets/survey_new.bmp')
        .then((onValue) {
      surveyNew = onValue;
    });
    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(48, 48)),
            'assets/survey_complete.bmp')
        .then((onValue) {
      surveyComplete = onValue;
    });
  }

  Future<String> _getAddress(LatLng latlng) async {
    final coords = new Coordinates(latlng.latitude, latlng.longitude);
    var addresses = await Geocoder.local.findAddressesFromCoordinates(coords);
    var first = addresses.first;
    // refactor pls
    if (first.subThoroughfare != null)
      return "${first.subThoroughfare} ${first.thoroughfare}, ${first.locality}";
    else
      return "${first.thoroughfare}, ${first.locality}";
  }

  Future<void> _addMarker(LatLng latlng) async {
    _curPos = latlng;
    _addr = await _getAddress(_curPos);
    setState(() {
      _markers.clear();
      _circles.clear();
      _markers.add(Marker(
        markerId: MarkerId(latlng.toString()),
        position: latlng,
        icon: surveyNew,
      ));
      _circles.add(Circle(
        circleId: CircleId(latlng.toString()),
        center: latlng,
        radius: 200.0,
        fillColor: Colors.blueAccent.withOpacity(0.5),
        strokeWidth: 3,
        strokeColor: Colors.blueAccent,
      ));
      _showNewSurvey = true;
    });
  }

  Future<void> _updateCamera(String input) async {
    var addresses = await Geocoder.local.findAddressesFromQuery(input);
    var coords = addresses.first.coordinates;
    print('Query "$input" returned (${coords.longitude}, ${coords.latitude})');
    LatLng latlng = LatLng(coords.latitude, coords.longitude);
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: latlng, zoom: 15)));
    _addMarker(latlng);
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
    _curPos = LatLng(_locationData.latitude, _locationData.longitude);
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _curPos, zoom: 15)));
  }

  Future<void> _updateMap() async {
    GoogleMapController controller = await _mapController.future;
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
              markers: _markers,
              circles: _circles,
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
                controller.setMapStyle(_mapStyle);
              },
              onTap: (LatLng latlng) {
                print("I got tapped @ $latlng");
                _addMarker(latlng);
                _updateCamera(latlng.toString());
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
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Settings(_updateMap),
                  ),
                );
              },
            )
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedOpacity(
              opacity: _showNewSurvey ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              child: FloatingActionButton(
                  heroTag: 'newSurvey',
                  onPressed: () {
                    if (_showNewSurvey)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Survey(
                              address: _addr,
                              page: 0,
                              editMode: false), // Go to survey page
                        ),
                      );
                  },
                  child: Icon(Icons.add_circle)),
            ),
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
