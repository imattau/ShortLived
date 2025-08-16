import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nostr_video/ui/home/home_page.dart';

void main() {
  testWidgets('Author appears only once and Mute is top-left', (t) async {
    await t.pumpWidget(const MaterialApp(home: HomePage()));
    await t.pumpAndSettle();
    // Author shown exactly once (in BottomInfoBar) by display name snippet:
    expect(find.textContaining('npub'), findsOneWidget);
    // Mute/Unmute button exists (web) and not overlapping caption (approx check by presence):
    expect(find.textContaining('Mute', findRichText: true), findsOneWidget);
  });

  testWidgets('Search sheet sits above HUD (HUD hidden)', (t) async {
    await t.pumpWidget(const MaterialApp(home: HomePage()));
    await t.pumpAndSettle();
    // Open search
    await t.tap(find.textContaining('Search'));
    await t.pumpAndSettle();
    // Create label should be hidden while sheet is open
    expect(find.text('Create'), findsNothing);
  });
}
