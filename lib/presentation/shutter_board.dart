import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/shutter_level.dart';
import '../game/game_controller.dart';
import 'shutter_theme.dart';

class ShutterBoard extends StatefulWidget {
  const ShutterBoard({required this.controller, super.key});
  final GameController controller;

  @override
  State<ShutterBoard> createState() => _ShutterBoardState();
}

class _ShutterBoardState extends State<ShutterBoard> with SingleTickerProviderStateMixin {
  late final AnimationController _snapController;
  late List<double> _visualNotches;
  int? _draggedPlate;
  int? _snappingPlate;
  double _snapFrom = 0;
  double _snapTo = 0;
  double _dragStartNotch = 0;
  double _dragDistance = 0;

  @override
  void initState() {
    super.initState();
    _visualNotches = widget.controller.positions.map((value) => value.toDouble()).toList();
    _snapController = AnimationController(vsync: this, duration: const Duration(milliseconds: 140))
      ..addListener(() {
        final index = _snappingPlate;
        if (index == null) return;
        setState(() {
          final progress = Curves.easeOutCubic.transform(_snapController.value);
          _visualNotches[index] = _snapFrom + (_snapTo - _snapFrom) * progress;
        });
      })
      ..addStatusListener((status) {
        if (status != AnimationStatus.completed) return;
        final index = _snappingPlate;
        if (index == null) return;
        _snappingPlate = null;
        widget.controller.movePlate(index, _snapTo.round());
      });
    widget.controller.addListener(_syncFromController);
  }

  @override
  void didUpdateWidget(covariant ShutterBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_syncFromController);
      widget.controller.addListener(_syncFromController);
      _syncFromController();
    }
  }

  void _syncFromController() {
    if (_draggedPlate != null || _snapController.isAnimating) return;
    setState(() {
      _visualNotches = widget.controller.positions.map((value) => value.toDouble()).toList();
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncFromController);
    _snapController.dispose();
    super.dispose();
  }

  int _pickPlate(Offset point, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = (point.dx - center.dx).abs();
    final dy = (point.dy - center.dy).abs();
    final preferredAxis = dx > dy ? PlateAxis.horizontal : PlateAxis.vertical;
    final preferred = widget.controller.level.plates.indexWhere((p) => p.axis == preferredAxis);
    return preferred >= 0 ? preferred : 0;
  }

  void _start(DragStartDetails details, Size size) {
    final index = _pickPlate(details.localPosition, size);
    _snapController.stop();
    setState(() {
      _draggedPlate = index;
      _dragStartNotch = _visualNotches[index];
      _dragDistance = 0;
    });
    HapticFeedback.selectionClick();
  }

  void _update(DragUpdateDetails details, Size size) {
    final index = _draggedPlate;
    if (index == null) return;
    final plate = widget.controller.level.plates[index];
    final delta = plate.axis == PlateAxis.horizontal ? details.delta.dx : details.delta.dy;
    _dragDistance += delta;
    final notchSpacing = size.shortestSide * .13;
    setState(() {
      _visualNotches[index] =
          (_dragStartNotch + _dragDistance / notchSpacing).clamp(0, plate.notchCount - 1);
    });
  }

  void _end(DragEndDetails details) {
    final index = _draggedPlate;
    if (index == null) return;
    final from = _visualNotches[index];
    final target = from.round().toDouble();
    setState(() {
      _draggedPlate = null;
      _snappingPlate = index;
      _snapFrom = from;
      _snapTo = target;
    });
    _snapController
      ..reset()
      ..animateTo(1, curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      final roundedPositions = _visualNotches.map((value) => value.round()).toList(growable: false);
      return Semantics(
        label: 'Shutter mechanism. Drag horizontally or vertically to move a plate.',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) => _start(details, size),
          onPanUpdate: (details) => _update(details, size),
          onPanEnd: _end,
          child: CustomPaint(
            painter: ShutterBoardPainter(
              level: widget.controller.level,
              visualNotches: _visualNotches,
              visibleLights: widget.controller.level.visibleLights(roundedPositions),
              draggedPlate: _draggedPlate,
              hint: widget.controller.hint,
              solved: widget.controller.solved,
            ),
          ),
        ),
      );
    });
  }
}

class ShutterBoardPainter extends CustomPainter {
  const ShutterBoardPainter({
    required this.level,
    required this.visualNotches,
    required this.visibleLights,
    required this.draggedPlate,
    required this.hint,
    required this.solved,
  });

