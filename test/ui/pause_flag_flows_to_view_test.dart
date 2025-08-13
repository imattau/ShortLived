import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/ui/home/home_feed_page.dart';
import '../test_utils/fake_video_player_platform.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    FakeVideoPlayerPlatform.register();
  });
  testWidgets('paused flag toggles without removing PageView', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeFeedPage()));
    await tester.pumpAndSettle();
    final pv = find.byKey(const Key('feed-pageview'));
    expect(pv, findsOneWidget);
    // Long-press overlays to ensure no rebuild of PageView
    await tester.longPress(find.byKey(const Key('feed-gesture')));
    await tester.pumpAndSettle();
    expect(pv, findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
