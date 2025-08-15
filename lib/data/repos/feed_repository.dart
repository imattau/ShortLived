import '../models/post.dart';
import '../models/author.dart';
import '../../services/nostr/relay_service.dart';
import '../../services/cache/cache_service.dart';
import '../../services/moderation/mute_service.dart';
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
  RealFeedRepository(this._relay, this._cache);
  final RelayService _relay;
  final CacheService _cache;

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

    final filters = [
      {
        "kinds": [1],
        "limit": 100,
        "#t": ["video/mp4", "video/quicktime", "video/webm"],
        "since": (DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000) -
            7 * 24 * 3600
      }
    ];
    final subId = await _relay.subscribe(filters);
    final mute = Locator.I.tryGet<MuteService>();
    try {
      await for (final evt in _relay.events) {
        final p = _postFromEvent(evt);
        if (p == null) continue;
        if (mute != null &&
            mute.isPostMuted(
                author: p.author.pubkey,
                eventId: p.id,
                caption: p.caption)) {
          continue;
        }
        _byId[p.id] = p;
        final list = _sorted();
        yield list;
        try {
          final latest = list.take(50).toList();
          await _cache.savePosts(latest);
        } catch (_) {}
      }
    } finally {
      await _relay.close(subId);
    }
  }
}
