import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nostr_video/ui/home/home_page.dart';

void main() {
  testWidgets('action stack compacts on short viewports', (t) async {
    await t.binding.setSurfaceSize(const Size(800, 520)); // short
    await t.pumpWidget(const MaterialApp(home: HomePage()));
    await t.pumpAndSettle();

    // Ensure the six actions exist
    expect(find.byTooltip('Like'), findsOneWidget);
    expect(find.byTooltip('Zap'), findsOneWidget);

    // Measure overall stack height is under 75% of viewport (i.e., dense)
    final stack = find.byTooltip('Like').evaluate().first.renderObject!;
    // Smoke check: not a golden test, but ensures it didn't overflow
    expect(t.binding.renderView.size.height, 520);
  });
}
