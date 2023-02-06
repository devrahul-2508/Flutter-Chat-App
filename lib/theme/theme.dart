import 'package:flutter/material.dart';

class MyTheme {
  static ThemeData appTheme(BuildContext context) => ThemeData(
      brightness: Brightness.dark,
      accentColor: accentColour,
      backgroundColor: backgroundColour,
      iconTheme: IconThemeData(color: Colors.white),
      appBarTheme: AppBarTheme(
          color: backgroundColour,
          elevation: 0.0,
          iconTheme: IconThemeData(color: Colors.white)));

  static Color accentColour = Color(0xffb9f85ff);
  static Color backgroundColour = Color(0xffb1d1b25);
}
