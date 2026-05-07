import 'dart:ui';

import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final List<double> barHeights;
  final double progressPercent;
  final Color playedColor;
  final Color unplayedColor;

  WaveformPainter({
    required this.barHeights,
    required this.progressPercent,
    required this.playedColor,
    required this.unplayedColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final double barWidth = 3.0;
    final double spacing = 2.0;
    final double totalBarWidth = barWidth + spacing;

    final int count = (size.width / totalBarWidth).floor();

    for (int i = 0; i < count; i++) {
      double baseHeightFactor = barHeights[i % barHeights.length];
      baseHeightFactor = baseHeightFactor.clamp(0.2, 1.0);

      final double barHeight = size.height * baseHeightFactor;
      final double x = i * totalBarWidth;
      final double y = (size.height - barHeight) / 2;

      // Fill color based on progress percentage
      final double currentPosPercent = i / count;
      if (currentPosPercent < progressPercent) {
        paint.color = playedColor;
      } else {
        paint.color = unplayedColor;
      }

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.progressPercent != progressPercent;
  }
}
