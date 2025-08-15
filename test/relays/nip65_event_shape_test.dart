import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/services/nostr/relay_directory.dart';
import 'package:nostr_video/services/nostr/relay_service.dart';
import 'package:nostr_video/services/settings/settings_service.dart';
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

class _RelaySpy implements RelayService {
  Map<String, dynamic>? lastPublished;
  @override
  Future<String> publishEvent(Map<String, dynamic> e) async {
    lastPublished = e;
    return e['id'] as String? ?? 'id';
  }

  @override
  Future<void> init(List<String> relays) async {}
  @override
  Future<String> subscribe(List<Map<String, dynamic>> f,
          {String? subId}) async =>
      's';
  @override
  Future<void> close(String subId) async {}
  @override
  Stream<List<dynamic>> subscribeFeed(
          {required List<String> authors, String? hashtag}) =>
      const Stream.empty();
  @override
  Stream<Map<String, dynamic>> get events => const Stream.empty();
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
}

class _KeysFake implements KeyService {
  @override
  Future<String?> getPrivkey() async => '11' * 32;
  @override
  Future<String?> getPubkey() async => '02' + 'a' * 66;
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
  test('publishes kind:10002 with r tags and markers', () async {
    final relay = _RelaySpy();
    final dir = RelayDirectory(_SettingsMem(FakePrefs()), relay, _KeysFake());
    await dir.add('wss://a', read: true, write: false);
    await dir.add('wss://b', read: false, write: true);
    final e = relay.lastPublished!;
    expect(e['kind'], 10002);
    final tags = (e['tags'] as List).where((t) => t[0] == 'r').toList();
    expect(
        tags.any((t) => t[1] == 'wss://a' && t.length >= 3 && t[2] == 'read'),
        true);
    expect(
        tags.any((t) => t[1] == 'wss://b' && t.length >= 3 && t[2] == 'write'),
        true);
  });
}
