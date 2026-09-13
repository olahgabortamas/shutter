import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoredGamePreferences {
  const StoredGamePreferences({
    this.currentLevelIndex = 0,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
  });

  final int currentLevelIndex;
  final bool hapticsEnabled;
  final bool reducedMotion;
}

abstract interface class GamePreferencesStore {
  Future<StoredGamePreferences> read();
  Future<void> write(StoredGamePreferences preferences);
}

class SharedPreferencesGameStore implements GamePreferencesStore {
  SharedPreferencesGameStore([SharedPreferencesAsync? preferences])
      : _preferences = preferences ?? SharedPreferencesAsync();

  static const _currentLevelKey = 'shutter.v1.currentLevelIndex';
  static const _hapticsKey = 'shutter.v1.hapticsEnabled';
  static const _reducedMotionKey = 'shutter.v1.reducedMotion';

  final SharedPreferencesAsync _preferences;

  @override
  Future<StoredGamePreferences> read() async => StoredGamePreferences(
        currentLevelIndex: await _preferences.getInt(_currentLevelKey) ?? 0,
        hapticsEnabled: await _preferences.getBool(_hapticsKey) ?? true,
        reducedMotion: await _preferences.getBool(_reducedMotionKey) ?? false,
      );

  @override
  Future<void> write(StoredGamePreferences preferences) async {
    await Future.wait([
      _preferences.setInt(_currentLevelKey, preferences.currentLevelIndex),
      _preferences.setBool(_hapticsKey, preferences.hapticsEnabled),
      _preferences.setBool(_reducedMotionKey, preferences.reducedMotion),
    ]);
  }
}

class GamePreferences extends ChangeNotifier {
  GamePreferences({
    GamePreferencesStore? store,
    int currentLevelIndex = 0,
    bool hapticsEnabled = true,
    bool reducedMotion = false,
  })  : _store = store,
        _currentLevelIndex = currentLevelIndex,
        _hapticsEnabled = hapticsEnabled,
        _reducedMotion = reducedMotion;

  static Future<GamePreferences> load({GamePreferencesStore? store}) async {
    final resolvedStore = store ?? SharedPreferencesGameStore();
    final saved = await resolvedStore.read();
    return GamePreferences(
      store: resolvedStore,
      currentLevelIndex: saved.currentLevelIndex,
      hapticsEnabled: saved.hapticsEnabled,
      reducedMotion: saved.reducedMotion,
    );
  }

  final GamePreferencesStore? _store;
  int _currentLevelIndex;
  bool _hapticsEnabled;
  bool _reducedMotion;

  int get currentLevelIndex => _currentLevelIndex;
  bool get hapticsEnabled => _hapticsEnabled;
  bool get reducedMotion => _reducedMotion;

  set currentLevelIndex(int value) {
    final normalized = value < 0 ? 0 : value;
    if (_currentLevelIndex == normalized) return;
    _currentLevelIndex = normalized;
    _changed();
  }

  set hapticsEnabled(bool value) {
    if (_hapticsEnabled == value) return;
    _hapticsEnabled = value;
    _changed();
  }

  set reducedMotion(bool value) {
    if (_reducedMotion == value) return;
    _reducedMotion = value;
    _changed();
  }

  void _changed() {
    notifyListeners();
    final store = _store;
    if (store == null) return;
    unawaited(
      store.write(
        StoredGamePreferences(
          currentLevelIndex: _currentLevelIndex,
          hapticsEnabled: _hapticsEnabled,
          reducedMotion: _reducedMotion,
        ),
      ),
    );
  }
}
