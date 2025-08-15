import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nostr_video/ui/sheets/key_management_sheet.dart';

void main() {
  testWidgets('Key sheet renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: KeyManagementSheet())));
    expect(find.textContaining('Keys'), findsOneWidget);
    expect(find.text('Generate new'), findsOneWidget);
  });
}

