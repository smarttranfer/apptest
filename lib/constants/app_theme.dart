import 'package:boilerplate/constants/font_family.dart';
import 'package:flutter/material.dart';
import 'font_family.dart';

final ThemeData themeData = new ThemeData(
    scaffoldBackgroundColor: Colors.white,
    fontFamily: FontFamily.productSans,
    primarySwatch: Colors.white,
    appBarTheme: AppBarTheme(
      color: Colors.white,
      iconTheme: IconThemeData(
        color: Colors.white,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: Colors.white,
      onPrimary: Colors.white,
      primaryVariant: Colors.white38,
      secondary: Colors.red,
    ),
    cardTheme: CardTheme(
      color: Colors.teal,
    ),
    iconTheme: IconThemeData(
      color: Colors.white54,
    ),
    textTheme: TextTheme(
      headline6: TextStyle(
        color: Colors.white,
        fontSize: 20.0,
      ),
    ));

final ThemeData themeDataDark = ThemeData(
  fontFamily: FontFamily.productSans,
  scaffoldBackgroundColor: Color.fromRGBO(23, 22, 27, 1),
  appBarTheme: AppBarTheme(
    color: Color.fromRGBO(23, 22, 27, 1),
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    actionsIconTheme: IconThemeData(
      color: Colors.white,
    ),
  ),
  colorScheme: ColorScheme.light(
    primary: Colors.black,
    onPrimary: Colors.black,
    primaryVariant: Colors.black,
    secondary: Colors.red,
  ),
  cardTheme: CardTheme(
    color: Colors.black,
  ),
  iconTheme: IconThemeData(
    color: Colors.white54,
  ),
  textTheme: TextTheme(
    headline6: TextStyle(
      color: Colors.white,
      fontSize: 20.0,
    ),
  ),
);
