import 'dart:async';
import '../models/notification.dart';
import '../../core/di/locator.dart'; // ignore: unused_import
import '../../services/nostr/relay_service.dart';
import '../../services/keys/signer.dart';
import '../../services/nostr/metadata_service.dart';
import '../../core/testing/test_switches.dart';

class NotificationsRepository {
  NotificationsRepository(this._relay, this._signer, this._meta);
  final RelayService _relay;
  final Signer _signer;
  final MetadataService _meta;

  StreamSubscription<Map<String, dynamic>>? _sub;
  final _byId = <String, NotificationItem>{};
  final _ctrl = StreamController<List<NotificationItem>>.broadcast();

  Stream<List<NotificationItem>> stream() => _ctrl.stream;

  Future<void> start() async {
    if (TestSwitches.disableRelays) return;
    final me = await _signer.getPubkey();
    if (me == null || me.isEmpty) return;

    // Subscribe to mentions/acts to me
    await _relay.subscribe([
      { "kinds": [1,6,7,9735], "#p": [me], "limit": 200 }
    ], subId: 'notif_\$me');

    _sub = _relay.events.listen((evt) {
      final kind = (evt['kind'] ?? -1) as int;
      if (kind != 1 && kind != 6 && kind != 7 && kind != 9735) return;

      final id = (evt['id'] ?? '') as String; if (id.isEmpty) return;
      if (_byId.containsKey(id)) return;

      final pk = (evt['pubkey'] ?? '') as String;
      final m = _meta.get(pk);
      final name = m?.name ?? (pk.isNotEmpty ? pk.substring(0,8) : 'unknown');
      final avatar = m?.picture ?? '';
      final created = (evt['created_at'] ?? 0) as int;

      // find related event id (first 'e' tag)
      String related = '';
      final tags = (evt['tags'] as List?)?.whereType<List>().toList() ?? const [];
      for (final t in tags) {
        if (t.isNotEmpty && t[0] == 'e' && t.length >= 2) { related = t[1] as String; break; }
      }

      NotificationType? t;
      String content = '';
      int? sats;

      if (kind == 1) { // reply/mention
        t = NotificationType.reply;
        content = (evt['content'] ?? '') as String;
      } else if (kind == 6) {
        t = NotificationType.repost;
        content = 'reposted your post';
      } else if (kind == 7) {
        t = NotificationType.like;
        content = 'liked your post';
      } else if (kind == 9735) {
        t = NotificationType.zap;
        // msats in tag or 'amount' field (varies by relays)
        final amtTag = tags.firstWhere(
          (x) => x.isNotEmpty && x[0] == 'amount',
          orElse: () => const [],
        );
        int msats = 0;
        if (amtTag.isNotEmpty && amtTag.length >= 2) {
          msats = int.tryParse(amtTag[1].toString()) ?? 0;
        } else {
          msats = int.tryParse((evt['amount'] ?? '0').toString()) ?? 0;
        }
        sats = (msats / 1000).round();
        content = sats > 0 ? 'zapped \$sats sats' : 'zapped you';
      }

      if (t == null) return;

      final item = NotificationItem(
        type: t,
        id: id,
        fromPubkey: pk,
        fromName: name,
        fromAvatar: avatar,
        relatedEventId: related,
        content: content,
        createdAt: created,
        sats: sats,
      );
      _byId[id] = item;

      final list = _byId.values.toList()
        ..sort((a,b) => b.createdAt.compareTo(a.createdAt));
      _ctrl.add(list);
    });
  }

  Future<void> stop() async { await _sub?.cancel(); _sub = null; }
  Future<void> dispose() async { await stop(); await _ctrl.close(); }
}
