import 'package:flutter/material.dart';

class DiamondBackground extends StatelessWidget {
  const DiamondBackground({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DiamondPainter(color: Colors.black.withValues(alpha: 0.02)),
    );
  }
}

class _DiamondPainter extends CustomPainter {
  final Color color;
  _DiamondPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const double step = 75;
    final path = Path();
    for (double y = -step; y < size.height + step; y += step) {
      for (double x = -step; x < size.width + step; x += step) {
        path
          ..reset()
          ..moveTo(x, y + step / 2)
          ..lineTo(x + step / 2, y)
          ..lineTo(x + step, y + step / 2)
          ..lineTo(x + step / 2, y + step)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}