import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nostr_video/ui/home/home_feed_page.dart';

void main() {
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
  });
}
