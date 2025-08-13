import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nostr_video/ui/sheets/relays_sheet.dart';
import 'package:nostr_video/services/settings/settings_service.dart';

void main() {
  testWidgets('add relay and toggle overlays default', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    final s = SettingsService(sp);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (_) => RelaysSheet(settings: s),
                ),
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Add a relay
    await tester.enterText(find.byType(TextField), 'wss://example.com');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Toggle overlays default hidden
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(s.relays().contains('wss://example.com'), true);
    expect(s.overlaysDefaultHidden(), true);
  });
}
