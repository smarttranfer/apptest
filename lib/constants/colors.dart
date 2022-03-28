import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // this basically makes it so you can instantiate this class

  static const Map<int, Color> orange = const <int, Color>{
    50: const Color(0xFFFCF2E7),
    100: const Color(0xFFF8DEC3),
    200: const Color(0xFFF3C89C),
    300: const Color(0xFFEEB274),
    400: const Color(0xFFEAA256),
    500: const Color(0xFFE69138),
    600: const Color(0xFFE38932),
    700: const Color(0xFFDF7E2B),
    800: const Color(0xFFDB7424),
    900: const Color(0xFFD56217),
    1000: const Color(0xFFF45302)
  };

  static const Color lightScaffoldBackground = Color.fromRGBO(245, 245, 245, 1);

  static const Color accentColor = Color.fromARGB(255, 18, 147, 246);

  static const Color hintColor = Color.fromARGB(255, 118, 130, 139);

  static const Color background1Color = Color.fromARGB(255, 24, 25, 29);

  static const Color buttonBackground1Color = Color.fromARGB(255, 42, 43, 49);
}
