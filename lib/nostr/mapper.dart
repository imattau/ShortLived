import 'dart:math';
import '../feed/demo_feed.dart';
import 'nostr_repo.dart';

final _urlRegex = RegExp(
  r'(https?:\/\/[^\s)]+?\.(?:mp4|webm|m3u8))(?!\S)',
  caseSensitive: false,
);

String _shortPk(String hex) {
  if (hex.length <= 12) return hex;
  return '${hex.substring(0, 6)}…${hex.substring(hex.length - 6)}';
}

String? _extractVideoUrl(NostrEvent e) {
  // Prefer tags: ["video","<url>"] or ["media","<url>"]
  for (final t in e.tags) {
    if (t.isNotEmpty) {
      final k = (t[0] ?? '').toString().toLowerCase();
      if ((k == 'video' || k == 'media') && t.length >= 2) {
        final v = t[1].toString();
        if (v.startsWith('http')) return v;
      }
    }
  }
  final m = _urlRegex.firstMatch(e.content);
  return m?.group(1);
}

FeedItem? mapEventToFeedItem(NostrEvent e) {
  final url = _extractVideoUrl(e);
  if (url == null) return null;

  String n(int max) => (Random(e.id.hashCode).nextInt(max) + 1).toString();

  return FeedItem(
    id: e.id,
    url: url,
    caption: e.content,
    likeCount: n(5000),
    commentCount: n(1000),
    repostCount: n(500),
    shareCount: n(300),
    zapCount: n(100),
    authorDisplay: _shortPk(e.pubkey),
    authorNpub: _shortPk(e.pubkey),
  );
}
