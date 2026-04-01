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
    required this.firstRuns,
    required this.secondRuns,
    required this.firstBalls,
    required this.secondBalls,
    required this.projectedScore,
    this.target,
    this.requiredRate,
  });

  final List<int> firstInningsRuns;
  final List<int> secondInningsRuns;
  final int maxBalls;
  final String firstLabel;
  final String secondLabel;
  final int firstRuns;
  final int secondRuns;
  final int firstBalls;
  final int secondBalls;
  final double projectedScore;
  final int? target;
  final double? requiredRate;

  @override
  Widget build(BuildContext context) {
    final peak = [
      ...firstInningsRuns,
      ...secondInningsRuns,
      target ?? 0,
      1,
    ].reduce(max);

    final firstRr = firstBalls == 0 ? 0 : (firstRuns * 6 / firstBalls);
    final secondRr = secondBalls == 0 ? 0 : (secondRuns * 6 / secondBalls);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            _LegendDot(
              color: Colors.blue,
              label: '$firstLabel RR ${firstRr.toStringAsFixed(2)}',
            ),
            _LegendDot(
              color: Colors.red,
              label: '$secondLabel RR ${secondRr.toStringAsFixed(2)}',
            ),
            _LegendDot(
              color: Colors.deepPurple,
              label: 'Projected ${projectedScore.toStringAsFixed(0)}',
            ),
            if (target != null)
              _LegendDot(
                color: Colors.amber.shade800,
                label:
                    'Target $target${requiredRate != null ? ' | Req RR ${requiredRate!.toStringAsFixed(2)}' : ''}',
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 185,
          child: CustomPaint(
            painter: _WormPainter(
              firstInningsRuns: firstInningsRuns,
              secondInningsRuns: secondInningsRuns,
              maxBalls: maxBalls,
              peakRuns: peak,
              target: target,
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
        Text(label, style: const TextStyle(fontSize: 12)),
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
    this.target,
  });

  final List<int> firstInningsRuns;
  final List<int> secondInningsRuns;
  final int maxBalls;
  final int peakRuns;
  final int? target;

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 1;
    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    final leftPad = 34.0;
    final rightPad = 10.0;
    final bottomPad = 26.0;
    final topPad = 10.0;
    final chartRect = Rect.fromLTWH(
      leftPad,
      topPad,
      size.width - leftPad - rightPad,
      size.height - bottomPad - topPad,
    );

    canvas.drawRect(chartRect, Paint()..color = Colors.white);

    for (var i = 0; i <= 5; i++) {
      final y = chartRect.top + chartRect.height * (i / 5);
      canvas.drawLine(
        Offset(chartRect.left, y),
        Offset(chartRect.right, y),
        gridPaint,
      );
    }

    for (var i = 0; i <= 4; i++) {
      final x = chartRect.left + chartRect.width * (i / 4);
      canvas.drawLine(
        Offset(x, chartRect.top),
        Offset(x, chartRect.bottom),
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

    if (target != null) {
      final targetY =
          chartRect.bottom - (target! / max(1, peakRuns)) * chartRect.height;
      final targetPaint = Paint()
        ..color = Colors.amber.shade700
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;
      canvas.drawLine(
        Offset(chartRect.left, targetY),
        Offset(chartRect.right, targetY),
        targetPaint,
      );
    }

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

    labelPainter.text = TextSpan(
      text: '${(maxBalls / 6).round()} ov',
      style: const TextStyle(fontSize: 10, color: Colors.black54),
    );
    labelPainter.layout();
    labelPainter.paint(
      canvas,
      Offset(chartRect.right - 26, chartRect.bottom + 4),
    );
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
        ..strokeWidth = 2.4,
    );

    final lastX =
        chartRect.left +
        ((values.length - 1) / max(1, maxBalls)) * chartRect.width;
    final lastY =
        chartRect.bottom - (values.last / max(1, peakRuns)) * chartRect.height;
    canvas.drawCircle(Offset(lastX, lastY), 3.3, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _WormPainter oldDelegate) {
    return oldDelegate.firstInningsRuns != firstInningsRuns ||
        oldDelegate.secondInningsRuns != secondInningsRuns ||
        oldDelegate.target != target;
  }
}
