import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/services/moderation/mute_service.dart';
import 'package:nostr_video/services/settings/settings_service.dart';
import 'package:nostr_video/services/nostr/relay_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RelayNoop implements RelayService {
  @override
  Future<void> init(List<String> relays) async {}

  @override
  Future<String> subscribe(List<Map<String, dynamic>> filters,
          {String? subId}) async =>
      's';

  @override
  Future<void> close(String subId) async {}

  @override
  Stream<List<dynamic>> subscribeFeed(
          {required List<String> authors, String? hashtag}) =>
      Stream<List<dynamic>>.empty();

  @override
  Future<String> publishEvent(Map<String, dynamic> e) async {
    expect(e['kind'], 10000);
    return e['id'] as String? ?? 'id';
  }

  @override
  Future<String?> signAndPublish({required int kind, required String content, required List<List<String>> tags}) async {
    return 'id';
  }

  @override
  Future<void> like({required String eventId, required String authorPubkey, String emojiOrPlus = '+'}) async {}

  @override
  Future<void> reply({
    required String parentId,
    required String content,
    String? parentPubkey,
    String? rootId,
    String? rootPubkey,
  }) async {}

  @override
  Future<void> quote({required String eventId, required String content}) async {}

  @override
  Future<void> zapRequest(
      {required String eventId, required int millisats}) async {}

  @override
  Future<void> repost({required String eventId, String? originalJson}) async {}

  @override
  Future<void> resetConnections(List<String> urls) async {}

  @override
  Stream<Map<String, dynamic>> get events => const Stream.empty();

  @override
  Future<Map<String, dynamic>> buildZapRequest({
    required String recipientPubkey,
    required String eventId,
    String content = '',
    List<String>? relays,
    int amountMsat = 0,
  }) async =>
      {};
}

void main() {
  test('publishes kind 10000 with p/e/t/word tags', () async {
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    final svc = MuteService(SettingsService(sp), _RelayNoop());
    await svc.muteUser('pk1');
    await svc.muteTag('nsfw');
    await svc.muteWord('spoiler');
    await svc.muteEvent('evt1');
    final list = svc.current();
    expect(list.users.contains('pk1'), true);
    expect(list.tags.contains('nsfw'), true);
    expect(list.words.contains('spoiler'), true);
    expect(list.events.contains('evt1'), true);
  });
}
