import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nostr_video/ui/sheets/comments_sheet.dart';
import 'package:nostr_video/services/nostr/relay_service.dart';

class _RelaySpy implements RelayService {
  String? lastParentId;
  String? lastContent;
  String? lastP;
  @override
  Future<void> reply(
      {required String parentId,
      required String content,
      String? parentPubkey}) async {
    lastParentId = parentId;
    lastContent = content;
    lastP = parentPubkey;
  }

  // Unused in this test:
  @override
  Future<void> init(List<String> relays) async {}
  @override
  Future<void> like({required String eventId}) async {}
  @override
  Future<String> publishEvent(Map<String, dynamic> e) async => 'id';
  @override
  Stream<List<dynamic>> subscribeFeed(
      {required List<String> authors, String? hashtag}) async* {}
  @override
  Stream<Map<String, dynamic>> get events async* {}
  @override
  Future<void> zapRequest(
      {required String eventId, required int millisats}) async {}

  @override
  Future<String> subscribe(List<Map<String, dynamic>> filters, {String? subId}) async => 'sub';

  @override
  Future<void> close(String subId) async {}

  @override
  Future<void> repost({required String eventId, String? originalJson}) async {}
}

void main() {
  testWidgets('sends reply with e and p tags', (tester) async {
    final spy = _RelaySpy();
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Builder(builder: (context) {
      return ElevatedButton(
        onPressed: () => showModalBottomSheet(
            context: context,
            builder: (_) => CommentsSheet(
                parentEventId: 'evt', parentPubkey: 'pk', relay: spy)),
        child: const Text('Open'),
      );
    }))));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    expect(spy.lastParentId, 'evt');
    expect(spy.lastContent, 'Hello');
    expect(spy.lastP, 'pk');
  });
}
