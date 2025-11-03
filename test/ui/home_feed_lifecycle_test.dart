import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/core/di/locator.dart';
import 'package:nostr_video/data/repos/feed_repository.dart';
import 'package:nostr_video/services/keys/key_service.dart';
import 'package:nostr_video/services/nostr/metadata_service.dart';
import 'package:nostr_video/services/nostr/relay_service.dart';
import 'package:nostr_video/services/settings/settings_service.dart';
import 'package:nostr_video/state/feed_controller.dart';
import 'package:nostr_video/ui/home/home_feed_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FeedControllerReplaySpy extends FeedController {
  _FeedControllerReplaySpy() : super(MockFeedRepository(count: 0));
  int replayCalls = 0;

  @override
  Future<void> replayQueue(RelayService relay) async {
    replayCalls++;
  }
}

class _RelayStub implements RelayService {
  @override
  Future<void> init(List<String> relays) async {}

  @override
  Future<String> publishEvent(Map<String, dynamic> signedEventJson) async => 'id';

  @override
  Future<String?> signAndPublish({
    required int kind,
    required String content,
    required List<List<String>> tags,
  }) async => 'id';

  @override
  Future<void> like({
    required String eventId,
    required String authorPubkey,
    String emojiOrPlus = '+',
  }) async {}

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
  Future<void> repost({required String eventId, String? originalJson}) async {}

  @override
  Future<void> zapRequest({required String eventId, required int millisats}) async {}

  @override
  Stream<Map<String, dynamic>> get events => const Stream.empty();

  @override
  Future<void> resetConnections(List<String> urls) async {}

  @override
  Future<Map<String, dynamic>> buildZapRequest({
    required String recipientPubkey,
    required String eventId,
    String content = '',
    List<String>? relays,
    int amountMsat = 0,
  }) async => {};

  @override
  Future<String> subscribe(List<Map<String, dynamic>> filters, {String? subId}) async => 'sub';

  @override
  Future<void> close(String subId) async {}

  @override
  Stream<List<dynamic>> subscribeFeed({
    required List<String> authors,
    String? hashtag,
  }) => const Stream.empty();
}

class _KeyServiceStub implements KeyService {
  @override
  Future<String?> exportNsec() async => null;

  @override
  Future<String> generate() async => 'pub';

  @override
  Future<String> importSecret(String nsecOrHex) async => 'pub';

  @override
  Future<String?> getPrivkey() async => 'priv';

  @override
  Future<String?> getPubkey() async => 'pub';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    Locator.I.remove<FeedController>();
    Locator.I.remove<RelayService>();
    Locator.I.remove<SettingsService>();
    Locator.I.remove<KeyService>();
    Locator.I.remove<MetadataService>();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('HomeFeedPage replays queue when app resumes', (tester) async {
    final controller = _FeedControllerReplaySpy();
    final prefs = await SharedPreferences.getInstance();
    Locator.I.put<FeedController>(controller);
    Locator.I.put<RelayService>(_RelayStub());
    Locator.I.put<SettingsService>(SettingsService(prefs));
    Locator.I.put<KeyService>(_KeyServiceStub());
    Locator.I.put<MetadataService>(MetadataService());

    addTearDown(() {
      controller.dispose();
      Locator.I.remove<FeedController>();
      Locator.I.remove<RelayService>();
      Locator.I.remove<SettingsService>();
      Locator.I.remove<KeyService>();
      Locator.I.remove<MetadataService>();
    });

    await tester.pumpWidget(const MaterialApp(home: HomeFeedPage()));
    await tester.pumpAndSettle();

    final observer = tester.state(find.byType(HomeFeedPage)) as WidgetsBindingObserver;
    observer.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await tester.pump();

    expect(controller.replayCalls, 1);
  });
}
