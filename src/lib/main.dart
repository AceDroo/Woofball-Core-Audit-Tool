import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

import 'home.dart';
import 'settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Settings.darkTheme = prefs.getString('darkTheme') ?? 'default';
  Settings.mapType = prefs.getString('mapType') ?? 'default';
  Settings.mapTheme = prefs.getString('mapTheme') ?? 'day';

  print(Settings.mapType);
  print(Settings.mapTheme);
  print(Settings.darkTheme);

  updateNavBar();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        accentColor: Colors.blue,
      ),
      dark: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        accentColor: Colors.blue,
      ),
      initial: AdaptiveThemeMode.system,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'Core Audit Tool',
        theme: theme,
        darkTheme: darkTheme,
        home: Home(),
      ),
    );
  }
}

void updateNavBar() async {
  final savedThemeMode = await AdaptiveTheme.getThemeMode();
  if (savedThemeMode == AdaptiveThemeMode.dark) {
    setDarkNavBar();
  } else if (savedThemeMode == AdaptiveThemeMode.light) {
    setLightNavBar();
  } else {
    if (WidgetsBinding.instance.window.platformBrightness == Brightness.dark) {
      setDarkNavBar();
    } else {
      setLightNavBar();
    }
  }
}

void setLightNavBar() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white,
  ));
}

void setDarkNavBar() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.grey[800],
  ));
}
