import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/shutter_level.dart';

abstract interface class LevelRepository {
  Future<ShutterLevel> load(int levelNumber);
}

class AssetLevelRepository implements LevelRepository {
  const AssetLevelRepository();

  @override
  Future<ShutterLevel> load(int levelNumber) async {
    final name = levelNumber.toString().padLeft(4, '0');
    final source = await rootBundle.loadString('assets/levels/campaign_$name.json');
    return ShutterLevel.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }
}

