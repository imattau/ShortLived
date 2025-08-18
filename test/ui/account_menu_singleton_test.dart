import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/ui/home/home_page.dart';
import 'package:nostr_video/ui/widgets/current_user_badge.dart';
import '../test_helpers/test_video_scope.dart';

void main() {
  testWidgets('avatar toggles single account menu instance', (t) async {
    await t
        .pumpWidget(const TestVideoApp(child: MaterialApp(home: HomePage())));
    await t.pumpAndSettle();

    final avatar = find.byType(CurrentUserBadge);

    // Tap to open.
    await t.tap(avatar);
    await t.pumpAndSettle();

    // Second tap closes the sheet instead of stacking.
    await t.tap(avatar);
    await t.pump(); // let scheduled close run
    await t.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);

    // Can open again
    await t.tap(avatar);
    await t.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
  });
}
