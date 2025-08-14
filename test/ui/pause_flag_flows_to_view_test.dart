import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/ui/home/home_feed_page.dart';
import '../test_utils/fake_video_player_platform.dart';
import '../test_utils/test_services.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FakeVideoPlayerPlatform.register();
    await setupTestLocator();
  });
  testWidgets('paused flag toggles without removing PageView', (tester) async {
    await mockNetworkImagesFor(() async {
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
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
    });
  });
}
