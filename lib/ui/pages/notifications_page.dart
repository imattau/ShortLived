import 'package:flutter/material.dart';
import '../../app/routes.dart';

/// Placeholder Notifications screen.
/// Data wiring (repo/stream) will land in a later PR.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppLabels.notificationsTitle),
      ),
      body: const _EmptyNotifications(),
    );
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.notifications_none, size: 48),
          const SizedBox(height: 12),
          Text(
            'Your Nostr notifications will appear here.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
