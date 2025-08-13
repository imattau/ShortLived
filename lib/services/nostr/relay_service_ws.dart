import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../core/config/network.dart';
import 'backoff.dart';
import 'relay_service.dart';

typedef WebSocketFactory = WebSocketChannel Function(Uri uri);

class RelayServiceWs implements RelayService {
  final WebSocketFactory factory;
  final Map<String, WebSocketChannel?> _ch = {};
  final Map<String, int> _attempts = {};
  final Backoff _backoff;
  final _eventsCtrl = StreamController<Map<String, dynamic>>.broadcast();

  @override
  Stream<Map<String, dynamic>> get events => _eventsCtrl.stream;

  RelayServiceWs({required this.factory, Backoff? backoff})
      : _backoff = backoff ?? Backoff();

  @override
  Future<void> init(List<String> relays) async {
    for (final r in relays) {
      _connect(r);
    }
  }

  void _connect(String url) {
    if (_ch[url] != null) return;
    final uri = Uri.parse(url);
    try {
      final ws = factory(uri);
      _ch[url] = ws;
      _attempts[url] = 0;
      ws.stream.listen(
        (msg) {
          try {
            final data = (msg is String) ? jsonDecode(msg) : msg;
            if (data is List && data.isNotEmpty && data[0] == 'EVENT') {
              final evt = data.length > 2 ? data[2] : null;
              if (evt is Map<String, dynamic>) _eventsCtrl.add(evt);
            }
          } catch (_) {/* ignore */}
        },
        onDone: () => _scheduleReconnect(url),
        onError: (_) => _scheduleReconnect(url),
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleReconnect(url);
    }
  }

  void _scheduleReconnect(String url) {
    _ch[url]?.sink.close();
    _ch[url] = null;
    final n = (_attempts[url] ?? 0) + 1;
    _attempts[url] = n;
    final delay = _backoff.at(n);
    Future.delayed(delay, () {
      if (_ch[url] == null) _connect(url);
    });
  }

  @override
  Stream<List<dynamic>> subscribeFeed(
      {required List<String> authors, String? hashtag}) async* {
    yield const [];
  }

  @override
  Future<String> publishEvent(Map<String, dynamic> eventJson) async {
    final jsonStr = jsonEncode(["EVENT", eventJson]);
    for (final url in NetworkConfig.relays) {
      final ws = _ch[url];
      if (ws != null) {
        try {
          ws.sink.add(jsonStr);
        } catch (_) {
          // ignore and rely on reconnect
        }
      }
    }
    return (eventJson['id'] as String?) ??
        'tmp_${DateTime.now().microsecondsSinceEpoch}';
  }

  @override
  Future<void> like({required String eventId}) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final evt = <String, dynamic>{
      "kind": 7,
      "content": "+",
      "tags": [
        ["e", eventId],
      ],
      "created_at": now,
    };
    await publishEvent(evt);
  }

  @override
  Future<void> reply(
      {required String parentId,
      required String content,
      String? parentPubkey}) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final tags = <List<String>>[
      ["e", parentId],
    ];
    if (parentPubkey != null && parentPubkey.isNotEmpty) {
      tags.add(["p", parentPubkey]);
    }
    final evt = <String, dynamic>{
      "kind": 1,
      "content": content,
      "tags": tags,
      "created_at": now,
    };
    await publishEvent(evt);
  }

  @override
  Future<void> zapRequest(
      {required String eventId, required int millisats}) async {
    // Not implemented yet
  }
}
