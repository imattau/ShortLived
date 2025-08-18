import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/app/routes.dart';
import 'package:nostr_video/ui/pages/notifications_page.dart';
import 'package:nostr_video/ui/pages/settings_page.dart';
import 'package:nostr_video/ui/sheets/account_menu_sheet.dart';

void main() {
  testWidgets('Account menu items navigate to pages', (tester) async {
    await tester.pumpWidget(MaterialApp(
      routes: {
        AppRoutes.notifications: (_) => const NotificationsPage(),
        AppRoutes.settings: (_) => const SettingsPage(),
      },
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              key: const Key('open_account_menu'),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  useRootNavigator: true,
                  builder: (_) => const AccountMenuSheet(),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.byKey(const Key('open_account_menu')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Notifications'));
    await tester.pumpAndSettle();
    expect(find.text(AppLabels.notificationsTitle), findsOneWidget);

    Navigator.of(tester.element(find.text(AppLabels.notificationsTitle))).pop();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open_account_menu')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text(AppLabels.settingsTitle), findsOneWidget);
  });
}
