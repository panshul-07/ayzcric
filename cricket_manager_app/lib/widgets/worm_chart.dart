import 'dart:math';

import 'package:flutter/material.dart';

class WormChart extends StatelessWidget {
  const WormChart({
    super.key,
    required this.firstInningsRuns,
    required this.secondInningsRuns,
    required this.maxBalls,
    required this.firstLabel,
    required this.secondLabel,
  });

  final List<int> firstInningsRuns;
  final List<int> secondInningsRuns;
  final int maxBalls;
  final String firstLabel;
  final String secondLabel;

  @override
  Widget build(BuildContext context) {
    final peak = [...firstInningsRuns, ...secondInningsRuns, 1].reduce(max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          children: [
            _LegendDot(color: Colors.blue, label: firstLabel),
            _LegendDot(color: Colors.red, label: secondLabel),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 170,
          child: CustomPaint(
            painter: _WormPainter(
              firstInningsRuns: firstInningsRuns,
              secondInningsRuns: secondInningsRuns,
              maxBalls: maxBalls,
              peakRuns: peak,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label),
      ],
    );
  }
}

class _WormPainter extends CustomPainter {
  _WormPainter({
    required this.firstInningsRuns,
    required this.secondInningsRuns,
    required this.maxBalls,
    required this.peakRuns,
  });

  final List<int> firstInningsRuns;
  final List<int> secondInningsRuns;
  final int maxBalls;
  final int peakRuns;

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    final leftPad = 34.0;
    final bottomPad = 22.0;
    final chartRect = Rect.fromLTWH(
      leftPad,
      8,
      size.width - leftPad - 8,
      size.height - bottomPad - 10,
    );

    canvas.drawRect(chartRect, Paint()..color = Colors.white);

    for (var i = 0; i <= 4; i++) {
      final y = chartRect.top + chartRect.height * (i / 4);
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );
    }

    canvas.drawLine(
      Offset(chartRect.left, chartRect.bottom),
      Offset(chartRect.right, chartRect.bottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(chartRect.left, chartRect.top),
      Offset(chartRect.left, chartRect.bottom),
      axisPaint,
    );

    _drawSeries(
      canvas,
      chartRect,
      firstInningsRuns,
      Colors.blue,
      maxBalls,
      peakRuns,
    );
    _drawSeries(
      canvas,
      chartRect,
      secondInningsRuns,
      Colors.red,
      maxBalls,
      peakRuns,
    );

    final labelPainter = TextPainter(textDirection: TextDirection.ltr);
    labelPainter.text = const TextSpan(
      text: '0',
      style: TextStyle(fontSize: 10, color: Colors.black54),
    );
    labelPainter.layout();
    labelPainter.paint(canvas, Offset(8, chartRect.bottom - 6));

    labelPainter.text = TextSpan(
      text: '$peakRuns',
      style: const TextStyle(fontSize: 10, color: Colors.black54),
    );
    labelPainter.layout();
    labelPainter.paint(canvas, Offset(4, chartRect.top - 4));
  }

  void _drawSeries(
    Canvas canvas,
    Rect chartRect,
    List<int> values,
    Color color,
    int maxBalls,
    int peakRuns,
  ) {
    if (values.isEmpty) return;

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final x = chartRect.left + (i / max(1, maxBalls)) * chartRect.width;
      final y =
          chartRect.bottom - (values[i] / max(1, peakRuns)) * chartRect.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );
  }

  @override
  bool shouldRepaint(covariant _WormPainter oldDelegate) {
    return oldDelegate.firstInningsRuns != firstInningsRuns ||
        oldDelegate.secondInningsRuns != secondInningsRuns;
  }
}
