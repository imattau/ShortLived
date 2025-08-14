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
  Future<void> like({required String eventId}) async {
    likes++;
  }

  @override
  Future<String> publishEvent(Map<String, dynamic> eventJson) async {
    publishes++;
    return 'id';
  }

  @override
  Future<void> reply({required String parentId, required String content, String? parentPubkey}) async {
    replies++;
  }

  @override
  Stream<List<dynamic>> subscribeFeed({required List<String> authors, String? hashtag}) async* {}
  @override
  Stream<Map<String, dynamic>> get events async* {}
  @override
  Future<void> zapRequest({required String eventId, required int millisats}) async {}
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
    await q.enqueue(QueuedAction(ActionType.like, {'eventId': 'evt1'}));

    final spy = _RelaySpy();
    await c.replayQueue(spy);

    expect(spy.publishes, 1);
    expect(spy.replies, 1);
    expect(spy.likes, 1);
    expect((await q.all()).isEmpty, true);
  });
}
