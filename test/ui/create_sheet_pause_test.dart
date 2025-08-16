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
  testWidgets('opening create sheet pauses playback (banner visible)', (tester) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(const TestVideoApp(child: MaterialApp(home: HomeFeedPage())));
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
  });
}
