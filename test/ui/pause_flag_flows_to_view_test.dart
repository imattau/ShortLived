import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/ui/home/home_feed_page.dart';
import 'package:nostr_video/state/feed_controller.dart';
import 'package:nostr_video/data/repos/feed_repository.dart';
import 'package:nostr_video/core/di/locator.dart';
import '../test_utils/test_services.dart';
import '../test_helpers/test_video_scope.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await setupTestLocator();
    Locator.I.put<FeedController>(FeedController(MockFeedRepository(count: 5)));
  });
  testWidgets('paused flag toggles without removing PageView', (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(const TestVideoApp(child: MaterialApp(home: HomeFeedPage())));
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
  });
}
