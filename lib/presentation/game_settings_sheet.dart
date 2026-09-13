import 'package:flutter/material.dart';

import 'game_preferences.dart';
import 'shutter_theme.dart';

class GameSettingsSheet extends StatelessWidget {
  const GameSettingsSheet({required this.preferences, super.key});

  final GamePreferences preferences;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
        child: ListenableBuilder(
          listenable: preferences,
          builder: (context, child) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 3,
                  decoration: BoxDecoration(
                    color: ShutterColors.hairline,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'GAME FEEL',
                style: TextStyle(
                  color: ShutterColors.text,
                  fontSize: 12,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: ShutterColors.brass,
                title: const Text('Haptics'),
                subtitle: const Text('Mechanical feedback at each notch.'),
                value: preferences.hapticsEnabled,
                onChanged: (value) => preferences.hapticsEnabled = value,
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: ShutterColors.brass,
                title: const Text('Reduced motion'),
                subtitle: const Text('Snap shutters directly into position.'),
                value: preferences.reducedMotion,
                onChanged: (value) => preferences.reducedMotion = value,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
