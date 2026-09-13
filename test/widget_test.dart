import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shutter/data/level_repository.dart';
import 'package:shutter/domain/shutter_level.dart';
import 'package:shutter/presentation/game_screen.dart';

class _MemoryRepository implements LevelRepository {
  ShutterLevel get level => const ShutterLevel(
        id: 'test',
        chapter: 'aperture',
        number: 1,
        rows: 1,
        columns: 1,
        baseLights: [true],
        targetPattern: [false],
        plates: [
          PlateDefinition(
            id: 'A',
            axis: PlateAxis.horizontal,
            notchCount: 1,
            initialNotch: 0,
            masks: [
              [true],
            ],
          ),
        ],
      );

  @override
  Future<ShutterLevel> load(int levelNumber) async => level;

  @override
  Future<List<ShutterLevel>> loadCampaign() async => [level];
}

void main() {
  testWidgets('renders the first playable screen', (tester) async {
    await tester.pumpWidget(MaterialApp(home: GameScreen(repository: _MemoryRepository())));
    await tester.pumpAndSettle();
    expect(find.text('SHUTTER'), findsOneWidget);
    expect(find.text('LEVEL 01'), findsOneWidget);
    expect(find.text('UNDO'), findsOneWidget);
    expect(find.text('HINT'), findsOneWidget);
    expect(find.text('RESET'), findsOneWidget);
  });
}
