import 'package:flutter/material.dart';
import '../sheet_gate.dart';
import '../../../session/user_session.dart';
import '../../../app/routes.dart';

Future<void> showAccountMenu(BuildContext context) {
  return SheetGate.openAccountMenu(context, accountMenuContent);
}

Widget accountMenuContent(BuildContext context) {
  final p = userSession.current.value;
  void navigateAfterClose(String route) {
    final navigator = Navigator.of(context, rootNavigator: true);
    navigator.maybePop();
    Future.microtask(() {
      navigator.pushNamed(route);
    });
  }

  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white24,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  p?.displayName ?? 'Guest',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.notifications, color: Colors.white70),
            title:
                const Text('Notifications', style: TextStyle(color: Colors.white)),
            onTap: () => navigateAfterClose(AppRoutes.notifications),
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white70),
            title: const Text('Settings', style: TextStyle(color: Colors.white)),
            onTap: () => navigateAfterClose(AppRoutes.settings),
          ),
        ],
      ),
    ),
  );
}
