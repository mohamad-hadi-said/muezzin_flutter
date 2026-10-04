import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:muezzin_flutter/core/theme/muezzin_theme.dart';

class QiblaCompassPainter extends CustomPainter {
  final double qiblaBearing;
  final bool isAligned;
  final double pulseValue;

  const QiblaCompassPainter({
    required this.qiblaBearing,
    required this.isAligned,
    this.pulseValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;

    // 1. Draw outer glowing halo if aligned
    if (isAligned) {
      final glowPaint = Paint()
        ..color = MuezzinTheme.successColor.withValues(alpha: 0.25 + 0.25 * pulseValue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10 + 6 * pulseValue
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(center, radius + 4, glowPaint);
    }

    // 2. Outer Dial Base Circle
    final basePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, basePaint);

    final borderPaint = Paint()
      ..color = isAligned ? MuezzinTheme.successColor : MuezzinTheme.outlineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isAligned ? 3.5 : 2.0;
    canvas.drawCircle(center, radius, borderPaint);

    // Inner decorative subtle circle
    final innerCirclePaint = Paint()
      ..color = MuezzinTheme.secondaryBackground.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.76, innerCirclePaint);

    final innerBorder = Paint()
      ..color = MuezzinTheme.outlineColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, radius * 0.76, innerBorder);

    // 3. Tick Marks and Degrees
    final tickPaint = Paint()
      ..color = MuezzinTheme.textSecondary.withValues(alpha: 0.7)
      ..strokeCap = StrokeCap.round;

    final majorTickPaint = Paint()
      ..color = MuezzinTheme.textPrimary
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (int deg = 0; deg < 360; deg += 5) {
      final rad = deg * (math.pi / 180.0);
      final isMajor = (deg % 30 == 0);
      final isCardinal = (deg % 90 == 0);
      final tickLength = isCardinal ? 14.0 : (isMajor ? 10.0 : 5.0);

      final p1 = Offset(
        center.dx + (radius - 4) * math.sin(rad),
        center.dy - (radius - 4) * math.cos(rad),
      );
      final p2 = Offset(
        center.dx + (radius - 4 - tickLength) * math.sin(rad),
        center.dy - (radius - 4 - tickLength) * math.cos(rad),
      );

      canvas.drawLine(p1, p2, isMajor ? majorTickPaint : tickPaint);
    }

    // 4. Cardinal Direction Labels (ش, ق, ج, غ)
    const cardinals = {
      0: 'ش',   // North
      90: 'ق',  // East
      180: 'ج', // South
      270: 'غ', // West
    };

    final textPainter = TextPainter(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.center,
    );

    cardinals.forEach((deg, label) {
      final rad = deg * (math.pi / 180.0);
      final offset = Offset(
        center.dx + (radius - 28) * math.sin(rad),
        center.dy - (radius - 28) * math.cos(rad),
      );

      final isNorth = deg == 0;
      textPainter.text = TextSpan(
        text: label,
        style: TextStyle(
          color: isNorth ? const Color(0xFFD32F2F) : MuezzinTheme.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(offset.dx - textPainter.width / 2, offset.dy - textPainter.height / 2),
      );
    });

    // 5. Qibla Direction Line and Kaaba Target Marker
    final qiblaRad = qiblaBearing * (math.pi / 180.0);
    final kaabaCenter = Offset(
      center.dx + (radius * 0.76) * math.sin(qiblaRad),
      center.dy - (radius * 0.76) * math.cos(qiblaRad),
    );

    // Qibla beam line
    final beamPaint = Paint()
      ..color = isAligned
          ? MuezzinTheme.successColor.withValues(alpha: 0.8)
          : MuezzinTheme.goldColor.withValues(alpha: 0.75)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, kaabaCenter, beamPaint);

    // Kaaba target emblem background
    final targetBg = Paint()
      ..color = isAligned ? MuezzinTheme.successColor : MuezzinTheme.goldColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(kaabaCenter, 14, targetBg);

    // Kaaba inner cube representation
    final cubePaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: kaabaCenter, width: 14, height: 14),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(rrect, cubePaint);

    // Golden Kiswa band on the miniature Kaaba
    final kiswaPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(kaabaCenter.dx - 6, kaabaCenter.dy - 3),
      Offset(kaabaCenter.dx + 6, kaabaCenter.dy - 3),
      kiswaPaint,
    );

    // 6. Magnetic North Pointer Needle (Red North, Slate South)
    final needlePathNorth = Path();
    needlePathNorth.moveTo(center.dx, center.dy - radius * 0.58);
    needlePathNorth.lineTo(center.dx - 9, center.dy);
    needlePathNorth.lineTo(center.dx + 9, center.dy);
    needlePathNorth.close();

    final northPaint = Paint()
      ..color = const Color(0xFFE53935)
      ..style = PaintingStyle.fill;
    canvas.drawPath(needlePathNorth, northPaint);

    final needlePathSouth = Path();
    needlePathSouth.moveTo(center.dx, center.dy + radius * 0.58);
    needlePathSouth.lineTo(center.dx - 9, center.dy);
    needlePathSouth.lineTo(center.dx + 9, center.dy);
    needlePathSouth.close();

    final southPaint = Paint()
      ..color = const Color(0xFF90A4AE)
      ..style = PaintingStyle.fill;
    canvas.drawPath(needlePathSouth, southPaint);

    // Center jewel pivot
    final pivotOuter = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 9, pivotOuter);

    final pivotInner = Paint()
      ..color = isAligned ? MuezzinTheme.successColor : MuezzinTheme.goldColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, pivotInner);
  }

  @override
  bool shouldRepaint(covariant QiblaCompassPainter oldDelegate) {
    return oldDelegate.qiblaBearing != qiblaBearing ||
        oldDelegate.isAligned != isAligned ||
        oldDelegate.pulseValue != pulseValue;
  }
}
