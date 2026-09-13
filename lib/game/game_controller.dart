import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../domain/shutter_level.dart';

class PlateMove {
  const PlateMove(this.plateIndex, this.notch);

  final int plateIndex;
  final int notch;
}

class GameController extends ChangeNotifier {
  GameController(this.level) : _positions = List<int>.of(level.initialPositions);

  final ShutterLevel level;
  List<int> _positions;
  final List<List<int>> _history = [];
  PlateMove? _hint;

  List<int> get positions => List<int>.unmodifiable(_positions);
  List<bool> get visibleLights => level.visibleLights(_positions);
  bool get solved => level.isSolved(_positions);
  bool get canUndo => _history.isNotEmpty;
  PlateMove? get hint => _hint;

  void movePlate(int plateIndex, int notch) {
    final plate = level.plates[plateIndex];
    final next = notch.clamp(0, plate.notchCount - 1) as int;
    if (_positions[plateIndex] == next) return;
    _history.add(List<int>.of(_positions));
    _positions[plateIndex] = next;
    _hint = null;
    HapticFeedback.lightImpact();
    if (solved) HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void undo() {
    if (_history.isEmpty) return;
    _positions = _history.removeLast();
    _hint = null;
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  void reset() {
    if (listEquals(_positions, level.initialPositions)) return;
    _history.add(List<int>.of(_positions));
    _positions = List<int>.of(level.initialPositions);
    _hint = null;
    HapticFeedback.selectionClick();
    notifyListeners();
  }

  PlateMove? requestHint() {
    _hint = _findFirstMoveToSolution();
    if (_hint != null) HapticFeedback.selectionClick();
    notifyListeners();
    return _hint;
  }

  PlateMove? _findFirstMoveToSolution() {
    final start = List<int>.of(_positions);
    if (level.isSolved(start)) return null;
    final queue = Queue<({List<int> state, PlateMove? first})>()
      ..add((state: start, first: null));
    final visited = <String>{start.join(',')};

    while (queue.isNotEmpty) {
      final node = queue.removeFirst();
      for (var plateIndex = 0; plateIndex < level.plates.length; plateIndex++) {
        final plate = level.plates[plateIndex];
        for (var notch = 0; notch < plate.notchCount; notch++) {
          if (notch == node.state[plateIndex]) continue;
          final next = List<int>.of(node.state)..[plateIndex] = notch;
          if (!visited.add(next.join(','))) continue;
          final first = node.first ?? PlateMove(plateIndex, notch);
          if (level.isSolved(next)) return first;
          queue.add((state: next, first: first));
        }
      }
    }
    return null;
  }
}
