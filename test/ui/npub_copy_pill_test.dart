import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/ui/overlay/widgets/npub_pill.dart';

void main() {
  testWidgets('NpubPill renders and can be tapped', (t) async {
    await t.pumpWidget(const MaterialApp(
        home: Scaffold(body: NpubPill(npub: 'npub1xyz1234567890'))));
    expect(find.textContaining('npub'), findsOneWidget);
    await t.tap(find.byType(NpubPill));
    await t.pump();
    expect(t.takeException(), isNull);
  });
}
