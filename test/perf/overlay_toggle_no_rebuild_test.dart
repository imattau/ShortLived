import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/ui/home/home_feed_page.dart';
import '../test_utils/fake_video_player_platform.dart';

void main() {
  setUpAll(() {
    FakeVideoPlayerPlatform.register();
  });
  testWidgets('overlay toggle does not remove feed PageView', (tester) async {
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
  });
}
