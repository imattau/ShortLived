import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nostr_video/ui/home/home_feed_page.dart';
import '../test_utils/fake_video_player_platform.dart';

void main() {
  setUpAll(() {
    FakeVideoPlayerPlatform.register();
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
  });
}
