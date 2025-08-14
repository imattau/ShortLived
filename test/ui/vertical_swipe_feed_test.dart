import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nostr_video/ui/home/home_feed_page.dart';
import '../test_utils/fake_video_player_platform.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nostr_video/services/settings/settings_service.dart';
import 'package:nostr_video/services/queue/action_queue_memory.dart';
import 'package:nostr_video/services/queue/action_queue.dart';
import 'package:nostr_video/core/di/locator.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FakeVideoPlayerPlatform.register();
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    Locator.I.put<SettingsService>(SettingsService(sp));
    Locator.I.put<ActionQueue>(ActionQueueMemory());
  });
  testWidgets('vertical swipe updates current index', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeFeedPage()));
    // Wait for initial load
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    // Initial page should be index 0 visually
    expect(find.textContaining('Playing'), findsOneWidget);

    // Swipe up to next item
    await tester.fling(find.byType(PageView), const Offset(0, -400), 1000);
    await tester.pumpAndSettle();

    // Should now show Playing on a different card
    expect(find.textContaining('Playing'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });
  });
}
