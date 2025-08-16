import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/ui/home/home_page.dart';
import '../test_helpers/test_video_scope.dart';

void main() {
  testWidgets('overlay toggle does not remove feed PageView', (tester) async {
    await tester.pumpWidget(const TestVideoApp(child: MaterialApp(home: HomePage())));
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
