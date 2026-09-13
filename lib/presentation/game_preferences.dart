import 'package:flutter/foundation.dart';

class GamePreferences extends ChangeNotifier {
  bool _hapticsEnabled = true;
  bool _reducedMotion = false;

  bool get hapticsEnabled => _hapticsEnabled;
  bool get reducedMotion => _reducedMotion;

  set hapticsEnabled(bool value) {
    if (_hapticsEnabled == value) return;
    _hapticsEnabled = value;
    notifyListeners();
  }

  set reducedMotion(bool value) {
    if (_reducedMotion == value) return;
    _reducedMotion = value;
    notifyListeners();
  }
}
