import 'dart:math' as math;
import 'package:flutter/material.dart';

class PercentGauge extends StatelessWidget {
  final double percent; // 0..100
  final double size; // diameter
  final double stroke; // ring thickness
  final Color color; // progress color
  final Color trackColor; // background ring
  final Widget? center; // content inside the ring (e.g., % text)

  const PercentGauge({
    super.key,
    required this.percent,
    required this.color,
    this.size = 160,
    this.stroke = 12,
    this.trackColor = const Color(0xFFF3F4F6), // grey100-ish
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    final p = percent.clamp(0, 100) / 100.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(
              value: p,
              color: color,
              trackColor: trackColor,
              stroke: stroke,
            ),
          ),
          // Center white “disk” like your design
          Container(
            width: size - stroke * 2,
            height: size - stroke * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Colors.white, const Color(0xFFF3F4F6)],
              ),
            ),
          ),
          if (center != null) center!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value; // 0..1
  final double stroke;
  final Color color;
  final Color trackColor;

  _RingPainter({
    required this.value,
    required this.color,
    required this.trackColor,
    this.stroke = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - stroke;

    final bgPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..shader = LinearGradient(
        colors: [color, color.withOpacity(0.7)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    // background
    canvas.drawCircle(center, radius, bgPaint);

    // progress arc (start at -90°)
    final sweep = 2 * math.pi * value;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.value != value ||
      old.color != color ||
      old.trackColor != trackColor ||
      old.stroke != stroke;
}
