import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/services/nostr/relay_service_ws.dart';
import 'package:nostr_video/services/keys/key_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:stream_channel/stream_channel.dart';

class _KeyMem implements KeyService {
  final String _priv = '11' * 32;
  final String _pub = '02${'a' * 66}';
  @override
  Future<String?> getPrivkey() async => _priv;
  @override
  Future<String?> getPubkey() async => _pub;
  @override
  Future<String> generate() async => _pub;
  @override
  Future<String> importSecret(String s) async => _pub;
  @override
  Future<String?> exportNsec() async => null;
}

class _WSFake extends StreamChannelMixin<dynamic> implements WebSocketChannel {
  @override
  Stream<dynamic> get stream => const Stream.empty();

  @override
  WebSocketSink get sink => _Sink();

  @override
  int? get closeCode => null;

  @override
  String? get closeReason => null;

  @override
  String? get protocol => null;

  @override
  Future get ready => Future.value();
}

class _Sink implements WebSocketSink {
  @override
  void add(event) {}

  @override
  void addError(error, [StackTrace? st]) {}

  @override
  Future addStream(Stream stream) async {}

  @override
  Future close([int? code, String? reason]) async {}

  @override
  Future get done async {}
}

void main() {
  test('builds signed 9734 zap request', () async {
    final rs = RelayServiceWs(factory: (u) => _WSFake(), keyService: _KeyMem());
    await rs.init(const ['wss://example']);
    final evt =
        await rs.buildZapRequest(recipientPubkey: 'pk', eventId: 'evt1');
    expect(evt['kind'], 9734);
    expect((evt['sig'] as String).length >= 128, true);
  });
}
