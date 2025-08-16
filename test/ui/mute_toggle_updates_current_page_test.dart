import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/ui/home/home_page.dart';
import '../test_helpers/test_video_scope.dart';

void main() {
  testWidgets('Mute toggle updates current page without removing PageView',
      (t) async {
    await t.pumpWidget(
      const TestVideoApp(child: MaterialApp(home: HomePage())),
    );
    await t.pumpAndSettle();

    expect(find.byType(PageView), findsOneWidget);

    // Keyboard shortcut `M` toggles mute via the controller.
    await t.sendKeyDownEvent(LogicalKeyboardKey.keyM);
    await t.pump();

    // PageView must still be mounted after mute toggle.
    expect(find.byType(PageView), findsOneWidget);
  });
}
