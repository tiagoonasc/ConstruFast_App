import 'package:flutter/material.dart';

const Map<int, Color> _swatchOpacity = {
  50: Color.fromRGBO(139, 195, 74, .1),
  100: Color.fromRGBO(139, 195, 74, .2),
  200: Color.fromRGBO(139, 195, 74, .3),
  300: Color.fromRGBO(139, 195, 74, .4),
  400: Color.fromRGBO(139, 195, 74, .5),
  500: Color.fromRGBO(139, 195, 74, .6),
  600: Color.fromRGBO(139, 195, 74, .7),
  700: Color.fromRGBO(139, 195, 74, .8),
  800: Color.fromRGBO(139, 195, 74, .9),
  900: Color.fromRGBO(139, 195, 74, 1),
};

abstract class CustomColors {
  static const Color customContrastColor = Color(0xFFD32F2F); // vermelho.shade700
  static const MaterialColor customSwatchColor = MaterialColor(0xFF8BC34A, _swatchOpacity);
}
