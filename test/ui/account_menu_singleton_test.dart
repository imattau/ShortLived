import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/ui/home/home_page.dart';
import 'package:nostr_video/ui/overlay/widgets/viewer_avatar.dart';
import 'package:nostr_video/ui/overlay/widgets/account_menu.dart';
import 'package:nostr_video/ui/overlay/sheet_gate.dart';
import '../test_helpers/test_video_scope.dart';

void main() {
  testWidgets('avatar toggles single account menu instance', (t) async {
    await t
        .pumpWidget(const TestVideoApp(child: MaterialApp(home: HomePage())));
    await t.pumpAndSettle();

    final avatar = find.byType(ViewerAvatar);
    final ctx = t.element(avatar);

    // Tap to open.
    await t.tap(avatar);
    await t.pumpAndSettle();

    // Second toggle closes the sheet instead of stacking.
    // SheetGate closes via a post-frame callback; don't await here.
    SheetGate.toggleAccountMenu(ctx, accountMenuContent);
    await t.pumpAndSettle();
    expect(find.byType(BottomSheet), findsNothing);

    // Can open again
    await t.tap(avatar);
    await t.pumpAndSettle();
    expect(find.byType(BottomSheet), findsOneWidget);
  });
}
