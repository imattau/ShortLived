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
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
    });
  });
}
