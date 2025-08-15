import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/data/repos/notifications_repository.dart';
import 'package:nostr_video/services/nostr/relay_service.dart';
import 'package:nostr_video/services/keys/signer.dart';
import 'package:nostr_video/services/nostr/metadata_service.dart';
import 'package:nostr_video/core/test_switches.dart';

class _RelayFake implements RelayService {
  final _c = StreamController<Map<String, dynamic>>.broadcast();
  @override
  Stream<Map<String, dynamic>> get events => _c.stream;
  @override
  Future<String> subscribe(List<Map<String, dynamic>> f, {String? subId}) async => 's';
  @override
  Future<void> close(String subId) async {}
  @override
  Future<void> init(List<String> relays) async {}
  @override
  Future<String> publishEvent(Map<String, dynamic> e) async => 'id';
  @override
  Future<void> like({required String eventId}) async {}
  @override
  Future<void> reply({required String parentId, required String content, String? parentPubkey, String? rootId, String? rootPubkey}) async {}
  @override
  Future<void> repost({required String eventId, String? originalJson}) async {}
  @override
  Future<void> zapRequest({required String eventId, required int millisats}) async {}
  @override
  Future<Map<String, dynamic>> buildZapRequest({required String recipientPubkey, required String eventId, String content = '', List<String>? relays}) async => {};
  @override
  Future<String?> signAndPublish({required int kind, required String content, required List<List<String>> tags}) async => 'id';
  @override
  Stream<List<dynamic>> subscribeFeed({required List<String> authors, String? hashtag}) => const Stream.empty();
  @override
  Future<void> resetConnections(List<String> urls) async {}
  void emit(Map<String,dynamic> e) => _c.add(e);
}

class _SignerFake implements Signer {
  @override
  Future<String?> getPubkey() async => '02${''.padRight(66, 'a')}';
  @override
  Future<Map<String, dynamic>?> sign(int kind, String content, List<List<String>> tags) async => {};
}

class _MetaMem implements MetadataService {
  final _m = <String, AuthorMeta>{};
  @override
  AuthorMeta? get(String pubkey) => _m[pubkey];
  @override
  Stream<AuthorMeta> get stream => const Stream.empty();
  @override
  void handleEvent(Map<String, dynamic> evt) {}
}

void main() async {
  setUp(() => TestSwitches.disableRelays = false);
  test('maps basic kinds to notifications', () async {
    final r = _RelayFake();
    final repo = NotificationsRepository(r, _SignerFake(), _MetaMem());
    await repo.start();
    r.emit({'id':'x1','kind':7,'pubkey':'p','created_at':10,'tags':[['p','me'],['e','post1']]});
    await Future<void>.delayed(const Duration(milliseconds: 1));
    final list = await repo.stream().firstWhere((l) => l.isNotEmpty);
    expect(list.first.type.name, 'like');
  });
}
