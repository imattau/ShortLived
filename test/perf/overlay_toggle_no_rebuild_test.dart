import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/ui/home/home_page.dart';
import '../test_helpers/test_video_scope.dart';

void main() {
  testWidgets('overlay toggle does not remove feed PageView', (t) async {
    await t.pumpWidget(const TestVideoApp(child: MaterialApp(home: HomePage())));
    await t.pumpAndSettle();

    final before = find.byType(PageView);
    expect(before, findsOneWidget);

    // Long-press anywhere (the overlay gesture layer handles it).
    await t.longPress(find.byType(Scaffold));
    await t.pump(const Duration(milliseconds: 200));

    // PageView must still be mounted.
    expect(find.byType(PageView), findsOneWidget);

    // Long-press again to show overlays.
    await t.longPress(find.byType(Scaffold));
    await t.pump(const Duration(milliseconds: 200));
    expect(find.byType(PageView), findsOneWidget);
  });
}
