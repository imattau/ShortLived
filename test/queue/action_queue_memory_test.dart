import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/services/queue/action_queue.dart';
import 'package:nostr_video/services/queue/action_queue_memory.dart';

void main() {
  test('enqueue and removeFirstN works', () async {
    final q = ActionQueueMemory();
    await q.init();
    await q.enqueue(QueuedAction(ActionType.like, {'eventId': 'a'}));
    await q.enqueue(QueuedAction(ActionType.publish, {'event': 'e'}));
    expect((await q.all()).length, 2);
    await q.removeFirstN(1);
    final left = await q.all();
    expect(left.length, 1);
    expect(left.first.type, ActionType.publish);
  });
}
