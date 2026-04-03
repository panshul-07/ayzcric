import 'dart:math';

import 'package:flutter/material.dart';

class WagonWheel extends StatelessWidget {
  const WagonWheel({
    super.key,
    required this.shotZones,
    required this.totalRuns,
    required this.totalBalls,
    required this.boundaries,
    required this.sixes,
    required this.dots,
    required this.singles,
    required this.doubles,
    required this.triples,
  });

  final Map<String, int> shotZones;
  final int totalRuns;
  final int totalBalls;
  final int boundaries;
  final int sixes;
  final int dots;
  final int singles;
  final int doubles;
  final int triples;

  @override
  Widget build(BuildContext context) {
    final totalShots = shotZones.values.fold<int>(0, (a, b) => a + b);
    final boundaryPct = totalBalls == 0 ? 0 : (boundaries * 100 / totalBalls);
    final rotationPct = totalBalls == 0
        ? 0
        : ((singles + doubles + triples) * 100 / totalBalls);
    final topZone = shotZones.entries.fold<MapEntry<String, int>>(
      const MapEntry<String, int>('straight', 0),
      (a, b) => a.value >= b.value ? a : b,
    );

    final info = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _MetricChip(label: 'Runs', value: '$totalRuns'),
        _MetricChip(label: 'Balls', value: '$totalBalls'),
        _MetricChip(label: '4s+6s', value: '$boundaries ($sixes x6)'),
        _MetricChip(
          label: 'Boundary %',
          value: '${boundaryPct.toStringAsFixed(1)}%',
        ),
        _MetricChip(
          label: 'Rotation %',
          value: '${rotationPct.toStringAsFixed(1)}%',
        ),
        _MetricChip(label: 'Dots', value: '$dots'),
        _MetricChip(
          label: 'Top Zone',
          value: '${_zoneLabel(topZone.key)} (${topZone.value})',
        ),
        _MetricChip(label: 'Shot Count', value: '$totalShots'),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 730) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: min(360, constraints.maxWidth * 0.56),
                height: 240,
                child: CustomPaint(
                  painter: _WagonWheelPainter(shotZones),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(child: info),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 235,
              child: CustomPaint(
                painter: _WagonWheelPainter(shotZones),
                child: const SizedBox.expand(),
              ),
            ),
            const SizedBox(height: 10),
            info,
          ],
        );
      },
    );
  }

  String _zoneLabel(String zone) {
    switch (zone) {
      case 'thirdman':
        return 'Third Man';
      case 'midwicket':
        return 'Midwicket';
      case 'straight':
        return 'Straight';
      case 'cover':
        return 'Cover';
      case 'square':
        return 'Square';
      case 'fine':
        return 'Fine Leg';
      default:
        return zone;
    }
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _WagonWheelPainter extends CustomPainter {
  _WagonWheelPainter(this.shotZones);

  final Map<String, int> shotZones;

  static const Map<String, _Sector> _sectors = {
    'thirdman': _Sector(startDeg: 120, endDeg: 155),
    'fine': _Sector(startDeg: 65, endDeg: 105),
    'square': _Sector(startDeg: 155, endDeg: 205),
    'cover': _Sector(startDeg: 205, endDeg: 245),
    'straight': _Sector(startDeg: 245, endDeg: 295),
    'midwicket': _Sector(startDeg: 25, endDeg: 65),
  };

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 6);
    final radius = min(size.width, size.height) * 0.34;

    final fieldFill = Paint()..color = const Color(0xFFF2FAF2);
    final boundaryLine = Paint()
      ..color = const Color(0xFF3B7A57)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius + 24, fieldFill);
    canvas.drawCircle(center, radius + 24, boundaryLine);
    canvas.drawCircle(
      center,
      radius + 8,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0x55498B6D)
        ..strokeWidth = 1.2,
    );
    canvas.drawCircle(
      center,
      radius * 0.65,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0x33498B6D)
        ..strokeWidth = 1.0,
    );

    // pitch
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 34, height: radius * 1.7),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFD8BE98),
    );

    final maxCount = max(1, shotZones.values.fold<int>(0, (a, b) => max(a, b)));

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    _sectors.forEach((name, sector) {
      final count = shotZones[name] ?? 0;
      final intensity = count / maxCount;
      final sectorRadius = radius * (0.34 + (0.62 * intensity));

      final fillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = Color.lerp(
          const Color(0xFFFFE0B2),
          const Color(0xFFE65100),
          intensity,
        )!.withValues(alpha: 0.72);

      final start = sector.startRad;
      final sweep = sector.endRad - sector.startRad;

      final rect = Rect.fromCircle(center: center, radius: sectorRadius);
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(rect, start, sweep, false)
        ..close();

      canvas.drawPath(path, fillPaint);

      // spoke edges
      final edgePaint = Paint()
        ..color = Colors.black26
        ..strokeWidth = 1;
      canvas.drawLine(
        center,
        Offset(
          center.dx + cos(start) * (radius + 24),
          center.dy + sin(start) * (radius + 24),
        ),
        edgePaint,
      );
      canvas.drawLine(
        center,
        Offset(
          center.dx + cos(start + sweep) * (radius + 24),
          center.dy + sin(start + sweep) * (radius + 24),
        ),
        edgePaint,
      );

      final mid = (sector.startRad + sector.endRad) / 2;
      final labelOffset = Offset(
        center.dx + cos(mid) * (radius + 30),
        center.dy + sin(mid) * (radius + 30),
      );

      textPainter.text = TextSpan(
        text: '${_short(name)} $count',
        style: const TextStyle(
          fontSize: 10.5,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout(maxWidth: 74);
      textPainter.paint(canvas, labelOffset);
    });

    final compass = TextPainter(textDirection: TextDirection.ltr);
    compass.text = const TextSpan(
      text: 'Batter',
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Colors.black54,
      ),
    );
    compass.layout();
    compass.paint(
      canvas,
      Offset(center.dx - compass.width / 2, center.dy + radius + 30),
    );
  }

  String _short(String zone) {
    switch (zone) {
      case 'thirdman':
        return '3rd';
      case 'midwicket':
        return 'MW';
      case 'straight':
        return 'ST';
      case 'cover':
        return 'CV';
      case 'square':
        return 'SQ';
      case 'fine':
        return 'FN';
      default:
        return zone;
    }
  }

  @override
  bool shouldRepaint(covariant _WagonWheelPainter oldDelegate) {
    return oldDelegate.shotZones != shotZones;
  }
}

class _Sector {
  const _Sector({required this.startDeg, required this.endDeg});

  final double startDeg;
  final double endDeg;

  double get startRad => startDeg * pi / 180;
  double get endRad => endDeg * pi / 180;
}
