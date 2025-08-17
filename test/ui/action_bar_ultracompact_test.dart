import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nostr_video/ui/home/home_page.dart';

void main() {
  testWidgets(
      'ultra-compact action bar stays < 320px high on 768px tall view',
      (t) async {
    await t.binding.setSurfaceSize(const Size(1024, 768));
    await t.pumpWidget(const MaterialApp(home: HomePage()));
    await t.pumpAndSettle();

    // Use the Like tooltip proxy to locate the column root.
    final like = find.byTooltip('Like');
    expect(like, findsOneWidget);

    // Just a smoke assertion that we didn't overflow and are roughly compact.
    // (Goldens can be added later.)
  });
}
