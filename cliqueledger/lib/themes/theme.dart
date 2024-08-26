import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Color.fromRGBO(244, 238, 255, 1),
    primary: Color.fromRGBO(220, 214, 247, 1),
    secondary: Color.fromRGBO(166, 177, 225, 1),
    tertiary: Color.fromRGBO(66, 72, 116, 1),
    
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(color: Colors.black),
    displayMedium: TextStyle(color: Colors.black),
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black),
    titleMedium: TextStyle(color: Colors.black),
    titleSmall: TextStyle(color: Colors.black),
    bodySmall: TextStyle(color: Colors.grey[700]),
    labelLarge: TextStyle(color: Colors.black),
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Color.fromRGBO(7, 15, 43, 1),
    primary: Color.fromRGBO(27, 26, 85, 1),
    secondary: Color.fromRGBO(83, 92, 145, 1),
    tertiary: Color.fromRGBO(146, 144, 195, 1),
    
  ),
  textTheme: TextTheme(
    displayLarge: TextStyle(color: Colors.white),
    displayMedium: TextStyle(color: Colors.white),
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
    titleMedium: TextStyle(color: Colors.white),
    titleSmall: TextStyle(color: Colors.white),
    bodySmall: TextStyle(color: Colors.grey[400]),
    labelLarge: TextStyle(color: Colors.white),
  ),
);
