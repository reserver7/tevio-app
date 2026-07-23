import 'package:flutter/material.dart';

abstract final class TevioRadius {
  static const small = Radius.circular(8);
  static const medium = Radius.circular(12);
  static const large = Radius.circular(16);
  static const full = Radius.circular(999);

  static const smallBorder = BorderRadius.all(small);
  static const mediumBorder = BorderRadius.all(medium);
  static const largeBorder = BorderRadius.all(large);
  static const fullBorder = BorderRadius.all(full);
}
