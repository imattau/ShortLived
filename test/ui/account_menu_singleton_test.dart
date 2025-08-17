import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/ui/home/home_page.dart';
import 'package:nostr_video/ui/overlay/widgets/viewer_avatar.dart';

void main() {
  testWidgets('avatar toggles single account menu instance', (t) async {
    await t.pumpWidget(const MaterialApp(home: HomePage()));
    await t.pumpAndSettle();

    final avatar = find.byType(ViewerAvatar);

    // Tap twice quickly; the menu should not stack and ends closed.
    await t.tap(avatar);
    await t.tap(avatar);
    await t.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);

    // Can open again
    await t.tap(avatar);
    await t.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
  });
}
