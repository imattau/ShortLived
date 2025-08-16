import 'dart:async';

class NostrEvent {
  final String id;
  final String pubkey;
  final int createdAt;
  final int kind;
  final String content;
  final List<List<dynamic>> tags;
  NostrEvent({
    required this.id,
    required this.pubkey,
    required this.createdAt,
    required this.kind,
    required this.content,
    required this.tags,
  });
}

abstract class NostrRepo {
  /// Streams events suitable for the "For You" feed.
  Stream<NostrEvent> streamRecent({int limit = 50});
  Future<void> dispose();
}
