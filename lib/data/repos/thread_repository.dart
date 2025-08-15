import 'dart:async';
import '../../services/nostr/relay_service.dart';
import '../../services/nostr/metadata_service.dart';

class ThreadRepository {
  ThreadRepository(this._relay, this._meta);
  final RelayService _relay;
  final MetadataService _meta;

  final Map<String, ThreadComment> _byId = {};
  StreamSubscription<Map<String, dynamic>>? _sub;

  Future<void> dispose() async => _sub?.cancel();

  Stream<List<ThreadComment>> watchThread({required String rootEventId}) {
    late final StreamController<List<ThreadComment>> ctrl;
    String? subId;

    ctrl = StreamController<List<ThreadComment>>.broadcast(
      onListen: () async {
        // Listen before subscribing so early events aren't missed.
        _sub = _relay.events.listen((evt) {
          if (evt['kind'] != 1) return;
          final tags =
              (evt['tags'] as List?)?.whereType<List>().toList() ?? const [];
          final hasRoot = tags.any((t) =>
                  t.isNotEmpty &&
                  t[0] == 'e' &&
                  t.length >= 4 &&
                  t[3] == 'root' &&
                  t[1] == rootEventId) ||
              tags.any((t) =>
                  t.isNotEmpty &&
                  t[0] == 'e' &&
                  t.length >= 2 &&
                  t[1] == rootEventId);
          if (!hasRoot) return;

          final id = (evt['id'] ?? '') as String;
          if (id.isEmpty) return;

          final pk = (evt['pubkey'] ?? '') as String;
          final meta = _meta.get(pk);
          final created = DateTime.fromMillisecondsSinceEpoch(
              ((evt['created_at'] ?? 0) as int) * 1000,
              isUtc: true);

          _byId[id] = ThreadComment(
            id: id,
            pubkey: pk,
            authorName: meta?.name ?? pk.substring(0, 8),
            authorAvatar: meta?.picture ?? '',
            content: (evt['content'] ?? '') as String,
            createdAt: created,
          );

          final list = _byId.values.toList()
            ..sort((a, b) =>
                a.createdAt.compareTo(b.createdAt)); // oldest → newest
          ctrl.add(list);
        });

        // Subscribe for kind:1 replies that reference the root
        subId = await _relay.subscribe([
          {
            "kinds": [1],
            "#e": [rootEventId],
            "limit": 200,
          }
        ]);
      },
      onCancel: () async {
        if (subId != null) {
          await _relay.close(subId!);
        }
        await _sub?.cancel();
      },
    );

    return ctrl.stream;
  }
}

class ThreadComment {
  final String id;
  final String pubkey;
  final String authorName;
  final String authorAvatar;
  final String content;
  final DateTime createdAt;
  const ThreadComment({
    required this.id,
    required this.pubkey,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    required this.createdAt,
  });
}
