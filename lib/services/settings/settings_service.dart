import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _kMuted = 'muted_pubkeys';
  static const _kOverlaysDefaultHidden = 'overlays_default_hidden';
  static const _kRelays = 'custom_relays';
  static const _kSensitiveBlur = 'sensitive_blur_enabled';
  static const _kSensitiveWords = 'sensitive_words';
  static const _kSensitiveMarks = 'sensitive_marks'; // user-marked event ids

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

  bool sensitiveBlurEnabled() => prefs.getBool(_kSensitiveBlur) ?? true;
  Future<void> setSensitiveBlurEnabled(bool v) =>
      prefs.setBool(_kSensitiveBlur, v);

  Set<String> sensitiveWords() =>
      (prefs.getStringList(_kSensitiveWords) ?? const ['nsfw', '18plus', 'nudity']).toSet();
  Future<void> setSensitiveWords(Set<String> words) =>
      prefs.setStringList(_kSensitiveWords, words.toList());

  Set<String> sensitiveMarks() =>
      (prefs.getStringList(_kSensitiveMarks) ?? const []).toSet();
  Future<void> addSensitiveMark(String eventId) async {
    final s = sensitiveMarks()..add(eventId);
    await prefs.setStringList(_kSensitiveMarks, s.toList());
  }

  Future<void> removeSensitiveMark(String eventId) async {
    final s = sensitiveMarks()..remove(eventId);
    await prefs.setStringList(_kSensitiveMarks, s.toList());
  }
}
