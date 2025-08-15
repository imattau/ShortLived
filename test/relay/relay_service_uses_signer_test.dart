import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/services/nostr/relay_service_ws.dart';
import 'package:nostr_video/services/keys/signer.dart';
import 'package:nostr_video/core/di/locator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:stream_channel/stream_channel.dart';

class _SignerFake implements Signer {
  @override
  Future<String?> getPubkey() async => '02' + 'a' * 66;
  @override
  Future<Map<String, dynamic>?> sign(int k, String c, List<List<String>> t) async => {
        'kind': k,
        'content': c,
        'tags': t,
        'id': 'id',
        'pubkey': '02' + 'a' * 66,
        'sig': 's'
      };
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
  test('signAndPublish uses Signer', () async {
    final rs = RelayServiceWs(factory: (u) => _WSFake());
    Locator.I.put<Signer>(_SignerFake());
    await rs.init(const ['wss://example']);
    final id = await rs.signAndPublish(kind: 1, content: 'hi', tags: const []);
    expect(id, isNotNull);
  });
}
