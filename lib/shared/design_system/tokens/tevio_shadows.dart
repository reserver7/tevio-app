import 'package:flutter/material.dart';

import 'tevio_colors.dart';

abstract final class TevioShadows {
  static const card = [
    BoxShadow(color: TevioColors.shadow, blurRadius: 16, offset: Offset(0, 8)),
  ];
}
