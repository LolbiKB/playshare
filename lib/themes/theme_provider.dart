import 'package:flutter/material.dart';
import 'package:playshare/themes/light_mode.dart';
import 'package:playshare/themes/dark_mode.dart';

class ThemeProvider extends ChangeNotifier {
  //lightMode - default
  ThemeData _themeData = lightMode;

  //get theme
  ThemeData get themeData => _themeData;

  //is dark mode
  bool get isDarkMode => _themeData == darkMode;

  set themeData(ThemeData themedata) {
    _themeData = themedata;

    //update UI
    notifyListeners();
  }

  //toggle theme
  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
