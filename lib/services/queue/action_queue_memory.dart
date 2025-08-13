import 'action_queue.dart';

class ActionQueueMemory implements ActionQueue {
  final List<QueuedAction> _q = [];
  @override
  Future<void> init() async {}
  @override
  Future<void> enqueue(QueuedAction a) async {
    _q.add(a);
  }

  @override
  Future<List<QueuedAction>> all() async => List.unmodifiable(_q);

  @override
  Future<void> removeFirstN(int n) async {
    n = n.clamp(0, _q.length);
    _q.removeRange(0, n);
  }

  @override
  Future<void> clear() async {
    _q.clear();
  }
}
