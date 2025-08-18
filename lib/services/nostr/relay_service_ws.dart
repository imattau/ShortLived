import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'backoff.dart';
import 'relay_service.dart';
import '../../crypto/nip19.dart';
import '../keys/signer.dart';
import '../../core/di/locator.dart';
import 'events/reaction_event.dart';
import 'events/zap_request_event.dart';

typedef WebSocketFactory = WebSocketChannel Function(Uri uri);

class RelayServiceWs implements RelayService {
  final WebSocketFactory factory;
  final Map<String, WebSocketChannel?> _ch = {};
  final Map<String, int> _attempts = {};
  final Backoff _backoff;
  final _eventsCtrl = StreamController<Map<String, dynamic>>.broadcast();
  final Set<String> _subs = {};
  final _rand = const Uuid();
  @override
  Stream<Map<String, dynamic>> get events => _eventsCtrl.stream;

  late final Signer _signer = Locator.I.get<Signer>();

  RelayServiceWs({required this.factory, Backoff? backoff})
      : _backoff = backoff ?? Backoff();

  @override
  Future<void> init(List<String> relays) async {
    for (final r in relays) {
      _connect(r);
    }
  }

  @override
  Future<String> subscribe(List<Map<String, dynamic>> filters,
      {String? subId}) async {
    final id = subId ?? _rand.v4();
    _subs.add(id);
    final frame = jsonEncode(["REQ", id, ...filters]);
    for (final url in _ch.keys) {
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
    for (final url in _ch.keys) {
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
      },
          onDone: () => _scheduleReconnect(url),
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
  Future<Map<String, dynamic>?> _sign(
      int kind, String content, List<List<String>> tags) {
    return _signer.sign(kind, content, tags);
  }

  @override
  Future<String?> signAndPublish({
    required int kind,
    required String content,
    required List<List<String>> tags,
  }) async {
    final evt = await _sign(kind, content, tags);
    if (evt == null) return null;
    return publishEvent(evt);
  }

  @override
  Future<void> repost({required String eventId, String? originalJson}) async {
    final tags = <List<String>>[
      ["e", eventId],
    ];
    await signAndPublish(kind: 6, content: originalJson ?? "", tags: tags);
  }

  Future<void> quote({required String eventId, required String content}) async {
    final noteRef = Nip19.encodeNote(eventId);
    final tags = <List<String>>[
      ["e", eventId],
    ];
    await signAndPublish(
        kind: 1, content: "$content\nnostr:$noteRef", tags: tags);
  }

  @override
  Future<String> publishEvent(Map<String, dynamic> signedEventJson) async {
    final jsonStr = jsonEncode(["EVENT", signedEventJson]);
    for (final url in _ch.keys) {
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
  Future<void> like({
    required String eventId,
    required String authorPubkey,
    String emojiOrPlus = '+',
  }) async {
    final builder = ReactionEventBuilder(
      content: emojiOrPlus,
      targetEventId: eventId,
      targetAuthorPubkey: authorPubkey,
    );
    await signAndPublish(kind: 7, content: builder.content, tags: builder.toTags());
  }

  @override
  Future<void> reply({
    required String parentId,
    required String content,
    String? parentPubkey,
    String? rootId,
    String? rootPubkey,
  }) async {
    // NIP-10: prefer explicit root; otherwise assume parent is root.
    final rid = rootId ?? parentId;
    final rpk = rootPubkey ?? parentPubkey ?? '';
    final tags = <List<String>>[
      ['e', rid, '', 'root'],
      if (parentId != rid) ['e', parentId, '', 'reply'],
      if (rpk.isNotEmpty) ['p', rpk],
    ];
    await signAndPublish(kind: 1, content: content, tags: tags);
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
    required int amountMsat,
  }) async {
    final builder = ZapRequestBuilder(
      recipientPubkey: recipientPubkey,
      targetEventId: eventId,
      amountMsat: amountMsat,
      relays: relays ?? const [],
      content: content,
    );
    final pub = await _signer.getPubkey();
    if (pub == null) return <String, dynamic>{};
    final unsigned = builder.toUnsigned(pubkey: pub);
    final tags = (unsigned['tags'] as List)
        .map((e) => (e as List).cast<String>())
        .toList();
    final evt = await _sign(9734, unsigned['content'] as String, tags);
    return evt ?? <String, dynamic>{};
  }

  @override
  Future<void> resetConnections(List<String> urls) async {
    final keep = urls.toSet();
    for (final url in _ch.keys.toList()) {
      if (!keep.contains(url)) {
        try {
          await _ch[url]?.sink.close();
        } catch (_) {}
        _ch.remove(url);
        _attempts.remove(url);
      }
    }
    for (final u in urls) {
      if (!_ch.containsKey(u)) {
        _connect(u);
      }
    }
  }
}
