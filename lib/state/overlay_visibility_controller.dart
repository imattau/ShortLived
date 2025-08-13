import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/feature_flags.dart';

class OverlayVisibilityController extends ChangeNotifier {
  OverlayVisibilityController(this._prefs);
  final SharedPreferences _prefs;
  static const _k = 'overlays_visible';
  bool _visible = !(FeatureFlags.overlaysDefaultHidden);
  bool get visible => _visible;

  Future<void> load() async {
    _visible = _prefs.getBool(_k) ?? !(FeatureFlags.overlaysDefaultHidden);
    notifyListeners();
  }
  Future<void> toggle() async {
    _visible = !_visible;
    await _prefs.setBool(_k, _visible);
    notifyListeners();
  }
}
