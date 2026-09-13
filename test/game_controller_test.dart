import 'package:flutter_test/flutter_test.dart';
import 'package:shutter/domain/shutter_level.dart';
import 'package:shutter/game/game_controller.dart';

void main() {
  late ShutterLevel level;

  setUp(() {
    level = ShutterLevel(
      id: 'test',
      chapter: 'aperture',
      number: 1,
      rows: 1,
      columns: 2,
      baseLights: const [true, true],
      targetPattern: const [false, true],
      plates: const [
        PlateDefinition(
          id: 'A',
          axis: PlateAxis.horizontal,
          notchCount: 2,
          initialNotch: 0,
          masks: [
            [true, false],
            [false, true],
          ],
        ),
      ],
    );
  });

  test('moving to the target notch solves the level', () {
    final controller = GameController(level);
    expect(controller.solved, isFalse);
    controller.movePlate(0, 1);
    expect(controller.visibleLights, [false, true]);
    expect(controller.solved, isTrue);
  });

  test('undo restores the previous snapped position', () {
    final controller = GameController(level)..movePlate(0, 1);
    controller.undo();
    expect(controller.positions, [0]);
    expect(controller.canUndo, isFalse);
  });

  test('hint returns the first move on a shortest solution', () {
    final controller = GameController(level);
    final hint = controller.requestHint();
    expect(hint?.plateIndex, 0);
    expect(hint?.notch, 1);
  });
}

