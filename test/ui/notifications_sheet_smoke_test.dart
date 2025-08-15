import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nostr_video/ui/sheets/notifications_sheet.dart';

void main() {
  testWidgets('sheet renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: NotificationsSheet())));
    expect(find.textContaining('Notifications'), findsOneWidget);
  });
}
