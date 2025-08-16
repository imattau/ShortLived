import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/ui/widgets/app_icon.dart';

void main() {
  testWidgets('AppIcon falls back to Material icon when vec missing',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: AppIcon('nonexistent_24'))),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}

