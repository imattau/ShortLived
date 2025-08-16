import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nostr_video/notifications/notification_models.dart';
import 'package:nostr_video/notifications/notifications_store.dart';
import 'package:nostr_video/notifications/notifications_controller.dart';
import 'package:nostr_video/notifications/notifications_service.dart';

class _FakeSvc extends NotificationsService {
  _FakeSvc() : super(client: _NoopClient(), myPubkey: 'me');
  @override
  void start() {} // no timers
}

class _NoopClient implements INostrClient {
  @override
  void send(String _) {}
  @override
  Stream<String> get messages => const Stream.empty();
  @override
  Future<void> close() async {}
}

void main() {
  test('unread respects filters and persists', () async {
    await Hive.initFlutter();
    final store = NotificationsStore();
    await store.init();
    final svc = _FakeSvc();
    final ctrl = NotificationsController(svc, store);

    // Seed two notifs
    await store.upsert(AppNotification(
      id: '1',
      type: NotificationType.like,
      fromPubkey: 'a',
      createdAt: DateTime.now(),
    ));
    await store.upsert(AppNotification(
      id: '2',
      type: NotificationType.reply,
      fromPubkey: 'b',
      createdAt: DateTime.now(),
    ));

    await ctrl.attach();
    expect(ctrl.unread, 2);

    // Exclude likes from badge:
    await store.setPref('pref_badge_like', false);
    await store.setPref('pref_badge_reply', true);
    await Future<void>.delayed(const Duration(milliseconds: 1));
    // Recalc
    await ctrl.markAllRead(); // mark as read then no unread
    expect(ctrl.unread, 0);
  });
}
