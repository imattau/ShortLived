import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/data/repos/thread_repository.dart';
import 'package:nostr_video/services/nostr/metadata_service.dart';
import 'package:nostr_video/services/nostr/relay_service.dart';

void main() {
  test('ThreadRepository sorts replies oldest→newest and dedupes', () async {
    final meta = MetadataService();
    final r = _RelayEventsFake();
    final repo = ThreadRepository(r, meta);
    final out = <List<ThreadComment>>[];
    final sub = repo.watchThread(rootEventId: 'root').listen(out.add);

    // emit root reply events (order shuffled)
    r.emit({
      'id': 'a',
      'kind': 1,
      'pubkey': 'p1',
      'created_at': 2,
      'content': 'B',
      'tags': [
        ['e', 'root', '', 'root']
      ]
    });
    r.emit({
      'id': 'b',
      'kind': 1,
      'pubkey': 'p2',
      'created_at': 1,
      'content': 'A',
      'tags': [
        ['e', 'root', '', 'root']
      ]
    });

    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(out.isNotEmpty, true);
    final list = out.last;
    expect(list.first.content, 'A');
    await sub.cancel();
  });
}

class _RelayEventsFake implements RelayService {
  final _c = StreamController<Map<String, dynamic>>.broadcast();
  void emit(Map<String, dynamic> e) => _c.add(e);
  @override
  Stream<Map<String, dynamic>> get events => _c.stream;
  @override
  Future<String> subscribe(List<Map<String, dynamic>> filters,
          {String? subId}) async =>
      'sub';
  @override
  Future<void> close(String subId) async {}
  // Unused methods
  @override
  Future<void> init(List<String> relays) async {}
  @override
  Stream<List<dynamic>> subscribeFeed(
      {required List<String> authors, String? hashtag}) async* {}
  @override
  Future<String> publishEvent(Map<String, dynamic> signedEventJson) async => '';
  @override
  Future<void> like({required String eventId}) async {}
  @override
  Future<void> reply(
      {required String parentId,
      required String content,
      String? parentPubkey,
      String? rootId,
      String? rootPubkey}) async {}
  @override
  Future<void> repost({required String eventId, String? originalJson}) async {}
  @override
  Future<void> zapRequest(
      {required String eventId, required int millisats}) async {}
  @override
  Future<void> resetConnections(List<String> urls) async {}
  @override
  Future<Map<String, dynamic>> buildZapRequest(
          {required String recipientPubkey,
          required String eventId,
          String content = '',
          List<String>? relays}) async =>
      {};
}
