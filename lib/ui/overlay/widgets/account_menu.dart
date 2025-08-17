import 'package:flutter/material.dart';
import '../../../session/user_session.dart';

Future<void> showAccountMenu(BuildContext context) async {
  final p = userSession.current.value;
  await showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF0E0E11),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => SafeArea(
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
              title: const Text('Notifications',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: open notifications
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Colors.white70),
              title:
                  const Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // TODO: open settings
              },
            ),
          ],
        ),
      ),
    ),
  );
}
