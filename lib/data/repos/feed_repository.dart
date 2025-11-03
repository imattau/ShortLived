import 'dart:convert';
import '../models/post.dart';
import '../models/author.dart';
import '../../services/nostr/relay_service.dart';
import '../../services/cache/cache_service.dart';
import '../../services/moderation/mute_service.dart';
import '../../services/nostr/metadata_service.dart';
import '../../core/di/locator.dart';

abstract class FeedRepository {
  Stream<List<Post>> watchFeed();
  Future<List<Post>> fetchInitial();
}

/// Mock implementation for development and tests
class MockFeedRepository implements FeedRepository {
  final int count;
  MockFeedRepository({this.count = 10});

  @override
  Future<List<Post>> fetchInitial() async {
    return List.generate(
        count,
        (i) => Post(
              id: 'evt_\$i',
              author: const Author(
                  pubkey: 'pk',
                  name: 'Creator',
                  avatarUrl: 'https://picsum.photos/64'),
              caption: 'Sample video #\$i',
              tags: const ['demo'],
              url:
                  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
              thumb: 'https://picsum.photos/seed/\$i/300/533',
              mime: 'video/mp4',
              width: 1080,
              height: 1920,
              duration: 10 + i.toDouble(),
              likeCount: 0,
              commentCount: 0,
              repostCount: 0,
              createdAt: DateTime.now().subtract(Duration(minutes: i)),
            ));
  }

  @override
  Stream<List<Post>> watchFeed() async* {
    yield await fetchInitial();
  }
}

class RealFeedRepository implements FeedRepository {
  RealFeedRepository(this._relay, this._cache, this._meta);
  final RelayService _relay;
  final CacheService _cache;
  final MetadataService _meta;

  final Map<String, Post> _byId = {};

  static Post? postFromEvent(Map<String, dynamic> e) => _postFromEvent(e);

  static Post? _postFromEvent(Map<String, dynamic> e) {
    if ((e['kind'] as int?) != 1) return null;
    final tags = (e['tags'] as List?)?.whereType<List>().toList() ?? const [];
    String? mime, url, thumb;
    int w = 0, h = 0;
    double dur = 0.0;
    for (final t in tags) {
      if (t.length < 2) continue;
      switch (t[0]) {
        case 't':
          mime ??= t[1];
          break;
        case 'url':
          url ??= t[1];
          break;
        case 'thumb':
          thumb ??= t[1];
          break;
        case 'dim':
          final parts = t[1].split('x');
          if (parts.length == 2) {
            final wi = int.tryParse(parts[0]) ?? 0;
            final hi = int.tryParse(parts[1]) ?? 0;
            w = wi;
            h = hi;
          }
          break;
        case 'dur':
          dur = double.tryParse(t[1]) ?? 0.0;
          break;
      }
    }
    if (url == null || mime == null) return null;
    final created = DateTime.fromMillisecondsSinceEpoch(
        ((e['created_at'] ?? 0) as int) * 1000,
        isUtc: true);

    final pubkey = (e['pubkey'] ?? '') as String;
    final author = Author(
      pubkey: pubkey,
      name: pubkey.length >= 8 ? pubkey.substring(0, 8) : pubkey,
      avatarUrl: '',
    );
    return Post(
      id: (e['id'] ?? '') as String,
      author: author,
      caption: (e['content'] ?? '') as String,
      tags: const [],
      url: url,
      thumb: thumb ?? '',
      mime: mime,
      width: w,
      height: h,
      duration: dur,
      likeCount: 0,
      commentCount: 0,
      repostCount: 0,
      createdAt: created,
    );
  }

  @override
  Future<List<Post>> fetchInitial() async {
    try {
      final cached = await _cache.loadCachedPosts();
      if (cached.isNotEmpty) {
        for (final p in cached) {
          _byId[p.id] = p;
        }
        return _sorted();
      }
    } catch (_) {}
    return const [];
  }

  List<Post> _sorted() {
    final list = _byId.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Stream<List<Post>> watchFeed() async* {
    final initial = await fetchInitial();
    yield initial;

    final since =
        (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000) - 7 * 24 * 3600;
    final filters = [
      {
        "kinds": [1],
        "limit": 100,
        "#t": ["video/mp4", "video/quicktime", "video/webm"],
        "since": since,
      },
      {
        "kinds": [6, 7],
        "since": since,
      },
      {
        "kinds": [0],
        "since": since,
      }
    ];
    final subId = await _relay.subscribe(filters);
    final mute = Locator.I.tryGet<MuteService>();
    try {
      await for (final evt in _relay.events) {
        final kind = evt['kind'] as int? ?? 0;
        switch (kind) {
          case 1:
            final p = _postFromEvent(evt);
            if (p == null) break;
            if (mute != null &&
                mute.isPostMuted(
                    author: p.author.pubkey,
                    eventId: p.id,
                    caption: p.caption)) {
              break;
            }
            _byId[p.id] = p;
            final list = _sorted();
            yield list;
            try {
              await _cache.savePosts(list);
            } catch (_) {}
            break;
          case 7: // like reaction
            final id = _firstTagValue(evt, 'e');
            if (id != null && _byId.containsKey(id)) {
              final p = _byId[id]!;
              _byId[id] = p.copyWith(likeCount: p.likeCount + 1);
              yield _sorted();
            }
            break;
          case 6: // repost
            final id = _firstTagValue(evt, 'e');
            if (id != null && _byId.containsKey(id)) {
              final p = _byId[id]!;
              _byId[id] = p.copyWith(repostCount: p.repostCount + 1);
              yield _sorted();
            }
            break;
          case 0: // metadata
            _meta.handleEvent(evt);
            final pk = (evt['pubkey'] ?? '') as String;
            if (pk.isEmpty) break;
            String? name;
            String? picture;
            try {
              final content = (evt['content'] ?? '{}') as String;
              final c = jsonDecode(content) as Map<String, dynamic>;
              name = c['name'] as String? ?? c['display_name'] as String?;
              picture = c['picture'] as String?;
            } catch (_) {}
            bool changed = false;
            for (final entry in _byId.entries.toList()) {
              if (entry.value.author.pubkey == pk) {
                final a = entry.value.author;
                final updated = entry.value.copyWith(
                  author: Author(
                    pubkey: a.pubkey,
                    name: name ?? a.name,
                    avatarUrl: picture ?? a.avatarUrl,
                    following: a.following,
                  ),
                );
                _byId[entry.key] = updated;
                changed = true;
              }
            }
            if (changed) {
              yield _sorted();
            }
            break;
        }
      }
    } finally {
      await _relay.close(subId);
    }
  }

  String? _firstTagValue(Map<String, dynamic> e, String tag) {
    final tags = (e['tags'] as List?)?.whereType<List>().toList() ?? const [];
    for (final t in tags) {
      if (t.isNotEmpty && t.first == tag && t.length > 1) {
        return t[1] as String;
      }
    }
    return null;
  }
}
