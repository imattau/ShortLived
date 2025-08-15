import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../core/config/network.dart';
import 'backoff.dart';
import 'relay_service.dart';
import '../../services/keys/key_service.dart';
import '../../crypto/nostr_event.dart';
import '../../crypto/nip19.dart';

typedef WebSocketFactory = WebSocketChannel Function(Uri uri);

class RelayServiceWs implements RelayService {
  final WebSocketFactory factory;
  final Map<String, WebSocketChannel?> _ch = {};
  final Map<String, int> _attempts = {};
  final Backoff _backoff;
  final _eventsCtrl = StreamController<Map<String, dynamic>>.broadcast();
  final Set<String> _subs = {};
  final _rand = const Uuid();
  final KeyService _keyService;

  @override
  Stream<Map<String, dynamic>> get events => _eventsCtrl.stream;

  RelayServiceWs({required this.factory, required KeyService keyService, Backoff? backoff})
      : _keyService = keyService,
        _backoff = backoff ?? Backoff();

  @override
  Future<void> init(List<String> relays) async {
    for (final r in relays) {
      _connect(r);
    }
  }

  @override
  Future<String> subscribe(List<Map<String, dynamic>> filters, {String? subId}) async {
    final id = subId ?? _rand.v4();
    _subs.add(id);
    final frame = jsonEncode(["REQ", id, ...filters]);
    for (final url in NetworkConfig.relays) {
      final ws = _ch[url];
      ws?.sink.add(frame);
    }
    return id;
  }

  @override
  Future<void> close(String subId) async {
    if (!_subs.contains(subId)) return;
    _subs.remove(subId);
    final frame = jsonEncode(["CLOSE", subId]);
    for (final url in NetworkConfig.relays) {
      final ws = _ch[url];
      ws?.sink.add(frame);
    }
  }

  void _connect(String url) {
    if (_ch[url] != null) return;
    final uri = Uri.parse(url);
    try {
      final ws = factory(uri);
      _ch[url] = ws;
      _attempts[url] = 0;
      ws.stream.listen((msg) {
        try {
          final data = (msg is String) ? jsonDecode(msg) : msg;
          if (data is List && data.isNotEmpty) {
            switch (data[0]) {
              case 'EVENT':
                final evt = data.length > 2 ? data[2] : null;
                if (evt is Map<String, dynamic>) _eventsCtrl.add(evt);
                break;
              case 'EOSE':
                // End of stored events; ignore for now
                break;
              default:
                break;
            }
          }
        } catch (_) {/* ignore */}
      }, onDone: () => _scheduleReconnect(url),
          onError: (_) => _scheduleReconnect(url),
          cancelOnError: true);
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

  // helper:
  Future<Map<String, dynamic>> _sign(int kind, String content, List<List<String>> tags) async {
    final priv = await _keyService.getPrivkey();
    final pub  = await _keyService.getPubkey();
    if (priv == null || pub == null) {
      throw Exception('No keys present. Generate or import a key first.');
    }
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final e = NostrEvent(kind: kind, createdAt: now, content: content, tags: tags);
    return NostrEvent.sign(priv, pub, e);
  }

  @override
  Future<void> repost({required String eventId, String? originalJson}) async {
    final tags = <List<String>>[
      ["e", eventId],
    ];
    final evt = await _sign(6, originalJson ?? "", tags);
    await publishEvent(evt);
  }

  Future<void> quote({required String eventId, required String content}) async {
    final noteRef = Nip19.encodeNote(eventId);
    final tags = <List<String>>[
      ["e", eventId],
    ];
    final evt = await _sign(1, "$content\nnostr:$noteRef", tags);
    await publishEvent(evt);
  }

  @override
  Future<String> publishEvent(Map<String, dynamic> signedEventJson) async {
    final jsonStr = jsonEncode(["EVENT", signedEventJson]);
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
    return (signedEventJson['id'] as String?) ??
        'tmp_${DateTime.now().microsecondsSinceEpoch}';
  }

  @override
  Future<void> like({required String eventId}) async {
    final evt = await _sign(7, "+", [
      ["e", eventId],
    ]);
    await publishEvent(evt);
  }

  @override
  Future<void> reply(
      {required String parentId,
      required String content,
      String? parentPubkey}) async {
    final tags = <List<String>>[["e", parentId]];
    if (parentPubkey != null && parentPubkey.isNotEmpty) {
      tags.add(["p", parentPubkey]);
    }
    final evt = await _sign(1, content, tags);
    await publishEvent(evt);
  }

  @override
  Future<void> zapRequest(
      {required String eventId, required int millisats}) async {
    // Not implemented yet
  }

  @override
  Future<Map<String, dynamic>> buildZapRequest({
    required String recipientPubkey,
    required String eventId,
    String content = '',
    List<String>? relays,
  }) async {
    final tags = <List<String>>[
      ['p', recipientPubkey],
      ['e', eventId],
      if (relays != null && relays.isNotEmpty) ...relays.map((r) => ['relays', r]),
    ];
    return _sign(9734, content, tags);
  }
}
