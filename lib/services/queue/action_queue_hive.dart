import 'package:hive_flutter/hive_flutter.dart';
import 'action_queue.dart';

class ActionQueueHive implements ActionQueue {
  static const _boxName = 'action_queue';
  Box? _box;

  @override
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  @override
  Future<void> enqueue(QueuedAction action) async {
    await _box!.add(action.toMap());
  }

  @override
  Future<List<QueuedAction>> all() async {
    return _box!.values.map((e) => QueuedAction.fromMap(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<void> removeFirstN(int n) async {
    final keys = _box!.keys.take(n).toList();
    await _box!.deleteAll(keys);
  }

  @override
  Future<void> clear() async {
    await _box!.clear();
  }
}
