import 'package:flutter/material.dart';

import '../domain/shutter_level.dart';
import 'shutter_theme.dart';

class TargetPreview extends StatelessWidget {
  const TargetPreview({required this.level, required this.confirmed, super.key});

  final ShutterLevel level;
  final bool confirmed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Target light pattern',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 78,
        height: 78,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: ShutterColors.surfaceLight,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: confirmed ? ShutterColors.brass : ShutterColors.hairline,
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x11000000), blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: CustomPaint(painter: _TargetPainter(level)),
      ),
    );
  }
}

class _TargetPainter extends CustomPainter {
  const _TargetPainter(this.level);
  final ShutterLevel level;

  @override
  void paint(Canvas canvas, Size size) {
    final stepX = size.width / level.columns;
    final stepY = size.height / level.rows;
    for (var row = 0; row < level.rows; row++) {
      for (var column = 0; column < level.columns; column++) {
        final active = level.targetPattern[row * level.columns + column];
        final center = Offset((column + .5) * stepX, (row + .5) * stepY);
        canvas.drawCircle(
          center,
          active ? 3.6 : 2.2,
          Paint()
            ..color = active
                ? ShutterColors.brass
                : ShutterColors.hairline.withValues(alpha: .35),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_TargetPainter oldDelegate) => oldDelegate.level != level;
}
