import 'dart:async';
import '../nostr/relay_service.dart';
import '../../data/repos/feed_repository.dart';
import '../../data/models/post.dart';
import 'search_models.dart';
import 'search_parser.dart';

class SearchService {
  SearchService(this._relay, this._repo);
  final RelayService _relay;
  final FeedRepository _repo;

  Future<SearchQuery> buildQuery(String raw) async {
    final pk = SearchParser.parseAuthor(raw);
    final tag = SearchParser.parseHashtag(raw);
    final text = SearchParser.parseText(raw);
    return SearchQuery(raw: raw, authorHex: pk, hashtag: tag, text: text);
  }

  /// Try NIP-50 text search, else fall back to standard filters.
  Future<String> openSubscription(SearchQuery q) async {
    final filters = <Map<String, dynamic>>[];
    if (q.text != null) {
      // NIP-50 search clause (some relays ignore it harmlessly)
      filters.add({
        "kinds": [1],
        "search": q.text,
        "limit": 50,
      });
    }
    if (q.hashtag != null) {
      filters.add({
        "kinds": [1],
        "#t": [q.hashtag],
        "limit": 50,
      });
    }
    if (q.authorHex != null) {
      filters.add({
        "kinds": [1],
        "authors": [q.authorHex],
        "limit": 50,
      });
    }
    if (filters.isEmpty) {
      // default recent videos filter
      filters.add({
        "kinds": [1],
        "#t": ["video/mp4", "video/webm", "video/quicktime"],
        "limit": 50,
      });
    }
    return _relay.subscribe(filters);
  }

  /// Derive trending hashtags from posts we already have in memory.
  List<String> trendingHashtags(List<Post> posts, {int max = 12}) {
    final counts = <String, int>{};
    for (final p in posts) {
      final m = RegExp(r'(?:^|\s)#([a-z0-9_]{1,40})', caseSensitive: false).allMatches(p.caption);
      for (final g in m) {
        final tag = g.group(1)!.toLowerCase();
        counts[tag] = (counts[tag] ?? 0) + 1;
      }
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(max).map((e) => e.key).toList();
  }
}
