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
  testWidgets('opening create sheet pauses playback (banner visible)', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeFeedPage()));
    // Open the sheet by tapping the FAB
    final fab = find.byIcon(Icons.add);
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();
    // Paused banner should be visible while sheet is open
    expect(find.byKey(const Key('paused-banner')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
