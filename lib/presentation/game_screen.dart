import 'package:flutter/material.dart';

import '../data/level_repository.dart';
import '../domain/shutter_level.dart';
import '../game/game_controller.dart';
import 'game_controls.dart';
import 'shutter_board.dart';
import 'shutter_theme.dart';
import 'target_preview.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({required this.repository, super.key});
  final LevelRepository repository;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final Future<ShutterLevel> _level = widget.repository.load(1);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ShutterLevel>(
      future: _level,
      builder: (context, snapshot) {
        if (snapshot.hasError) return _LoadError(error: snapshot.error);
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(strokeWidth: 1.5)));
        }
        return _LoadedGame(level: snapshot.requireData);
      },
    );
  }
}

class _LoadedGame extends StatefulWidget {
  const _LoadedGame({required this.level});
  final ShutterLevel level;

  @override
  State<_LoadedGame> createState() => _LoadedGameState();
}

class _LoadedGameState extends State<_LoadedGame> {
  late final GameController controller = GameController(widget.level)..addListener(_refresh);
  void _refresh() => setState(() {});

  @override
  void dispose() {
    controller.removeListener(_refresh);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          final compact = constraints.maxHeight < 700;
          final boardSize = (constraints.maxWidth - 40).clamp(280.0, 600.0);
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _TopButton(icon: Icons.pause_rounded, label: 'Pause', onPressed: () {}),
                        _TopButton(icon: Icons.tune_rounded, label: 'Settings', onPressed: () {}),
                      ],
                    ),
                  ),
                  SizedBox(height: compact ? 2 : 8),
                  const Text(
                    'SHUTTER',
                    style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontFamilyFallback: ['Georgia'],
                      fontSize: 40,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 9,
                      color: ShutterColors.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'SLIDE  •  MASK  •  REVEAL',
                    style: TextStyle(fontSize: 9, letterSpacing: 2.5, color: ShutterColors.muted),
                  ),
                  SizedBox(height: compact ? 10 : 18),
                  Text(
                    'LEVEL ${widget.level.number.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 12, letterSpacing: 3.5, color: ShutterColors.text),
                  ),
                  const SizedBox(height: 10),
                  TargetPreview(level: widget.level, confirmed: controller.solved),
                  const SizedBox(height: 7),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      controller.solved ? 'COMPLETE' : 'TARGET',
                      key: ValueKey(controller.solved),
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 3,
                        color: controller.solved ? ShutterColors.brassDark : ShutterColors.muted,
                      ),
                    ),
                  ),
                  SizedBox(height: compact ? 10 : 18),
                  SizedBox.square(
                    dimension: boardSize,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ShutterBoard(controller: controller),
                    ),
                  ),
                  SizedBox(height: compact ? 12 : 20),
                  GameControls(
                    canUndo: controller.canUndo,
                    onUndo: controller.undo,
                    onHint: controller.requestHint,
                    onReset: controller.reset,
                  ),
                  const SizedBox(height: 22),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TopButton extends StatelessWidget {
  const _TopButton({required this.icon, required this.label, required this.onPressed});
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      onPressed: onPressed,
      tooltip: label,
      icon: Icon(icon, size: 19),
      color: ShutterColors.text,
      style: IconButton.styleFrom(
        minimumSize: const Size.square(46),
        side: const BorderSide(color: ShutterColors.hairline),
        backgroundColor: ShutterColors.surfaceLight.withValues(alpha: .45),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.error});
  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text('The mechanism could not be loaded.\n$error', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
