import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'presentation/game_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
  final preferences = await GamePreferences.load();
  runApp(ShutterApp(preferences: preferences));
}
