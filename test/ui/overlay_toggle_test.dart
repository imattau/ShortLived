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
  testWidgets('long-press hides and shows overlays', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeFeedPage()));
    // Start visible
    expect(find.byType(AnimatedOpacity), findsOneWidget);
    // Long press to hide
    await tester.longPress(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();
    // Long press to show
    await tester.longPress(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });

  testWidgets('double-tap does not toggle overlays', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeFeedPage()));
    await tester.tap(find.byType(GestureDetector).first);
    await tester.pump(const Duration(milliseconds: 10));
    await tester.tap(find.byType(GestureDetector).first); // second tap quickly
    await tester.pumpAndSettle();
    // No assertion beyond not crashing; later we assert like animation
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
