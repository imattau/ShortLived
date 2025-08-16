import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nostr_video/ui/home/home_page.dart';
import '../test_helpers/test_video_scope.dart';

void main() {
  testWidgets('Mute toggle updates current page without removing PageView', (t) async {
    await t.pumpWidget(const TestVideoApp(child: MaterialApp(home: HomePage())));
    await t.pumpAndSettle();

    expect(find.byType(PageView), findsOneWidget);

    final unmute = find.textContaining('Mute', findRichText: true);
    expect(unmute, findsOneWidget);

    await t.tap(unmute);
    await t.pump(const Duration(milliseconds: 50));

    expect(find.byType(PageView), findsOneWidget);
  });
}
