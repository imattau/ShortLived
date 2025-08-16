import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'nostr_repo.dart';

class NostrRepoWebSocket implements NostrRepo {
  final List<String> relays;
  final int limit;

  final _controller = StreamController<NostrEvent>.broadcast();
  final _channels = <WebSocketChannel>[];
  final _subs = <StreamSubscription>[];

  NostrRepoWebSocket({required this.relays, this.limit = 50});

  @override
  Stream<NostrEvent> streamRecent({int? limit}) {
    final useLimit = limit ?? this.limit;
    for (final url in relays) {
      try {
        final ch = WebSocketChannel.connect(Uri.parse(url));
        _channels.add(ch);

        final subId = 'shortlived_${DateTime.now().millisecondsSinceEpoch}_${_channels.length}';
        final filter = {
          'kinds': [1],
          'limit': useLimit,
        };
        ch.sink.add(jsonEncode(['REQ', subId, filter]));

        final sub = ch.stream.listen((raw) {
          try {
            final msg = jsonDecode(raw as String);
            if (msg is List && msg.isNotEmpty) {
              final typ = msg[0] as String;
              if (typ == 'EVENT' && msg.length >= 3) {
                final ev = msg[2] as Map<String, dynamic>;
                final e = NostrEvent(
                  id: ev['id'] as String,
                  pubkey: ev['pubkey'] as String,
                  createdAt: (ev['created_at'] as num).toInt(),
                  kind: (ev['kind'] as num).toInt(),
                  content: (ev['content'] ?? '') as String,
                  tags: (ev['tags'] as List<dynamic>?)
                          ?.map((x) => (x as List).map((e) => e).toList())
                          .toList() ??
                      const <List<dynamic>>[],
                );
                _controller.add(e);
              }
            }
          } catch (_) {
            // swallow malformed frames
          }
        }, onError: (_) {}, onDone: () {});
        _subs.add(sub);
      } catch (_) {
        // ignore bad relay
      }
    }
    return _controller.stream;
  }

  @override
  Future<void> dispose() async {
    for (final s in _subs) {
      await s.cancel();
    }
    for (final ch in _channels) {
      await ch.sink.close();
    }
    await _controller.close();
  }
}
