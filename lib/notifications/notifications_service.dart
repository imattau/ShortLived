import 'dart:async';

import 'notification_models.dart';

/// Simple interface representing a client capable of sending and receiving
/// messages from a relay.
abstract class INostrClient {
  void send(String message);
  Stream<String> get messages;
  Future<void> close();
}

/// Base class for fetching notifications from relays.
class NotificationsService {
  NotificationsService({required this.client, required this.myPubkey});

  final INostrClient client;
  final String myPubkey;

  final _ctrl = StreamController<List<AppNotification>>.broadcast();
  Stream<List<AppNotification>> get stream => _ctrl.stream;

  /// Starts fetching notifications. Subclasses may override to implement
  /// concrete behaviour. The base implementation does nothing.
  void start() {}

  /// Adds a batch of notifications to listeners.
  void emit(List<AppNotification> items) => _ctrl.add(items);

  Future<void> dispose() async {
    await client.close();
    await _ctrl.close();
  }
}
