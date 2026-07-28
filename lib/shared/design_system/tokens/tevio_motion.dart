import 'package:flutter/animation.dart';

abstract final class TevioMotion {
  static const fast = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 220);
  static const slow = Duration(milliseconds: 420);
  static const pulse = Duration(milliseconds: 1500);

  static const pressCurve = Curves.easeOut;
  static const standardCurve = Curves.easeOutCubic;
}
