import 'package:cliqueledger/themes/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark
            ? darkTheme
            : lightTheme;

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData){
    _themeData = themeData;
    notifyListeners();
  }

  void toggleMode(){
    themeData = themeData == lightTheme? darkTheme : lightTheme;
  }
}