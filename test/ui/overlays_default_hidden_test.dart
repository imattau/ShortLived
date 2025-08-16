import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nostr_video/ui/home/home_feed_page.dart';
import '../test_utils/test_services.dart';
import '../test_helpers/test_video_scope.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await setupTestLocator(prefs: {'overlays_default_hidden': true});
  });
  testWidgets('overlays are hidden on open when setting is true', (
    tester,
  ) async {
    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(const TestVideoApp(child: MaterialApp(home: HomeFeedPage())));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('overlay-visibility')), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
    });
  });
}
