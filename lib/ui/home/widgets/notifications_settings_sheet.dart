import 'package:flutter/material.dart';

import '../../../notifications/notifications_prefs.dart';
import '../../../notifications/notifications_store.dart';
import '../../design/tokens.dart';
import '../../../web_push/web_push.dart';

/// Bottom sheet allowing users to toggle notification visibility and badge
/// behaviour.
class NotificationsSettingsSheet extends StatefulWidget {
  const NotificationsSettingsSheet({super.key, required this.store});

  final NotificationsStore store;

  @override
  State<NotificationsSettingsSheet> createState() => _NSSState();
}

class _NSSState extends State<NotificationsSettingsSheet> {
  bool _get(String k, bool d) => widget.store.getPref(k, d);
  Future<void> _set(String k, bool v) async {
    await widget.store.setPref(k, v);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(T.s16),
        children: [
          const Text('Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: T.s16),
          ListTile(
            title: const Text('Enable Web Push (PWA)'),
            subtitle: const Text('Receive notifications when the app is closed'),
            trailing: ElevatedButton(
              onPressed: () async {
                final ok = await WebPushManager.enable();
                if (!context.mounted) return;
                final snack = SnackBar(content: Text(ok ? 'Web Push enabled' : 'Web Push failed'));
                ScaffoldMessenger.of(context).showSnackBar(snack);
                setState((){}); // reflect any UI change you want
              },
              child: const Text('Enable'),
            ),
          ),
          _tile('Show replies', NotifPrefsKeys.includeReply),
          _tile('Show likes', NotifPrefsKeys.includeLike),
          _tile('Show reposts', NotifPrefsKeys.includeRepost),
          _tile('Show zaps', NotifPrefsKeys.includeZap),
          _tile('Show mentions', NotifPrefsKeys.includeMention),
          const Divider(height: T.s24 * 2),
          const Text('Count in badge', style: TextStyle(fontSize: 16)),
          _tile('Replies in badge', NotifPrefsKeys.badgeReply),
          _tile('Likes in badge', NotifPrefsKeys.badgeLike),
          _tile('Reposts in badge', NotifPrefsKeys.badgeRepost),
          _tile('Zaps in badge', NotifPrefsKeys.badgeZap),
          _tile('Mentions in badge', NotifPrefsKeys.badgeMention),
        ],
      ),
    );
  }

  Widget _tile(String label, String key) {
    final v = _get(key, true);
    return SwitchListTile(
      title: Text(label),
      value: v,
      onChanged: (nv) => _set(key, nv),
    );
  }
}
