import 'dart:math';

import 'package:flutter/material.dart';

class WagonWheel extends StatelessWidget {
  const WagonWheel({super.key, required this.shotZones});

  final Map<String, int> shotZones;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: CustomPaint(
        painter: _WagonWheelPainter(shotZones),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _WagonWheelPainter extends CustomPainter {
  _WagonWheelPainter(this.shotZones);

  final Map<String, int> shotZones;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.36;

    final pitchPaint = Paint()
      ..color = const Color(0xFFD8BC8D)
      ..style = PaintingStyle.fill;

    final fieldPaint = Paint()
      ..color = const Color(0xFFEAF6EA)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius + 20, fieldPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 30, height: radius * 1.8),
        const Radius.circular(6),
      ),
      pitchPaint,
    );

    final zones = <String, double>{
      'thirdman': pi * 1.1,
      'fine': pi * 0.78,
      'square': pi * 1.4,
      'cover': pi * 1.72,
      'straight': pi * 1.95,
      'midwicket': pi * 0.35,
    };

    final maxCount = shotZones.values.fold<int>(1, max);
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    zones.forEach((zone, angle) {
      final count = (shotZones[zone] ?? 0);
      final strength = count / maxCount;
      final len = radius * (0.3 + strength * 0.9);
      final end = Offset(
        center.dx + cos(angle) * len,
        center.dy + sin(angle) * len,
      );

      linePaint
        ..color = Color.lerp(
          Colors.orange.shade200,
          Colors.red.shade700,
          strength,
        )!
        ..strokeWidth = 1.5 + strength * 5;

      canvas.drawLine(center, end, linePaint);

      final labelOffset = Offset(
        center.dx + cos(angle) * (radius + 14),
        center.dy + sin(angle) * (radius + 14),
      );
      textPainter.text = TextSpan(
        text: '$zone ($count)',
        style: const TextStyle(fontSize: 10, color: Colors.black87),
      );
      textPainter.layout(maxWidth: 90);
      textPainter.paint(canvas, labelOffset);
    });
  }

  @override
  bool shouldRepaint(covariant _WagonWheelPainter oldDelegate) {
    return oldDelegate.shotZones != shotZones;
  }
}
