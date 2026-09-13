import 'package:flutter/material.dart';

import 'shutter_theme.dart';

class GameControls extends StatelessWidget {
  const GameControls({
    required this.onUndo,
    required this.onHint,
    required this.onReset,
    required this.canUndo,
    super.key,
  });

  final VoidCallback? onUndo;
  final VoidCallback onHint;
  final VoidCallback onReset;
  final bool canUndo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _Control(icon: Icons.undo_rounded, label: 'UNDO', onPressed: canUndo ? onUndo : null),
        const SizedBox(width: 38),
        _Control(icon: Icons.lightbulb_outline_rounded, label: 'HINT', onPressed: onHint),
        const SizedBox(width: 38),
        _Control(icon: Icons.refresh_rounded, label: 'RESET', onPressed: onReset),
      ],
    );
  }
}

class _Control extends StatelessWidget {
  const _Control({required this.icon, required this.label, required this.onPressed});
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label.toLowerCase(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: AnimatedOpacity(
              opacity: onPressed == null ? .3 : 1,
              duration: const Duration(milliseconds: 120),
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ShutterColors.surfaceLight.withValues(alpha: .78),
                  border: Border.all(color: ShutterColors.hairline),
                  boxShadow: const [
                    BoxShadow(color: Color(0x10000000), blurRadius: 8, offset: Offset(0, 3)),
                  ],
                ),
                child: Icon(icon, size: 22, color: ShutterColors.text),
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            label,
            style: const TextStyle(
              color: ShutterColors.muted,
              fontSize: 10,
              letterSpacing: 2.4,
            ),
          ),
        ],
      ),
    );
  }
}
