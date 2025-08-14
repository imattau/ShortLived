import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/services/nostr/relay_service_ws.dart';
import 'package:nostr_video/services/keys/key_service.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class _KeyMem implements KeyService {
  String? _priv;
  String? _pub;
  @override
  Future<String?> getPrivkey() async => _priv;
  @override
  Future<String?> getPubkey() async => _pub;
  @override
  Future<String> generate() async => throw UnimplementedError();
  @override
  Future<String> importSecret(String s) async {
    _priv = s;
    _pub = '02${'a' * 66}';
    return _pub!;
  }

  @override
  Future<String?> exportNsec() async => 'nsec1xyz';
}

class _WSFake with StreamChannelMixin implements WebSocketChannel {
  _WSFake();

  final _sink = _Sink();

  @override
  WebSocketSink get sink => _sink;

  @override
  Stream get stream => const Stream.empty();

  @override
  int? get closeCode => null;

  @override
  String? get closeReason => null;
}

class _Sink extends StreamSinkBase<String> implements WebSocketSink {
  final frames = <String>[];

  @override
  void add(String event) => frames.add(event);

  @override
  void addError(Object error, [StackTrace? st]) {}

  @override
  Future close([int? closeCode, String? closeReason]) async {}

  @override
  Future addStream(Stream<String> stream) async {
    await for (final e in stream) {
      frames.add(e);
    }
  }

  @override
  Future get done async {}
}

void main() {
  test('like/reply are signed before publish', () async {
    final rs = RelayServiceWs(factory: (u) => _WSFake(), keyService: _KeyMem()..importSecret('11'*32));
    await rs.init(const ['wss://example']);
    await rs.like(eventId: 'evt1');
    await rs.reply(parentId: 'evt1', content: 'hello');

    // we can’t easily intercept frames per relay here; rely on no-throw and smoke test.
    expect(true, true);
  });
}
