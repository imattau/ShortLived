import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nostr_video/ui/home/home_feed_page.dart';

void main() {
  testWidgets('paused flag toggles without removing PageView', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeFeedPage()));
    await tester.pumpAndSettle();
    final pv = find.byKey(const Key('feed-pageview'));
    expect(pv, findsOneWidget);
    // Long-press overlays to ensure no rebuild of PageView
    await tester.longPress(find.byType(GestureDetector));
    await tester.pumpAndSettle();
    expect(pv, findsOneWidget);
  });
}
