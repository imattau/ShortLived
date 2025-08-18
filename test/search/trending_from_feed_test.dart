import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/services/search/search_service.dart';
import 'package:nostr_video/data/models/post.dart';
import 'package:nostr_video/data/models/author.dart';
import 'package:nostr_video/services/nostr/relay_service.dart';

void main() {
  test('trending hashtags ranks by frequency', () {
    final svc = SearchService(FakeRelay());
    final posts = [
      Post(
          id: '1',
          author: const Author(pubkey: 'a', name: 'a', avatarUrl: ''),
          caption: '#dart #nostr',
          tags: const [],
          url: 'u',
          thumb: 't',
          mime: 'video/mp4',
          width: 1,
          height: 1,
          duration: 1,
          createdAt: DateTime.now()),
      Post(
          id: '2',
          author: const Author(pubkey: 'a', name: 'a', avatarUrl: ''),
          caption: 'nice #nostr clip',
          tags: const [],
          url: 'u',
          thumb: 't',
          mime: 'video/mp4',
          width: 1,
          height: 1,
          duration: 1,
          createdAt: DateTime.now()),
    ];
    final top = svc.trendingHashtags(posts);
    expect(top.first, 'nostr');
  });
}

// Minimal fakes to satisfy type params (not used in this unit)
class FakeRelay implements RelayService {
  @override
  Future<void> init(List<String> relays) async {}

  @override
  Future<String> subscribe(List<Map<String, dynamic>> filters,
          {String? subId}) async =>
      '';

  @override
  Future<void> close(String subId) async {}

  @override
  Stream<List<dynamic>> subscribeFeed(
          {required List<String> authors, String? hashtag}) =>
      const Stream.empty();

    @override
    Future<String> publishEvent(Map<String, dynamic> signedEventJson) async => '';
    @override
    Future<String?> signAndPublish({required int kind, required String content, required List<List<String>> tags}) async => '';

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
  Future<void> repost({required String eventId, String? originalJson}) async {}

  @override
  Future<void> zapRequest(
      {required String eventId, required int millisats}) async {}

  @override
  Stream<Map<String, dynamic>> get events => const Stream.empty();

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
