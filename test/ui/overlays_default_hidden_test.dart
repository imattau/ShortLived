import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nostr_video/ui/home/home_feed_page.dart';
import '../test_utils/fake_video_player_platform.dart';

void main() {
  setUpAll(() {
    FakeVideoPlayerPlatform.register();
  });
  testWidgets('overlays are hidden on open when setting is true', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'overlays_default_hidden': true});
    await tester.pumpWidget(const MaterialApp(home: HomeFeedPage()));
    await tester.pumpAndSettle();
    expect(find.byType(AnimatedOpacity), findsOneWidget);
  });
}
