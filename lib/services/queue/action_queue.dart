enum ActionType { publish, like, reply }

class QueuedAction {
  final ActionType type;
  final Map<String, dynamic> payload; // eventJson or minimal info
  QueuedAction(this.type, this.payload);

  Map<String, dynamic> toMap() => {
        'type': type.name,
        'payload': payload,
      };
  static QueuedAction fromMap(Map<String, dynamic> m) =>
      QueuedAction(ActionType.values.firstWhere((t) => t.name == m['type']), Map<String, dynamic>.from(m['payload']));
}

abstract class ActionQueue {
  Future<void> init();
  Future<void> enqueue(QueuedAction action);
  Future<List<QueuedAction>> all();
  Future<void> removeFirstN(int n);
  Future<void> clear();
}
