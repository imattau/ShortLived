import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/ui/home/home_feed_page.dart';
import '../test_utils/fake_video_player_platform.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nostr_video/services/settings/settings_service.dart';
import 'package:nostr_video/services/queue/action_queue_memory.dart';
import 'package:nostr_video/services/queue/action_queue.dart';
import 'package:nostr_video/core/di/locator.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FakeVideoPlayerPlatform.register();
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    Locator.I.put<SettingsService>(SettingsService(sp));
    Locator.I.put<ActionQueue>(ActionQueueMemory());
  });
  testWidgets('overlay toggle does not remove feed PageView', (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(const MaterialApp(home: HomeFeedPage()));
      await tester.pumpAndSettle();
      final finder = find.byKey(const Key('feed-pageview'));
      expect(finder, findsOneWidget);
      await tester.longPress(find.byKey(const Key('feed-gesture')));
      await tester.pumpAndSettle();
      expect(finder, findsOneWidget);
      await tester.longPress(find.byKey(const Key('feed-gesture')));
      await tester.pumpAndSettle();
      expect(finder, findsOneWidget);
      // Remove the widget tree to allow controller disposal
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  });
}
