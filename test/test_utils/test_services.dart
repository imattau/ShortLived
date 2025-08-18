import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:nostr_video/services/settings/settings_service.dart';
import 'package:nostr_video/services/queue/action_queue.dart';
import 'package:nostr_video/services/queue/action_queue_memory.dart';
import 'package:nostr_video/services/nostr/relay_service.dart';
import 'package:nostr_video/services/cache/cache_service.dart';
import 'package:nostr_video/data/models/post.dart';
import 'package:nostr_video/data/models/author.dart';
import 'package:nostr_video/core/di/locator.dart';
import 'package:nostr_video/services/keys/key_service.dart';

class RelayServiceFake implements RelayService {
  final _ctrl = StreamController<Map<String, dynamic>>.broadcast();

  @override
  Stream<Map<String, dynamic>> get events => _ctrl.stream;

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
    Future<String> publishEvent(Map<String, dynamic> eventJson) async => 'id';
    @override
    Future<String?> signAndPublish({required int kind, required String content, required List<List<String>> tags}) async => 'id';

  @override
  Future<void> like({required String eventId, required String authorPubkey, String emojiOrPlus = '+'}) async {}

  @override
  Future<void> reply(
      {required String parentId,
      required String content,
      String? parentPubkey,
      String? rootId,
      String? rootPubkey}) async {}

  @override
  Future<void> zapRequest(
      {required String eventId, required int millisats}) async {}

  @override
  Future<void> repost({required String eventId, String? originalJson}) async {}

  @override
  Future<Map<String, dynamic>> buildZapRequest(
          {required String recipientPubkey,
          required String eventId,
          String content = '',
          List<String>? relays,
          int amountMsat = 0}) async =>
      {};

  @override
  Future<void> resetConnections(List<String> urls) async {}
}

class KeyServiceFake implements KeyService {
  @override
  Future<String?> getPrivkey() async => null;
  @override
  Future<String?> getPubkey() async => null;
  @override
  Future<String> generate() async => '';
  @override
  Future<String> importSecret(String nsecOrHex) async => '';
  @override
  Future<String?> exportNsec() async => null;
}

Future<void> setupTestLocator({Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sp = await SharedPreferences.getInstance();
  Locator.I.put<SettingsService>(SettingsService(sp));
  Locator.I.put<ActionQueue>(ActionQueueMemory());
  Locator.I.put<RelayService>(RelayServiceFake());
  Locator.I.put<KeyService>(KeyServiceFake());

  // Seed cache with sample posts so UI has content
  final cache = Locator.I.get<CacheService>();
  final posts = List.generate(
    5,
    (i) => Post(
      id: 'p$i',
      author: const Author(pubkey: 'pk', name: 'name', avatarUrl: ''),
      caption: 'caption $i',
      tags: const [],
      url: 'https://cdn/$i.mp4',
      thumb: 'https://cdn/$i.jpg',
      mime: 'video/mp4',
      width: 1,
      height: 1,
      duration: 1.0,
      createdAt: DateTime.fromMillisecondsSinceEpoch(i * 1000),
    ),
  );
  await cache.savePosts(posts);
}
