import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/services/queue/action_queue_memory.dart';
import 'package:nostr_video/state/feed_controller.dart';
import 'package:nostr_video/data/repos/feed_repository.dart';
import 'package:nostr_video/services/nostr/relay_service.dart';
import 'package:nostr_video/services/queue/action_queue.dart';

  class _RelaySpy implements RelayService {
  int likes = 0;
    int publishes = 0;
  int replies = 0;
  @override
  Future<void> init(List<String> relays) async {}
  @override
  Future<void> like({required String eventId, required String authorPubkey, String emojiOrPlus = '+'}) async {
    likes++;
  }

    @override
    Future<String> publishEvent(Map<String, dynamic> eventJson) async {
      publishes++;
      return 'id';
    }
    @override
    Future<String?> signAndPublish({required int kind, required String content, required List<List<String>> tags}) async {
      publishes++;
      return 'id';
    }

  @override
  Future<void> reply(
      {required String parentId,
      required String content,
      String? parentPubkey,
      String? rootId,
      String? rootPubkey}) async {
    replies++;
  }

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

void main() async {
  test('replays queued actions in order', () async {
    final c = FeedController(MockFeedRepository(count: 1));
    await c.connect();
    final q = ActionQueueMemory();
    await q.init();
    c.bindQueue(q);

    await c.enqueuePublish({'kind': 1, 'content': 'hi', 'tags': []});
    await c.enqueueReply('evt1', 'yo', parentPubkey: 'pk');
    await q.enqueue(QueuedAction(ActionType.like, {
      'eventId': 'evt1',
      'authorPubkey': 'pk',
    }));

    final spy = _RelaySpy();
    await c.replayQueue(spy);

    expect(spy.publishes, 1);
    expect(spy.replies, 1);
    expect(spy.likes, 1);
    expect((await q.all()).isEmpty, true);
  });
}
