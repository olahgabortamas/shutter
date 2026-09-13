import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shutter/data/level_repository.dart';
import 'package:shutter/domain/shutter_level.dart';
import 'package:shutter/presentation/game_screen.dart';
import 'package:shutter/presentation/game_preferences.dart';

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

class _MemoryPreferencesStore implements GamePreferencesStore {
  StoredGamePreferences value = const StoredGamePreferences();

  @override
  Future<StoredGamePreferences> read() async => value;

  @override
  Future<void> write(StoredGamePreferences preferences) async {
    value = preferences;
  }
}

void main() {
  testWidgets('renders the first playable screen', (tester) async {
    await tester.pumpWidget(
        MaterialApp(home: GameScreen(repository: _MemoryRepository())));
    await tester.pumpAndSettle();
    expect(find.text('SHUTTER'), findsOneWidget);
    expect(find.text('LEVEL 01'), findsOneWidget);
    expect(find.text('REVEAL THIS PATTERN'), findsOneWidget);
    expect(find.text('MOVE THE TWO PLATES'), findsOneWidget);
    expect(find.text('UNDO'), findsOneWidget);
    expect(find.text('HINT'), findsOneWidget);
    expect(find.text('RESET'), findsOneWidget);
  });

  testWidgets('settings expose haptic and reduced-motion options',
      (tester) async {
    await tester.pumpWidget(
        MaterialApp(home: GameScreen(repository: _MemoryRepository())));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('GAME FEEL'), findsOneWidget);
    expect(find.text('Haptics'), findsOneWidget);
    expect(find.text('Reduced motion'), findsOneWidget);
    expect(find.byType(Switch), findsNWidgets(2));
  });

  test('preferences save game feel and campaign progress', () async {
    final store = _MemoryPreferencesStore();
    final preferences = await GamePreferences.load(store: store);

    preferences.currentLevelIndex = 3;
    preferences.hapticsEnabled = false;
    preferences.reducedMotion = true;
    await Future<void>.delayed(Duration.zero);

    expect(store.value.currentLevelIndex, 3);
    expect(store.value.hapticsEnabled, isFalse);
    expect(store.value.reducedMotion, isTrue);
  });
}
