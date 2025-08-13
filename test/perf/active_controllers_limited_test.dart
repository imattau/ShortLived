import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/ui/home/home_feed_page.dart';
import '../test_utils/fake_video_player_platform.dart';

void main() {
  setUpAll(() {
    FakeVideoPlayerPlatform.register();
  });
  testWidgets('keeps at most 3 active controllers (±1)', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeFeedPage()));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('active-controllers')), findsOneWidget);
    for (var i = 0; i < 6; i++) {
      await tester.fling(find.byKey(const Key('feed-pageview')), const Offset(0, -400), 1000);
      await tester.pumpAndSettle();
      final text = tester.widget<Text>(find.byKey(const Key('active-controllers'))).data!;
      final n = int.parse(text);
      expect(n <= 3, true);
    }
  });
}
