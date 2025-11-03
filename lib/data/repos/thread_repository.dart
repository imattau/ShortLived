import 'dart:async';
import '../../services/nostr/relay_service.dart';
import '../../services/nostr/metadata_service.dart';
import '../../services/moderation/mute_service.dart';
import '../../core/di/locator.dart';

class ThreadRepository {
  ThreadRepository(this._relay, this._meta);
  final RelayService _relay;
  final MetadataService _meta;

  final Map<String, ThreadComment> _byId = {};
  StreamSubscription<Map<String, dynamic>>? _sub;
  StreamSubscription<AuthorMeta>? _metaSub;

  Future<void> dispose() async {
    await _sub?.cancel();
    await _metaSub?.cancel();
  }

  Stream<List<ThreadComment>> watchThread({required String rootEventId}) {
    late final StreamController<List<ThreadComment>> ctrl;
    String? subId;

    ctrl = StreamController<List<ThreadComment>>.broadcast(
      onListen: () async {
        await _metaSub?.cancel();
        _metaSub = _meta.stream.listen((meta) {
          bool changed = false;
          for (final entry in _byId.entries.toList()) {
            final comment = entry.value;
            if (comment.pubkey != meta.pubkey) continue;
            final nextName =
                meta.name.isNotEmpty ? meta.name : comment.authorName;
            final nextAvatar = meta.picture;
            if (comment.authorName == nextName &&
                comment.authorAvatar == nextAvatar) {
              continue;
            }
            _byId[entry.key] = comment.copyWith(
              authorName: nextName,
              authorAvatar: nextAvatar,
            );
            changed = true;
          }
          if (changed && !ctrl.isClosed) {
            ctrl.add(_sortedComments());
          }
        });
        // Listen before subscribing so early events aren't missed.
        _sub = _relay.events.listen((evt) {
          final kind = evt['kind'] as int? ?? -1;
          if (kind == 0) {
            _meta.handleEvent(evt);
            return;
          }
          if (kind != 1) return;
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
          final caption = (evt['content'] ?? '') as String? ?? '';
          final mute = Locator.I.tryGet<MuteService>();
          if (mute != null &&
              mute.isPostMuted(author: pk, eventId: id, caption: caption)) {
            return;
          }
          final meta = _meta.get(pk);
          final created = DateTime.fromMillisecondsSinceEpoch(
              ((evt['created_at'] ?? 0) as int) * 1000,
              isUtc: true);

          _byId[id] = ThreadComment(
            id: id,
            pubkey: pk,
            authorName: meta?.name ?? (pk.length > 8 ? pk.substring(0, 8) : pk),
            authorAvatar: meta?.picture ?? '',
            content: caption,
            createdAt: created,
          );

          if (!ctrl.isClosed) {
            ctrl.add(_sortedComments());
          }
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
        await _metaSub?.cancel();
      },
    );

    return ctrl.stream;
  }

  List<ThreadComment> _sortedComments() {
    final list = _byId.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
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

  ThreadComment copyWith({
    String? authorName,
    String? authorAvatar,
    String? content,
    DateTime? createdAt,
  }) {
    return ThreadComment(
      id: id,
      pubkey: pubkey,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
