import 'package:flutter/material.dart';

import 'data/level_repository.dart';
import 'presentation/game_screen.dart';
import 'presentation/game_preferences.dart';
import 'presentation/shutter_theme.dart';

class ShutterApp extends StatelessWidget {
  const ShutterApp({required this.preferences, super.key});

  final GamePreferences preferences;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SHUTTER',
      debugShowCheckedModeBanner: false,
      theme: ShutterTheme.data,
      home: GameScreen(
        repository: const AssetLevelRepository(),
        preferences: preferences,
      ),
    );
  }
}
