import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/services/lightning/lightning_service_lnurl.dart';
import 'package:nostr_video/services/nostr/relay_service.dart';
import 'dart:async';

class _RelayEvents implements RelayService {
  final _ctrl = StreamController<Map<String, dynamic>>.broadcast();
  @override
  Stream<Map<String, dynamic>> get events => _ctrl.stream;
  void emit(Map<String, dynamic> e) => _ctrl.add(e);
  // Unused:
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
  Future<void> zapRequest(
      {required String eventId, required int millisats}) async {}
}

void main() async {
  test('filters kind 9735 for event id', () async {
    final r = _RelayEvents();
    final l = LightningServiceLnurl(r);
    final got = <Map<String, dynamic>>[];
    final sub = l.listenForZapReceipts('evt123').listen(got.add);

    r.emit({
      "kind": 9735,
      "tags": [
        ["e", "evt123"],
        ["p", "pk"]
      ]
    });
    r.emit({
      "kind": 9735,
      "tags": [
        ["e", "other"]
      ]
    }); // ignored
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(got.length, 1);
    await sub.cancel();
  });
}
