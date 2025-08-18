import 'package:flutter/material.dart';
import '../pages/notifications_page.dart';
import '../pages/settings_page.dart';

/// Simple account menu bottom sheet with wired navigation.
class AccountMenuSheet extends StatelessWidget {
  const AccountMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_Item>[
      _Item(
        icon: Icons.notifications_outlined,
        label: 'Notifications',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const NotificationsPage()));
        },
      ),
      _Item(
        icon: Icons.settings_outlined,
        label: 'Settings',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const SettingsPage()));
        },
      ),
    ];

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: items.length,
          separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
          itemBuilder: (context, i) {
            final it = items[i];
            return ListTile(
              leading: Icon(it.icon),
              title: Text(it.label),
              onTap: it.onTap,
            );
          },
        ),
      ),
    );
  }
}

class _Item {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  _Item({required this.icon, required this.label, required this.onTap});
}

