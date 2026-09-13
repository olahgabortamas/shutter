import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shutter/domain/shutter_level.dart';

void main() {
  test('campaign manifest contains ordered, valid, solvable levels', () {
    final manifest = jsonDecode(
      File('assets/levels/manifest.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final files = (manifest['levels'] as List<dynamic>).cast<String>();

    expect(files, isNotEmpty);
    for (var index = 0; index < files.length; index++) {
      final level = ShutterLevel.fromJson(
        jsonDecode(
          File('assets/levels/${files[index]}').readAsStringSync(),
        ) as Map<String, dynamic>,
      );
      expect(level.number, index + 1);
      expect(level.isSolved(level.initialPositions), isFalse);
      expect(_hasSolution(level), isTrue, reason: '${level.id} is unsolvable');
    }
  });
}

bool _hasSolution(ShutterLevel level) {
  bool visit(int plateIndex, List<int> positions) {
    if (plateIndex == level.plates.length) return level.isSolved(positions);
    for (var notch = 0;
        notch < level.plates[plateIndex].notchCount;
        notch++) {
      positions[plateIndex] = notch;
      if (visit(plateIndex + 1, positions)) return true;
    }
    return false;
  }

  return visit(0, List<int>.filled(level.plates.length, 0));
}

