import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _kMuted = 'muted_pubkeys';
  static const _kOverlaysDefaultHidden = 'overlays_default_hidden';
  static const _kRelays = 'custom_relays';

  final SharedPreferences prefs;
  SettingsService(this.prefs);

  Set<String> muted() => (prefs.getStringList(_kMuted) ?? const []).toSet();
  Future<void> addMute(String pk) async {
    final s = muted()..add(pk);
    await prefs.setStringList(_kMuted, s.toList());
  }

  Future<void> removeMute(String pk) async {
    final s = muted()..remove(pk);
    await prefs.setStringList(_kMuted, s.toList());
  }

  bool overlaysDefaultHidden() =>
      prefs.getBool(_kOverlaysDefaultHidden) ?? false;
  Future<void> setOverlaysDefaultHidden(bool v) =>
      prefs.setBool(_kOverlaysDefaultHidden, v);

  List<String> relays() => prefs.getStringList(_kRelays) ?? const [];
  Future<void> setRelays(List<String> urls) =>
      prefs.setStringList(_kRelays, urls);
}
