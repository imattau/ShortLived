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

// Look for common patterns: ["video","<url>"], ["media","<url>"],
// NIP-94: ["url","<url>"] with ["m","video/mp4"] or ["imeta","url <url> ..."]
String? _extractVideoUrl(NostrEvent e, List<String> preferredExts) {
  final urls = <String>[];

  void add(String? u) {
    if (u != null && u.startsWith('http')) urls.add(u);
  }

  for (final t in e.tags) {
    if (t.isEmpty) continue;
    final k = (t[0] ?? '').toString().toLowerCase();
    if ((k == 'video' || k == 'media') && t.length >= 2) {
      add(t[1].toString());
    }
    if (k == 'url' && t.length >= 2) {
      final v = t[1].toString();
      if (v.contains('.mp4') || v.contains('.webm') || v.contains('.m3u8')) {
        add(v);
      }
    }
    if (k == 'imeta' && t.length >= 2) {
      final s = t.sublist(1).join(' ');
      final m = _urlRegex.firstMatch(s);
      add(m?.group(1));
    }
  }

  for (final m in _urlRegex.allMatches(e.content)) {
    add(m.group(1));
  }

  if (urls.isEmpty) return null;

  int rank(String u) {
    for (var i = 0; i < preferredExts.length; i++) {
      if (u.toLowerCase().contains('.${preferredExts[i]}')) return i;
    }
    return preferredExts.length;
  }

  urls.sort((a, b) => rank(a).compareTo(rank(b)));
  return urls.first;
}

FeedItem? mapEventToFeedItem(NostrEvent e,
    {List<String> preferredExts = const ['mp4', 'webm', 'm3u8']}) {
  final url = _extractVideoUrl(e, preferredExts);
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
