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
    // Create label should still be present but invisible while sheet is open
    final createFinder = find.text('Create');
    expect(createFinder, findsOneWidget);
    final opacityFinder = find
        .ancestor(of: createFinder, matching: find.byType(AnimatedOpacity))
        .first;
    final animatedOpacity = t.widget<AnimatedOpacity>(opacityFinder);
    expect(animatedOpacity.opacity, equals(0));
  });
}
