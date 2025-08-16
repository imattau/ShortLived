import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/ui/home/home_page.dart';
import '../test_helpers/test_video_scope.dart';

void main() {
  testWidgets('App starts and shows a PageView', (t) async {
    await t
        .pumpWidget(const TestVideoApp(child: MaterialApp(home: HomePage())));
    await t.pump();
    expect(find.byType(PageView), findsOneWidget);
  });
}
