import 'notifications_store.dart';
import 'notifications_prefs.dart';
import 'notification_models.dart';
import 'notifications_service.dart';

/// Coordinates fetching, persistence and filtering of notifications.
class NotificationsController {
  NotificationsController(this.service, this.store);

  final NotificationsService service;
  final NotificationsStore store;

  int _unread = 0;
  List<AppNotification> _items = const [];

  int get unread => _unread;
  List<AppNotification> get items => _items;

  bool _f(String key, bool d) => store.getPref(key, d);

  /// Initializes the controller, loading any persisted notifications and
  /// subscribing to live updates from [service].
  Future<void> attach() async {
    await store.init();
    // Load persisted first
    _applyAndCount(store.all());
    // Live updates
    service.start();
    service.stream.listen((list) async {
      for (final n in list) {
        await store.upsert(n);
      }
      _applyAndCount(store.all());
    });
  }

  void _applyAndCount(List<AppNotification> src) {
    // Filter visibility
    final keep = src.where((n) {
      return switch (n.type) {
        NotificationType.reply => _f(NotifPrefsKeys.includeReply, true),
        NotificationType.like => _f(NotifPrefsKeys.includeLike, true),
        NotificationType.repost => _f(NotifPrefsKeys.includeRepost, true),
        NotificationType.zap => _f(NotifPrefsKeys.includeZap, true),
        NotificationType.mention => _f(NotifPrefsKeys.includeMention, true),
      };
    }).toList();

    // Count badge types and unread
    final countable = keep.where((n) {
      return !n.read && switch (n.type) {
        NotificationType.reply => _f(NotifPrefsKeys.badgeReply, true),
        NotificationType.like => _f(NotifPrefsKeys.badgeLike, true),
        NotificationType.repost => _f(NotifPrefsKeys.badgeRepost, true),
        NotificationType.zap => _f(NotifPrefsKeys.badgeZap, true),
        NotificationType.mention => _f(NotifPrefsKeys.badgeMention, true),
      };
    });

    _items = keep;
    _unread = countable.length;
  }

  Future<void> markAllRead() async {
    await store.markAllRead();
    _applyAndCount(store.all());
  }
}
