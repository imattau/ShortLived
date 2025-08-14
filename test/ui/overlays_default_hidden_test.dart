import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nostr_video/ui/home/home_feed_page.dart';
import '../test_utils/fake_video_player_platform.dart';
import 'package:nostr_video/services/settings/settings_service.dart';
import 'package:nostr_video/services/queue/action_queue_memory.dart';
import 'package:nostr_video/services/queue/action_queue.dart';
import 'package:nostr_video/core/di/locator.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FakeVideoPlayerPlatform.register();
    SharedPreferences.setMockInitialValues({'overlays_default_hidden': true});
    final sp = await SharedPreferences.getInstance();
    Locator.I.put<SettingsService>(SettingsService(sp));
    Locator.I.put<ActionQueue>(ActionQueueMemory());
  });
  testWidgets('overlays are hidden on open when setting is true', (
    tester,
  ) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(const MaterialApp(home: HomeFeedPage()));
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedOpacity), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
    });
  });
}
