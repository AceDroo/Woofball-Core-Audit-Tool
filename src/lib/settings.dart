import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'main.dart';

class Settings extends StatefulWidget {
  Settings(this._updateMap);

  static String mapType;
  static String darkTheme;
  static String mapTheme;

  static savePreference(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
    print(key + ', ' + value);
  }

  final Function _updateMap;

  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();
  }

  void updateTheme() {
    if (Settings.darkTheme == 'dark') {
      AdaptiveTheme.of(context).setDark();
      setDarkNavBar();
    } else if (Settings.darkTheme == 'light') {
      AdaptiveTheme.of(context).setLight();
      setLightNavBar();
    } else {
      var brightness = MediaQuery.of(context).platformBrightness;
      AdaptiveTheme.of(context).setSystem();
      if (brightness == Brightness.dark) {
        setDarkNavBar();
      } else {
        setLightNavBar();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: InkWell(
                child: Column(
                  children: <Widget>[
                    Text('Settings'),
                  ],
                ),
                onTap: () {
                  Navigator.pop(context);
                })),
        body: ListView(padding: const EdgeInsets.all(20), children: <Widget>[
          Text(
            'Map Type:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          DropdownButton(
            value: Settings.mapType,
            isExpanded: true,
            items: [
              new DropdownMenuItem(
                child: Text("Default"),
                value: 'default',
              ),
              new DropdownMenuItem(
                child: Text("Satellite"),
                value: 'satellite',
              ),
              new DropdownMenuItem(
                child: Text("Terrain"),
                value: 'terrain',
              ),
            ],
            hint: new Text("Map type"),
            onChanged: (value) {
              setState(() {
                Settings.mapType = value;
                Settings.savePreference('mapType', value);
                this.widget._updateMap();
              });
            },
          ),
          SizedBox(height: 24),
          if (Settings.mapType == 'default')
            ListBody(children: <Widget>[
              Text(
                'Default Map Theme:',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.left,
              ),
              DropdownButton(
                  value: Settings.mapTheme,
                  isExpanded: true,
                  items: [
                    new DropdownMenuItem(
                      child: Text("Day"),
                      value: 'day',
                    ),
                    new DropdownMenuItem(
                      child: Text("Night"),
                      value: 'night',
                    ),
                  ],
                  hint: new Text("Map Theme"),
                  onChanged: (value) {
                    setState(() {
                      Settings.mapTheme = value;
                      Settings.savePreference('mapTheme', value);
                      updateTheme();
                      this.widget._updateMap();
                    });
                  }),
              SizedBox(height: 24),
            ]),
          Text(
            'Theme:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          DropdownButton(
              value: Settings.darkTheme,
              isExpanded: true,
              items: [
                new DropdownMenuItem(
                  child: Text("System Default"),
                  value: 'default',
                ),
                new DropdownMenuItem(
                  child: Text("Light"),
                  value: 'light',
                ),
                new DropdownMenuItem(
                  child: Text("Dark"),
                  value: 'dark',
                ),
              ],
              hint: new Text("Theme"),
              onChanged: (value) {
                setState(() {
                  Settings.darkTheme = value;
                  Settings.savePreference('darkTheme', value);
                  updateTheme();
                  this.widget._updateMap();
                });
              }),
          SizedBox(height: 24),
          Text(
            'Designed by Woofball \nVersion 1.234',
            style: TextStyle(),
          ),
        ]));
  }
}
