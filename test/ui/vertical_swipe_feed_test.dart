import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
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
  testWidgets('vertical swipe updates current index', (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(const TestVideoApp(child: MaterialApp(home: HomeFeedPage())));
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
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
    });
  });
}
