import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nostr_video/ui/home/home_feed_page.dart';

void main() {
  testWidgets('vertical swipe updates current index', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeFeedPage()));
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
  });
}
