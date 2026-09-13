import 'package:flutter/material.dart';

import 'data/level_repository.dart';
import 'presentation/game_screen.dart';
import 'presentation/shutter_theme.dart';

class ShutterApp extends StatelessWidget {
  const ShutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SHUTTER',
      debugShowCheckedModeBanner: false,
      theme: ShutterTheme.data,
      home: const GameScreen(repository: AssetLevelRepository()),
    );
  }
}

