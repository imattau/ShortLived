import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nostr_video/ui/home/home_page.dart';
import '../test_helpers/test_video_scope.dart';

void main() {
  testWidgets('Author appears only once', (t) async {
    await t
        .pumpWidget(const TestVideoApp(child: MaterialApp(home: HomePage())));
    await t.pumpAndSettle();
    // Author shown exactly once (in BottomInfoBar) by display name snippet:
    expect(find.textContaining('npub'), findsOneWidget);
  });

  testWidgets('Search sheet sits above HUD (HUD hidden)', (t) async {
    await t
        .pumpWidget(const TestVideoApp(child: MaterialApp(home: HomePage())));
    await t.pumpAndSettle();
    // Open search
    await t.tap(find.textContaining('Search'));
    await t.pumpAndSettle();
    // Create label should be hidden while sheet is open
    expect(find.text('Create'), findsNothing);
  });
}
