import 'package:flutter/material.dart';

import '../tokens/tevio_colors.dart';
import '../tokens/tevio_typography.dart';

enum TevioLogoVariant { symbol, korean, english }

class TevioLogo extends StatelessWidget {
  const TevioLogo({
    super.key,
    this.variant = TevioLogoVariant.symbol,
    this.size = 36,
    this.foregroundColor = TevioColors.primary,
    this.pointColor = TevioColors.mint,
    this.textColor = TevioColors.deepNavy,
  });

  final TevioLogoVariant variant;
  final double size;
  final Color foregroundColor;
  final Color pointColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final symbol = SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _TevioSymbolPainter(
          foregroundColor: foregroundColor,
          pointColor: pointColor,
        ),
      ),
    );

    if (variant == TevioLogoVariant.symbol) {
      return Semantics(label: '테비오', child: symbol);
    }

    final text = variant == TevioLogoVariant.korean ? '테비오' : 'Tevio';

    return Semantics(
      label: text,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          symbol,
          SizedBox(width: size * 0.22),
          Text(
            text,
            style: TevioTypography.titleLarge.copyWith(
              color: textColor,
              fontSize: size * 0.58,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TevioSymbolPainter extends CustomPainter {
  const _TevioSymbolPainter({
    required this.foregroundColor,
    required this.pointColor,
  });

  final Color foregroundColor;
  final Color pointColor;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.shortestSide;
    final paint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = unit * 0.22;

    final stem = Path()
      ..moveTo(unit * 0.40, unit * 0.22)
      ..lineTo(unit * 0.40, unit * 0.66)
      ..cubicTo(
        unit * 0.40,
        unit * 0.78,
        unit * 0.52,
        unit * 0.84,
        unit * 0.68,
        unit * 0.76,
      );

    canvas.drawPath(stem, paint);
    canvas.drawLine(
      Offset(unit * 0.22, unit * 0.42),
      Offset(unit * 0.62, unit * 0.42),
      paint,
    );

    canvas.drawCircle(
      Offset(unit * 0.76, unit * 0.30),
      unit * 0.075,
      Paint()..color = pointColor,
    );
  }

  @override
  bool shouldRepaint(covariant _TevioSymbolPainter oldDelegate) {
    return foregroundColor != oldDelegate.foregroundColor ||
        pointColor != oldDelegate.pointColor;
  }
}
