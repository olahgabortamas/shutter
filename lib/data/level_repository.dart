import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/shutter_level.dart';

abstract interface class LevelRepository {
  Future<ShutterLevel> load(int levelNumber);

  Future<List<ShutterLevel>> loadCampaign();
}

class AssetLevelRepository implements LevelRepository {
  const AssetLevelRepository();

  static const _manifestPath = 'assets/levels/manifest.json';

  @override
  Future<ShutterLevel> load(int levelNumber) async {
    final name = levelNumber.toString().padLeft(4, '0');
    final source = await rootBundle.loadString('assets/levels/campaign_$name.json');
    return ShutterLevel.fromJson(jsonDecode(source) as Map<String, dynamic>);
  }

  @override
  Future<List<ShutterLevel>> loadCampaign() async {
    final source = await rootBundle.loadString(_manifestPath);
    final manifest = jsonDecode(source) as Map<String, dynamic>;
    final files = (manifest['levels'] as List<dynamic>).cast<String>();
    return Future.wait(files.map((file) async {
      final levelSource = await rootBundle.loadString('assets/levels/$file');
      return ShutterLevel.fromJson(
        jsonDecode(levelSource) as Map<String, dynamic>,
      );
    }));
  }
}
