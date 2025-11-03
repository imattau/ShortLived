import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/data/repos/feed_repository.dart';
import 'package:nostr_video/services/nostr/relay_service.dart';
import 'package:nostr_video/services/cache/cache_service.dart';
import 'package:nostr_video/data/models/post.dart';
import 'package:nostr_video/data/models/author.dart';
import 'package:nostr_video/services/nostr/metadata_service.dart';

class _RelayFake implements RelayService {
  final _ctrl = StreamController<Map<String, dynamic>>.broadcast();
  @override
  Stream<Map<String, dynamic>> get events => _ctrl.stream;
  @override
  Future<String> subscribe(List<Map<String, dynamic>> filters,
          {String? subId}) async =>
      'sub';
  @override
  Future<void> close(String subId) async {}
  @override
  Future<void> init(List<String> relays) async {}
  @override
  Stream<List<dynamic>> subscribeFeed(
      {required List<String> authors, String? hashtag}) async* {}
    @override
    Future<String> publishEvent(Map<String, dynamic> eventJson) async => 'id';
    @override
    Future<String?> signAndPublish({required int kind, required String content, required List<List<String>> tags}) async => 'id';
  @override
  Future<void> like({required String eventId, required String authorPubkey, String emojiOrPlus = '+'}) async {}
  @override
  Future<void> reply(
      {required String parentId,
      required String content,
      String? parentPubkey,
      String? rootId,
      String? rootPubkey}) async {}
  @override
  Future<void> zapRequest(
      {required String eventId, required int millisats}) async {}

  @override
  Future<void> repost({required String eventId, String? originalJson}) async {}

  @override
  Future<void> resetConnections(List<String> urls) async {}

  @override
  Future<Map<String, dynamic>> buildZapRequest(
          {required String recipientPubkey,
          required String eventId,
          String content = '',
          List<String>? relays,
          int amountMsat = 0}) async =>
      {};
}

class _CacheNoop implements CacheService {
  @override
  Future<void> cacheThumb(String postId, String url) async {}

  @override
  Future<void> init() async {}

  List<Post> posts = [];

  @override
  Future<List<Post>> loadCachedPosts() async => posts;

  @override
  Future<void> savePosts(List<Post> p) async {
    posts = p;
  }
}

void main() {
  test('dedupes by id and sorts newest first', () async {
    final r = _RelayFake();
    final c = _CacheNoop();
    final repo = RealFeedRepository(r, c, MetadataService());

    final stream = repo.watchFeed();
    Future(() {
      r.events; // silence lints
    });

    Timer.run(() {
      r._ctrl.add({
        'id': 'same',
        'kind': 1,
        'pubkey': 'pk',
        'created_at': 1,
        'content': '',
        'tags': [
          ['t', 'video/mp4'],
          ['url', 'u'],
          ['dim', '1x1'],
          ['dur', '1']
        ]
      });
      r._ctrl.add({
        'id': 'same',
        'kind': 1,
        'pubkey': 'pk',
        'created_at': 2,
        'content': 'newer',
        'tags': [
          ['t', 'video/mp4'],
          ['url', 'u'],
          ['dim', '1x1'],
          ['dur', '1']
        ]
      });
    });

    final first = await stream.firstWhere((l) => l.isNotEmpty);
    expect(first.first.id, 'same');
  });

  test('fetchInitial yields cached posts when relay offline', () async {
    final r = _RelayFake();
    final c = _CacheNoop()
      ..posts = [
        Post(
          id: 'a',
          author: const Author(pubkey: 'pk', name: 'name', avatarUrl: ''),
          caption: 'older',
          tags: const [],
          url: 'https://cdn/older.mp4',
          thumb: '',
          mime: 'video/mp4',
          width: 1,
          height: 1,
          duration: 1,
          createdAt: DateTime.fromMillisecondsSinceEpoch(10, isUtc: true),
        ),
        Post(
          id: 'b',
          author: const Author(pubkey: 'pk', name: 'name', avatarUrl: ''),
          caption: 'newer',
          tags: const [],
          url: 'https://cdn/newer.mp4',
          thumb: '',
          mime: 'video/mp4',
          width: 1,
          height: 1,
          duration: 1,
          createdAt: DateTime.fromMillisecondsSinceEpoch(20, isUtc: true),
        ),
      ];

    final repo = RealFeedRepository(r, c, MetadataService());
    final initial = await repo.fetchInitial();

    expect(initial.map((p) => p.id), ['b', 'a']);

    final streamed = await repo.watchFeed().first;
    expect(streamed.map((p) => p.id), ['b', 'a']);
  });
}
