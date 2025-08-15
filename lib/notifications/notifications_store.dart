import 'package:hive/hive.dart';

import 'notification_models.dart';

/// Persistence layer for notifications and their preferences.
class NotificationsStore {
  static const _boxNotifs = 'notifs';
  static const _boxPrefs = 'notif_prefs';

  late Box<Map> _bNotifs;
  late Box _bPrefs;

  /// Opens the underlying Hive boxes.
  Future<void> init() async {
    _bNotifs = await Hive.openBox<Map>(_boxNotifs);
    _bPrefs = await Hive.openBox(_boxPrefs);
  }

  /// Inserts or updates a notification.
  Future<void> upsert(AppNotification n) async {
    await _bNotifs.put(n.id, {
      'id': n.id,
      'type': n.type.name,
      'fromPubkey': n.fromPubkey,
      'fromName': n.fromName,
      'noteId': n.noteId,
      'content': n.content,
      'createdAt': n.createdAt.millisecondsSinceEpoch,
      'read': n.read,
    });
  }

  /// Returns all notifications sorted by newest first.
  List<AppNotification> all() {
    return _bNotifs.values.map((m) {
      return AppNotification(
        id: m['id'] as String,
        type: NotificationType.values.firstWhere((t) => t.name == m['type']),
        fromPubkey: m['fromPubkey'] as String,
        fromName: m['fromName'] as String?,
        noteId: m['noteId'] as String?,
        content: m['content'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch(m['createdAt'] as int),
        read: m['read'] as bool? ?? false,
      );
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Marks every stored notification as read.
  Future<void> markAllRead() async {
    for (final k in _bNotifs.keys) {
      final m = Map<String, dynamic>.from(_bNotifs.get(k) as Map);
      m['read'] = true;
      await _bNotifs.put(k, m);
    }
  }

  // Prefs
  bool getPref(String key, bool def) => (_bPrefs.get(key) as bool?) ?? def;
  Future<void> setPref(String key, bool v) => _bPrefs.put(key, v);
}
