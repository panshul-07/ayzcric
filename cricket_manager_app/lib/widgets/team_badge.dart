import 'dart:math';

import 'package:flutter/material.dart';

import '../game/models.dart';

class TeamBadge extends StatelessWidget {
  const TeamBadge({super.key, required this.branding, this.size = 36});

  final TeamBranding branding;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _TeamBadgePainter(branding)),
    );
  }
}

class _TeamBadgePainter extends CustomPainter {
  _TeamBadgePainter(this.branding);

  final TeamBranding branding;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = _shapePath(rect, branding.shape);

    final primary = Paint()..color = Color(branding.primaryColor);
    final secondary = Paint()..color = Color(branding.secondaryColor);
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = max(1.2, size.width * 0.06)
      ..color = Colors.black.withValues(alpha: 0.28);

    canvas.drawPath(path, primary);
    canvas.save();
    canvas.clipPath(path);
    _drawPattern(canvas, rect, secondary, branding.pattern);
    canvas.restore();
    canvas.drawPath(path, border);
    _drawEmblem(canvas, rect, branding.emblem, Color(branding.accentColor));
  }

  Path _shapePath(Rect rect, TeamBadgeShape shape) {
    switch (shape) {
      case TeamBadgeShape.circle:
        return Path()..addOval(rect);
      case TeamBadgeShape.diamond:
        return Path()
          ..moveTo(rect.center.dx, rect.top)
          ..lineTo(rect.right, rect.center.dy)
          ..lineTo(rect.center.dx, rect.bottom)
          ..lineTo(rect.left, rect.center.dy)
          ..close();
      case TeamBadgeShape.hexagon:
        final w = rect.width;
        final h = rect.height;
        return Path()
          ..moveTo(rect.left + w * 0.25, rect.top)
          ..lineTo(rect.left + w * 0.75, rect.top)
          ..lineTo(rect.right, rect.top + h * 0.5)
          ..lineTo(rect.left + w * 0.75, rect.bottom)
          ..lineTo(rect.left + w * 0.25, rect.bottom)
          ..lineTo(rect.left, rect.top + h * 0.5)
          ..close();
      case TeamBadgeShape.pentagon:
        final w = rect.width;
        final h = rect.height;
        return Path()
          ..moveTo(rect.center.dx, rect.top)
          ..lineTo(rect.right, rect.top + h * 0.4)
          ..lineTo(rect.right - w * 0.18, rect.bottom)
          ..lineTo(rect.left + w * 0.18, rect.bottom)
          ..lineTo(rect.left, rect.top + h * 0.4)
          ..close();
      case TeamBadgeShape.shield:
        final w = rect.width;
        final h = rect.height;
        return Path()
          ..moveTo(rect.left + w * 0.12, rect.top)
          ..lineTo(rect.right - w * 0.12, rect.top)
          ..lineTo(rect.right, rect.top + h * 0.34)
          ..lineTo(rect.center.dx, rect.bottom)
          ..lineTo(rect.left, rect.top + h * 0.34)
          ..close();
    }
  }

  void _drawPattern(
    Canvas canvas,
    Rect rect,
    Paint paint,
    TeamBadgePattern pattern,
  ) {
    switch (pattern) {
      case TeamBadgePattern.chevron:
        final path = Path()
          ..moveTo(rect.left - rect.width * 0.1, rect.top + rect.height * 0.48)
          ..lineTo(rect.center.dx, rect.bottom - rect.height * 0.18)
          ..lineTo(rect.right + rect.width * 0.1, rect.top + rect.height * 0.48)
          ..lineTo(rect.right + rect.width * 0.1, rect.top + rect.height * 0.66)
          ..lineTo(rect.center.dx, rect.bottom + rect.height * 0.02)
          ..lineTo(rect.left - rect.width * 0.1, rect.top + rect.height * 0.66)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case TeamBadgePattern.diagonal:
        final path = Path()
          ..moveTo(
            rect.left - rect.width * 0.15,
            rect.bottom - rect.height * 0.12,
          )
          ..lineTo(
            rect.left + rect.width * 0.18,
            rect.bottom + rect.height * 0.08,
          )
          ..lineTo(
            rect.right + rect.width * 0.15,
            rect.top + rect.height * 0.22,
          )
          ..lineTo(
            rect.right - rect.width * 0.18,
            rect.top - rect.height * 0.08,
          )
          ..close();
        canvas.drawPath(path, paint);
        break;
      case TeamBadgePattern.band:
        canvas.drawRect(
          Rect.fromLTWH(
            rect.left + rect.width * 0.38,
            rect.top - rect.height * 0.05,
            rect.width * 0.24,
            rect.height * 1.1,
          ),
          paint,
        );
        break;
    }
  }

  void _drawEmblem(
    Canvas canvas,
    Rect rect,
    TeamBadgeEmblem emblem,
    Color color,
  ) {
    final icon = switch (emblem) {
      TeamBadgeEmblem.sword => Icons.vertical_align_top_rounded,
      TeamBadgeEmblem.star => Icons.star_rounded,
      TeamBadgeEmblem.bolt => Icons.bolt_rounded,
      TeamBadgeEmblem.crown => Icons.emoji_events_rounded,
      TeamBadgeEmblem.anchor => Icons.anchor_rounded,
    };

    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: rect.width * 0.4,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: color.withValues(alpha: 0.92),
      ),
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(rect.center.dx - tp.width / 2, rect.center.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _TeamBadgePainter oldDelegate) {
    return oldDelegate.branding != branding;
  }
}
