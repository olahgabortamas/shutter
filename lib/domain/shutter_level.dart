enum PlateAxis { horizontal, vertical }

class PlateDefinition {
  const PlateDefinition({
    required this.id,
    required this.axis,
    required this.notchCount,
    required this.initialNotch,
    required this.masks,
  });

  final String id;
  final PlateAxis axis;
  final int notchCount;
  final int initialNotch;
  final List<List<bool>> masks;

  factory PlateDefinition.fromJson(Map<String, dynamic> json, int cellCount) {
    final rawMasks = json['masks'] as List<dynamic>;
    final masks = rawMasks
        .map((mask) => (mask as List<dynamic>).map((value) => value == 1).toList())
        .toList(growable: false);
    final notches = json['notches'] as int;
    if (masks.length != notches || masks.any((mask) => mask.length != cellCount)) {
      throw const FormatException('Every notch needs one board-sized mask.');
    }
    return PlateDefinition(
      id: json['id'] as String,
      axis: switch (json['axis']) {
        'horizontal' => PlateAxis.horizontal,
        'vertical' => PlateAxis.vertical,
        _ => throw const FormatException('Unknown plate axis.'),
      },
      notchCount: notches,
      initialNotch: json['start'] as int,
      masks: masks,
    );
  }
}

class ShutterLevel {
  const ShutterLevel({
    required this.id,
    required this.chapter,
    required this.number,
    required this.rows,
    required this.columns,
    required this.baseLights,
    required this.targetPattern,
    required this.plates,
  });

  final String id;
  final String chapter;
  final int number;
  final int rows;
  final int columns;
  final List<bool> baseLights;
  final List<bool> targetPattern;
  final List<PlateDefinition> plates;

  int get cellCount => rows * columns;
  List<int> get initialPositions =>
      plates.map((plate) => plate.initialNotch).toList(growable: false);

  List<bool> visibleLights(List<int> positions) {
    if (positions.length != plates.length) {
      throw ArgumentError('A position is required for every plate.');
    }
    return List<bool>.generate(cellCount, (cell) {
      if (!baseLights[cell]) return false;
      for (var plateIndex = 0; plateIndex < plates.length; plateIndex++) {
        final plate = plates[plateIndex];
        final notch = positions[plateIndex].clamp(0, plate.notchCount - 1);
        if (!plate.masks[notch][cell]) return false;
      }
      return true;
    }, growable: false);
  }

  bool isSolved(List<int> positions) {
    final visible = visibleLights(positions);
    for (var index = 0; index < cellCount; index++) {
      if (visible[index] != targetPattern[index]) return false;
    }
    return true;
  }

  factory ShutterLevel.fromJson(Map<String, dynamic> json) {
    final board = json['board'] as Map<String, dynamic>;
    final rows = board['rows'] as int;
    final columns = board['columns'] as int;
    final cellCount = rows * columns;
    List<bool> bits(String key) {
      final values = (json[key] as List<dynamic>)
          .map((value) => value == 1)
          .toList(growable: false);
      if (values.length != cellCount) {
        throw FormatException('$key must contain $cellCount values.');
      }
      return values;
    }

    return ShutterLevel(
      id: json['id'] as String,
      chapter: json['chapter'] as String,
      number: json['number'] as int,
      rows: rows,
      columns: columns,
      baseLights: bits('baseLights'),
      targetPattern: bits('target'),
      plates: (json['plates'] as List<dynamic>)
          .map((plate) => PlateDefinition.fromJson(
                plate as Map<String, dynamic>,
                cellCount,
              ))
          .toList(growable: false),
    );
  }
}
