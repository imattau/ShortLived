import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/data/repos/feed_repository.dart';
import 'package:nostr_video/services/nostr/relay_service.dart';
import 'package:nostr_video/services/cache/cache_service.dart';
import 'package:nostr_video/data/models/post.dart';

class _RelayFake implements RelayService {
  final _ctrl = StreamController<Map<String, dynamic>>.broadcast();
  @override
  Stream<Map<String, dynamic>> get events => _ctrl.stream;
  @override
  Future<String> subscribe(List<Map<String, dynamic>> filters, {String? subId}) async => 'sub';
  @override
  Future<void> close(String subId) async {}
  @override
  Future<void> init(List<String> relays) async {}
  @override
  Stream<List<dynamic>> subscribeFeed({required List<String> authors, String? hashtag}) async* {}
  @override
  Future<String> publishEvent(Map<String, dynamic> eventJson) async => 'id';
  @override
  Future<void> like({required String eventId}) async {}
  @override
  Future<void> reply({required String parentId, required String content, String? parentPubkey}) async {}
  @override
  Future<void> zapRequest({required String eventId, required int millisats}) async {}
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
    final repo = RealFeedRepository(r, c);

    final stream = repo.watchFeed();
    Future(() {
      r.events; // silence lints
    });

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

    final first = await stream.firstWhere((l) => l.isNotEmpty);
    expect(first.first.id, 'same');
  });
}
