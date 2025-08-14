import '../../crypto/nip19.dart';

class SearchParser {
  /// Returns hex pubkey or null
  static String? parseAuthor(String input) {
    final t = input.trim();
    if (t.startsWith('npub1') || t.startsWith('nprofile1')) {
      try { return Nip19.decode(t); } catch (_) { return null; }
    }
    final hex = t.toLowerCase().replaceAll(RegExp(r'[^0-9a-f]'), '');
    return hex.length == 64 ? hex : null;
  }

  /// Extract hashtag without '#'
  static String? parseHashtag(String input) {
    final m = RegExp(r'(?:^|\s)#([a-z0-9_]{1,40})', caseSensitive: false).firstMatch(input);
    return m == null ? null : m.group(1)!.toLowerCase();
  }

  static String? parseText(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('npub1') || trimmed.startsWith('nprofile1')) return null;
    if (trimmed.startsWith('#')) return null;
    return trimmed;
  }
}
