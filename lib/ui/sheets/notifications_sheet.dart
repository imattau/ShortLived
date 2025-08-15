import 'package:flutter/material.dart';
import '../../core/di/locator.dart';
import '../../data/repos/notifications_repository.dart';
import '../../data/models/notification.dart';
import '../../services/settings/settings_service.dart';

class NotificationsSheet extends StatefulWidget {
  const NotificationsSheet({super.key});
  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  List<NotificationItem> _items = const [];
  @override
  void initState() {
    super.initState();
    final repo = Locator.I.tryGet<NotificationsRepository>();
    repo?.stream().listen((list) {
      if (mounted) setState(() => _items = list);
    });
    // Mark read on open
    final nowSecs = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    Locator.I.tryGet<SettingsService>()?.setNotifLastSeen(nowSecs);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 36,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text('Notifications',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (_, i) {
                  final n = _items[i];
                  final lead = CircleAvatar(
                    backgroundImage: n.fromAvatar.isNotEmpty
                        ? NetworkImage(n.fromAvatar)
                        : null,
                    child: n.fromAvatar.isEmpty
                        ? Text(n.fromName.substring(0, 1))
                        : null,
                  );
                  final title = switch (n.type) {
                    NotificationType.reply => '${n.fromName} replied',
                    NotificationType.like => '${n.fromName} liked',
                    NotificationType.repost => '${n.fromName} reposted',
                    NotificationType.zap => '${n.fromName} ${n.content}',
                  };
                  final sub =
                      n.type == NotificationType.reply ? n.content : '';
                  return ListTile(
                    dense: true,
                    leading: lead,
                    title: Text(title),
                    subtitle: sub.isEmpty
                        ? null
                        : Text(
                            sub,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                    onTap: () {
                      // Future: deep link into the post using relatedEventId.
                      Navigator.of(context).maybePop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
