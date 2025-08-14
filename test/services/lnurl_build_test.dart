import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/services/lightning/lightning_service_lnurl.dart';
import 'package:nostr_video/services/nostr/relay_service.dart';

class _NoopRelay implements RelayService {
  @override
  Future<void> init(List<String> relays) async {}
  @override
  Future<void> like({required String eventId}) async {}
  @override
  Future<String> publishEvent(Map<String, dynamic> e) async => 'id';
  @override
  Future<void> reply(
      {required String parentId,
      required String content,
      String? parentPubkey}) async {}
  @override
  Stream<List<dynamic>> subscribeFeed(
      {required List<String> authors, String? hashtag}) async* {}
  @override
  Stream<Map<String, dynamic>> get events async* {}
  @override
  Future<void> zapRequest(
      {required String eventId, required int millisats}) async {}

  @override
  Future<String> subscribe(List<Map<String, dynamic>> filters, {String? subId}) async => 'sub';

  @override
  Future<void> close(String subId) async {}

  @override
  Future<void> repost({required String eventId, String? originalJson}) async {}
}

void main() {
  test('builds lightning deep link', () {
    final svc = LightningServiceLnurl(_NoopRelay());
    final uri = svc.buildLnurl('alice@wallet.example', 1000, note: 'Hi');
    expect(uri.scheme, 'lightning');
    expect(uri.path, 'alice@wallet.example');
    expect(uri.queryParameters['amount'], '1000');
    expect(uri.queryParameters['comment'], 'Hi');
  });
}
