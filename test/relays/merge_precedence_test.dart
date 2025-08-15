import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/services/nostr/relay_directory.dart';
import 'package:nostr_video/services/settings/settings_service.dart';
import 'package:nostr_video/services/nostr/relay_service.dart';
import 'package:nostr_video/services/keys/key_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakePrefs implements SharedPreferences {
  final Map<String, Object> _store = {};
  @override
  List<String>? getStringList(String key) => _store[key] as List<String>?;
  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _store[key] = value;
    return true;
  }

  @override
  int? getInt(String key) => _store[key] as int?;
  @override
  Future<bool> setInt(String key, int value) async {
    _store[key] = value;
    return true;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

  class _RelayFake implements RelayService {
  final _ctrl = StreamController<Map<String, dynamic>>.broadcast();
  Map<String, dynamic>? published;
  @override
  Stream<Map<String, dynamic>> get events => _ctrl.stream;
  @override
  Future<String> subscribe(List<Map<String, dynamic>> f,
          {String? subId}) async =>
      's';
  @override
  Future<void> close(String subId) async {}
  @override
  Future<void> init(List<String> relays) async {}
  @override
  Stream<List<dynamic>> subscribeFeed(
          {required List<String> authors, String? hashtag}) =>
      const Stream.empty();
    @override
    Future<String> publishEvent(Map<String, dynamic> e) async {
      published = e;
      return 'id';
    }
    @override
    Future<String?> signAndPublish({required int kind, required String content, required List<List<String>> tags}) async {
      return 'id';
    }

  @override
  Future<void> like({required String eventId}) async {}
  @override
  Future<void> reply(
      {required String parentId,
      required String content,
      String? parentPubkey,
      String? rootId,
      String? rootPubkey}) async {}
  @override
  Future<void> repost({required String eventId, String? originalJson}) async {}
  @override
  Future<Map<String, dynamic>> buildZapRequest(
          {required String recipientPubkey,
          required String eventId,
          String content = '',
          List<String>? relays}) async =>
      {};
  @override
  Future<void> resetConnections(List<String> urls) async {}
  @override
  Future<void> zapRequest(
      {required String eventId, required int millisats}) async {}
  void emit(Map<String, dynamic> evt) => _ctrl.add(evt);
}

class _Keys implements KeyService {
  @override
  Future<String?> getPrivkey() async => '11' * 32;
  @override
  Future<String?> getPubkey() async => '02${'a' * 66}';
  @override
  Future<String> generate() async => '';
  @override
  Future<String> importSecret(String s) async => '';
  @override
  Future<String?> exportNsec() async => null;
}

class _SettingsMem extends SettingsService {
  _SettingsMem(super.prefs);
}

void main() {
  test('remote newer replaces local', () async {
    final relay = _RelayFake();
    final s = _SettingsMem(FakePrefs());
    await s.saveRelays(
        [RelayEntry(Uri.parse('wss://old'), read: true, write: true)],
        updatedAt: 1);

    final dir = RelayDirectory(s, relay, _Keys());
    Future.delayed(const Duration(milliseconds: 10), () {
      relay.emit({
        'kind': 10002,
        'pubkey': '02${'a' * 66}',
        'created_at': 999,
        'tags': [
          ['r', 'wss://new', 'read'],
        ],
      });
    });
    await dir.init();
    expect(
        dir
            .current()
            .any((e) => e.uri.toString() == 'wss://new' && e.read && !e.write),
        true);
  });
}
