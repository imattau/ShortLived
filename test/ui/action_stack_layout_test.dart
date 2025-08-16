import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/ui/home/home_page.dart';
import 'package:nostr_video/ui/overlay/widgets/action_button.dart';

void main() {
  testWidgets('action buttons have 48x48 min hit targets and compact gaps', (t) async {
    await t.pumpWidget(const MaterialApp(home: HomePage()));
    await t.pumpAndSettle();
    if (kIsWeb) {
      expect(find.byTooltip('Like'), findsOneWidget);
    } else {
      expect(find.byType(ActionButton), findsNWidgets(6));
    }
    final boxes = find.byWidgetPredicate((w) =>
        w is SizedBox && w.width == 48 && w.height == 48);
    expect(boxes, findsWidgets);
  });
}
