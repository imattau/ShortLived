import 'package:shared_preferences/shared_preferences.dart';
import '../moderation/mute_models.dart';
import '../nostr/relay_directory.dart';

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

  Set<String> sensitiveWords() => (prefs.getStringList(_kSensitiveWords) ??
          const ['nsfw', '18plus', 'nudity'])
      .toSet();
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

extension RelayPersistence on SettingsService {
  static const _kRelays = 'relays_list';
  static const _kRelaysAt = 'relays_updated_at';

  List<RelayEntry> loadRelays() {
    final raw = prefs.getStringList(_kRelays) ?? const [];
    return raw.map((s) {
      final parts = s.split('|'); // url|r|w
      final url = parts[0];
      final read = parts.length > 1 ? parts[1] == '1' : true;
      final write = parts.length > 2 ? parts[2] == '1' : true;
      return RelayEntry(Uri.parse(url), read: read, write: write);
    }).toList();
  }

  Future<void> saveRelays(List<RelayEntry> list,
      {required int updatedAt}) async {
    final raw = list
        .map((e) => '${e.uri}|${e.read ? '1' : '0'}|${e.write ? '1' : '0'}')
        .toList();
    await prefs.setStringList(_kRelays, raw);
    await prefs.setInt(_kRelaysAt, updatedAt);
  }

  int relaysUpdatedAt() => prefs.getInt(_kRelaysAt) ?? 0;
}

extension MutePersistence on SettingsService {
  static const _kMuteUsers = 'mute_users';
  static const _kMuteEvents = 'mute_events';
  static const _kMuteTags = 'mute_tags';
  static const _kMuteWords = 'mute_words';

  MuteList loadMuteList() {
    final u = prefs.getStringList(_kMuteUsers) ?? const [];
    final e = prefs.getStringList(_kMuteEvents) ?? const [];
    final t = prefs.getStringList(_kMuteTags) ?? const [];
    final w = prefs.getStringList(_kMuteWords) ?? const [];
    return MuteList(
      users: u.toSet(),
      events: e.toSet(),
      tags: t.toSet(),
      words: w.toSet(),
    );
  }

  Future<void> saveMuteList(MuteList list) async {
    await prefs.setStringList(_kMuteUsers, list.users.toList());
    await prefs.setStringList(_kMuteEvents, list.events.toList());
    await prefs.setStringList(_kMuteTags, list.tags.toList());
    await prefs.setStringList(_kMuteWords, list.words.toList());
  }
}

extension SignerPreference on SettingsService {
  static const _kSignerPref = 'signer_pref'; // 'local' | 'nip07'
  String signerPref() => prefs.getString(_kSignerPref) ?? 'local';
  Future<void> setSignerPref(String v) => prefs.setString(_kSignerPref, v);
}

extension NotificationsSeen on SettingsService {
  static const _kNotifSeenAt = 'notif_last_seen';
  int notifLastSeen() => prefs.getInt(_kNotifSeenAt) ?? 0;
  Future<void> setNotifLastSeen(int secs) => prefs.setInt(_kNotifSeenAt, secs);
}
