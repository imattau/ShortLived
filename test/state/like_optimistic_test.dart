import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/state/feed_controller.dart';
import 'package:nostr_video/data/repos/feed_repository.dart';
import 'package:nostr_video/services/nostr/relay_service.dart';

class _NoopRelay implements RelayService {
  @override
  Future<void> init(List<String> relays) async {}
  @override
  Future<void> like({required String eventId}) async {}
    @override
    Future<String> publishEvent(Map<String, dynamic> e) async => 'id';
    @override
    Future<String?> signAndPublish({required int kind, required String content, required List<List<String>> tags}) async => 'id';
  @override
  Future<void> reply(
      {required String parentId,
      required String content,
      String? parentPubkey,
      String? rootId,
      String? rootPubkey}) async {}
  @override
  Stream<List<dynamic>> subscribeFeed(
      {required List<String> authors, String? hashtag}) async* {}
  @override
  Stream<Map<String, dynamic>> get events async* {}
  @override
  Future<void> zapRequest(
      {required String eventId, required int millisats}) async {}

  @override
  Future<String> subscribe(List<Map<String, dynamic>> filters,
          {String? subId}) async =>
      'sub';

  @override
  Future<void> close(String subId) async {}

  @override
  Future<void> repost({required String eventId, String? originalJson}) async {}

  @override
  Future<void> resetConnections(List<String> urls) async {}

  @override
  Future<Map<String, dynamic>> buildZapRequest(
          {required String recipientPubkey,
          required String eventId,
          String content = '',
          List<String>? relays}) async =>
      {};
}

void main() {
  test('optimistic like increments count', () async {
    final c = FeedController(MockFeedRepository(count: 1));
    await c.connect();
    final before = c.posts.first.likeCount;
    await c.likeCurrent(_NoopRelay());
    expect(c.posts.first.likeCount, before + 1);
  });
}
