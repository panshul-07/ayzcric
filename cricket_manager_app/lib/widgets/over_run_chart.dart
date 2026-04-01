import 'dart:math';

import 'package:flutter/material.dart';

class OverRunChart extends StatelessWidget {
  const OverRunChart({super.key, required this.overRuns, required this.label});

  final List<int> overRuns;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Over-by-over runs: $label',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 145,
          child: CustomPaint(
            painter: _OverRunPainter(overRuns),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

class _OverRunPainter extends CustomPainter {
  _OverRunPainter(this.overRuns);

  final List<int> overRuns;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, Paint()..color = Colors.white);

    if (overRuns.isEmpty) return;

    final maxRun = max(1, overRuns.reduce(max));
    final barWidth = size.width / max(1, overRuns.length * 1.2);

    for (int i = 0; i < overRuns.length; i++) {
      final value = overRuns[i];
      final height = (value / maxRun) * (size.height - 26);
      final x = i * barWidth * 1.2 + 6;
      final y = size.height - height - 18;

      final color = Color.lerp(
        Colors.teal.shade200,
        Colors.teal.shade800,
        value / maxRun,
      )!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, height),
          const Radius.circular(4),
        ),
        Paint()..color = color,
      );

      if (i % 2 == 0 || overRuns.length <= 8) {
        final tp = TextPainter(
          text: TextSpan(
            text: '${i + 1}',
            style: const TextStyle(fontSize: 9, color: Colors.black54),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x, size.height - 15));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _OverRunPainter oldDelegate) {
    return oldDelegate.overRuns != overRuns;
  }
}
