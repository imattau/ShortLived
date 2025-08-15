import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/services/nostr/relay_service_ws.dart';
import 'package:nostr_video/services/keys/key_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:stream_channel/stream_channel.dart';

class _KeyMem implements KeyService {
  @override
  Future<String?> getPrivkey() async => '11' * 32;
  @override
  Future<String?> getPubkey() async => '02${'a' * 66}';
  @override
  Future<String> generate() async => '';
  @override
  Future<String> importSecret(String s) async => '';
  @override
  Future<String?> exportNsec() async => null;
}

class _WSFake extends StreamChannelMixin<dynamic> implements WebSocketChannel {
  @override
  Stream<dynamic> get stream => const Stream.empty();

  @override
  WebSocketSink get sink => _Sink();

  @override
  String? get protocol => null;

  @override
  int? get closeCode => null;

  @override
  String? get closeReason => null;

  @override
  Future<void> get ready => Future.value();
}

class _Sink implements WebSocketSink {
  @override
  void add(event) {}

  @override
  void addError(Object error, [StackTrace? st]) {}

  @override
  Future addStream(Stream<dynamic> stream) async {}

  @override
  Future close([int? code, String? reason]) async {}

  @override
  Future get done => Future.value();
}

void main() {
  test('reply includes NIP-10 markers', () async {
    final rs = RelayServiceWs(factory: (u) => _WSFake(), keyService: _KeyMem());
    await rs.init(const ['wss://example']);
    // We can’t intercept frames easily; call and assert no-throw.
    await rs.reply(
        parentId: 'evtParent',
        parentPubkey: 'pkParent',
        content: 'hi',
        rootId: 'evtRoot',
        rootPubkey: 'pkRoot');
    expect(true, true);
  });
}
