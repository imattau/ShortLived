import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nostr_video/ui/sheets/relays_sheet.dart';
import 'package:nostr_video/services/settings/settings_service.dart';
import 'package:nostr_video/services/nostr/relay_directory.dart';
import 'package:nostr_video/services/nostr/relay_service.dart';
import 'package:nostr_video/services/keys/key_service.dart';
import 'package:nostr_video/core/di/locator.dart';

class _RelayStub implements RelayService {
  @override
  Future<void> init(List<String> relays) async {}
  @override
  Future<String> subscribe(List<Map<String, dynamic>> filters,
          {String? subId}) async =>
      's';
  @override
  Future<void> close(String subId) async {}
  @override
  Stream<List<dynamic>> subscribeFeed(
          {required List<String> authors, String? hashtag}) =>
      const Stream.empty();
    @override
    Future<String> publishEvent(Map<String, dynamic> signedEventJson) async =>
        'id';
    @override
    Future<String?> signAndPublish({required int kind, required String content, required List<List<String>> tags}) async => 'id';
  @override
  Future<void> like({required String eventId, required String authorPubkey}) async {}
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
  Future<void> zapRequest(
      {required String eventId, required int millisats}) async {}
  @override
  Stream<Map<String, dynamic>> get events => const Stream.empty();
  @override
  Future<Map<String, dynamic>> buildZapRequest(
          {required String recipientPubkey,
          required String eventId,
          String content = '',
          List<String>? relays}) async =>
      {};
  @override
  Future<void> resetConnections(List<String> urls) async {}
}

class _KeyDummy implements KeyService {
  @override
  Future<String?> getPrivkey() async => null;
  @override
  Future<String?> getPubkey() async => null;
  @override
  Future<String> generate() async => '';
  @override
  Future<String> importSecret(String nsecOrHex) async => '';
  @override
  Future<String?> exportNsec() async => null;
}

void main() {
  testWidgets('add relay and toggle flags', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    final settings = SettingsService(sp);
    final dir = RelayDirectory(settings, _RelayStub(), _KeyDummy());
    Locator.I.put<RelayDirectory>(dir);

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            builder: (_) => const RelaysSheet(),
          ),
          child: const Text('Open'),
        ),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'wss://example.com');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(dir.current().any((e) => e.uri.toString() == 'wss://example.com'),
        true);

    await tester.tap(find.widgetWithText(FilterChip, 'Read'));
    await tester.pumpAndSettle();

    final entry = dir
        .current()
        .firstWhere((e) => e.uri.toString() == 'wss://example.com');
    expect(entry.read, false);
  });
}
