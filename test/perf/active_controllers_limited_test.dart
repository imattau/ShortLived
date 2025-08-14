import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  testWidgets('keeps at most 3 active controllers (±1)', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeFeedPage()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('active-controllers')), findsOneWidget);
    for (var i = 0; i < 6; i++) {
      await tester.fling(find.byKey(const Key('feed-pageview')), const Offset(0, -400), 1000);
      await tester.pumpAndSettle();
      final text = tester.widget<Text>(find.byKey(const Key('active-controllers'))).data!;
      final n = int.parse(text);
      expect(n <= 3, true);
    }
    // Remove the widget tree to ensure controllers are disposed
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    // Allow async disposals (pause/dispose) to run so timers are cleared
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    });
  });
}
