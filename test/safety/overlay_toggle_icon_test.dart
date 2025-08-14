import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nostr_video/ui/home/home_feed_page.dart';
import 'package:nostr_video/services/settings/settings_service.dart';
import 'package:nostr_video/core/di/locator.dart';
import 'package:nostr_video/core/testing/test_switches.dart';
import 'package:nostr_video/services/keys/key_service.dart';
import 'package:nostr_video/services/nostr/relay_service.dart';
import 'package:nostr_video/state/feed_controller.dart';
import 'package:nostr_video/data/repos/feed_repository.dart';
import 'package:nostr_video/services/queue/action_queue.dart';
import 'package:nostr_video/services/queue/action_queue_memory.dart';

class _KeyServiceStub implements KeyService {
  @override
  Future<String?> getPrivkey() async => null;
  @override
  Future<String?> getPubkey() async => null;
  @override
  Future<String> generate() async => 'pk';
  @override
  Future<String> importSecret(String nsecOrHex) async => 'pk';
  @override
  Future<String?> exportNsec() async => null;
}

class _RelayServiceStub implements RelayService {
  @override
  Future<void> init(List<String> relays) async {}
  @override
  Future<String> subscribe(List<Map<String, dynamic>> filters, {String? subId}) async => 'sub';
  @override
  Future<void> close(String subId) async {}
  @override
  Stream<List<dynamic>> subscribeFeed({required List<String> authors, String? hashtag}) => const Stream.empty();
  @override
  Future<String> publishEvent(Map<String, dynamic> signedEventJson) async => 'id';
  @override
  Future<void> like({required String eventId}) async {}
  @override
  Future<void> reply({required String parentId, required String content, String? parentPubkey}) async {}
  @override
  Future<void> repost({required String eventId, String? originalJson}) async {}
  @override
  Future<void> zapRequest({required String eventId, required int millisats}) async {}
  @override
  Stream<Map<String, dynamic>> get events => const Stream.empty();
}

void main() {
  testWidgets('safety shield toggles', (tester) async {
    TestSwitches.disableVideo = true;
    TestSwitches.disableRelays = true;
    SharedPreferences.setMockInitialValues({'sensitive_blur_enabled': true});
    final sp = await SharedPreferences.getInstance();
    final settings = SettingsService(sp);
    Locator.I.put<SettingsService>(settings);
    Locator.I.put<KeyService>(_KeyServiceStub());
    Locator.I.put<RelayService>(_RelayServiceStub());
    Locator.I.put<ActionQueue>(ActionQueueMemory());
    Locator.I.put<FeedController>(FeedController(MockFeedRepository(count: 0)));

    await tester.pumpWidget(const MaterialApp(home: HomeFeedPage()));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.shield), findsOneWidget);
  });
}
