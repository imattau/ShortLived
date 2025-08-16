/// Basic helpers to make Nostr captions readable on overlay.
class CaptionFormat {
  // Matches nostr:npub1..., nostr:nprofile1..., nostr:note1..., nostr:nevent1...
  static final _nostrRef = RegExp(r'nostr:(?:npub1|nprofile1|note1|nevent1)[a-z0-9]+', caseSensitive: false);
  // Strip direct video links; they’re already used by the player.
  static final _videoUrl = RegExp(r'https?:\/\/\S+\.(?:mp4|webm|m3u8)\b', caseSensitive: false);
  // Condense whitespace
  static final _ws = RegExp(r'\s+');

  /// Insert zero-width space every [chunk] chars for long unbroken tokens,
  /// so Flutter Web can wrap them.
  static String wrapLongTokens(String s, {int chunk = 18}) {
    return s.splitMapJoin(
      RegExp(r'[^\s]{40,}'),
      onMatch: (m) {
        final t = m[0]!;
        final b = StringBuffer();
        for (var i = 0; i < t.length; i += chunk) {
          b.write(t.substring(i, i + chunk > t.length ? t.length : i + chunk));
          if (i + chunk < t.length) b.write('\u200B'); // zero-width space
        }
        return b.toString();
      },
      onNonMatch: (n) => n,
    );
  }

  /// Display text for overlay: remove bech32 refs and video URLs, condense whitespace.
  static String display(String raw) {
    var s = raw.replaceAll(_nostrRef, '').replaceAll(_videoUrl, '');
    s = s.replaceAll(_ws, ' ').trim();
    return wrapLongTokens(s);
  }
}