  final ShutterLevel level;
  final List<double> visualNotches;
  final List<bool> visibleLights;
  final int? draggedPlate;
  final PlateMove? hint;
  final bool solved;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Offset.zero & size;
    final frame = RRect.fromRectAndRadius(outer.deflate(size.width * .015), Radius.circular(size.width * .075));
    canvas.drawShadow(
      Path()..addRRect(frame),
      Colors.black.withValues(alpha: .22),
      12,
      false,
    );
    canvas.drawRRect(
      frame,
      Paint()..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [ShutterColors.surfaceLight, ShutterColors.surface, Color(0xFFD8D2C7)],
      ).createShader(outer),
    );

    final rimRect = outer.deflate(size.width * .065);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rimRect, Radius.circular(size.width * .045)),
      Paint()..color = ShutterColors.brassDark,
    );
    final cavity = rimRect.deflate(size.width * .012);
    canvas.drawRRect(
      RRect.fromRectAndRadius(cavity, Radius.circular(size.width * .037)),
      Paint()..shader = const RadialGradient(
        colors: [ShutterColors.cavityLight, ShutterColors.cavity],
        radius: .95,
      ).createShader(cavity),
    );

    _drawLamps(canvas, cavity);
    for (var index = level.plates.length - 1; index >= 0; index--) {
      _drawPlate(canvas, cavity, index);
    }
    _drawFrameHighlight(canvas, frame);
  }

  void _drawLamps(Canvas canvas, Rect cavity) {
    final cellW = cavity.width / level.columns;
    final cellH = cavity.height / level.rows;
    for (var row = 0; row < level.rows; row++) {
      for (var column = 0; column < level.columns; column++) {
        final index = row * level.columns + column;
        final center = Offset(cavity.left + (column + .5) * cellW, cavity.top + (row + .5) * cellH);
        final radius = math.min(cellW, cellH) * .09;
        if (visibleLights[index]) {
          canvas.drawCircle(
            center,
            radius * 3,
            Paint()..shader = RadialGradient(colors: [
              ShutterColors.lightOn.withValues(alpha: solved ? .28 : .2),
              Colors.transparent,
            ]).createShader(Rect.fromCircle(center: center, radius: radius * 3)),
          );
          canvas.drawCircle(center, radius, Paint()..color = ShutterColors.lightOn);
          canvas.drawCircle(center.translate(-radius * .18, -radius * .18), radius * .34, Paint()..color = ShutterColors.lightCore);
        } else {
          canvas.drawCircle(center, radius * 1.08, Paint()..color = const Color(0xFF171713));
          canvas.drawCircle(
            center,
            radius * .7,
            Paint()..color = ShutterColors.lightOff.withValues(alpha: .52),
          );
        }
      }
    }
  }

  void _drawPlate(Canvas canvas, Rect cavity, int index) {
    final plate = level.plates[index];
    final notch = visualNotches[index];
    final midpoint = (plate.notchCount - 1) / 2;
    final offset = (notch - midpoint) * cavity.shortestSide * .13;
    final isHorizontal = plate.axis == PlateAxis.horizontal;
    final rect = Rect.fromCenter(
      center: cavity.center + (isHorizontal ? Offset(offset, -cavity.height * .13) : Offset(cavity.width * .13, offset)),
      width: isHorizontal ? cavity.width * .82 : cavity.width * .28,
      height: isHorizontal ? cavity.height * .28 : cavity.height * .82,
    );
    final elevated = draggedPlate == index;
    final platePath = Path()..addRRect(RRect.fromRectAndRadius(rect.translate(0, elevated ? -2 : 0), Radius.circular(cavity.width * .035)));
    final nearest = notch.round().clamp(0, plate.notchCount - 1);
    final mask = plate.masks[nearest];
    final cellW = cavity.width / level.columns;
    final cellH = cavity.height / level.rows;
    for (var cell = 0; cell < mask.length; cell++) {
      if (!mask[cell]) continue;
      final row = cell ~/ level.columns;
      final column = cell % level.columns;
      final holeCenter = Offset(cavity.left + (column + .5) * cellW, cavity.top + (row + .5) * cellH);
      if (rect.inflate(cellW * .12).contains(holeCenter)) {
        platePath.addOval(Rect.fromCircle(center: holeCenter, radius: math.min(cellW, cellH) * .135));
      }
    }
    platePath.fillType = PathFillType.evenOdd;
    canvas.drawShadow(
      platePath,
      Colors.black.withValues(alpha: elevated ? .48 : .32),
      elevated ? 7 : 4,
      false,
    );
    canvas.drawPath(
      platePath,
      Paint()..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF9F6F0), Color(0xFFE2DDD3), Color(0xFFCFC8BC)],
      ).createShader(rect),
    );
    canvas.drawPath(
      platePath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: .55),
    );

    final railStart = isHorizontal
        ? Offset(cavity.left + 18, rect.center.dy)
        : Offset(rect.center.dx, cavity.top + 18);
    final railEnd = isHorizontal
        ? Offset(cavity.right - 18, rect.center.dy)
        : Offset(rect.center.dx, cavity.bottom - 18);
    canvas.drawLine(
      railStart,
      railEnd,
      Paint()
        ..color = ShutterColors.brassDark.withValues(alpha: .55)
        ..strokeWidth = 2,
    );
    for (var notchIndex = 0; notchIndex < plate.notchCount; notchIndex++) {
      final t = plate.notchCount == 1 ? .5 : notchIndex / (plate.notchCount - 1);
      final marker = Offset.lerp(railStart, railEnd, .34 + t * .32)!;
      final highlighted = hint?.plateIndex == index && hint?.notch == notchIndex;
      canvas.drawCircle(
        marker,
        highlighted ? 4 : 2,
        Paint()
          ..color = highlighted
              ? ShutterColors.brassLight
              : ShutterColors.brassDark.withValues(alpha: .42),
      );
    }
    final knob = rect.center;
    canvas.drawCircle(
      knob.translate(0, 2),
      12,
      Paint()..color = Colors.black.withValues(alpha: .22),
    );
    canvas.drawCircle(
      knob,
      11,
      Paint()..shader = const RadialGradient(
        center: Alignment(-.35, -.4),
        colors: [ShutterColors.brassLight, ShutterColors.brass, ShutterColors.brassDark],
      ).createShader(Rect.fromCircle(center: knob, radius: 11)),
    );
    canvas.drawCircle(
      knob.translate(-2.5, -2.5),
      2.2,
      Paint()..color = Colors.white.withValues(alpha: .35),
    );
  }

  void _drawFrameHighlight(Canvas canvas, RRect frame) {
    canvas.drawRRect(
      frame,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withValues(alpha: .72),
    );
  }

  @override
  bool shouldRepaint(ShutterBoardPainter oldDelegate) =>
      oldDelegate.visualNotches != visualNotches ||
      oldDelegate.visibleLights != visibleLights ||
      oldDelegate.draggedPlate != draggedPlate ||
      oldDelegate.hint != hint ||
      oldDelegate.solved != solved;
}
