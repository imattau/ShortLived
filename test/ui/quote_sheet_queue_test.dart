import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/core/di/locator.dart';
import 'package:nostr_video/data/repos/feed_repository.dart';
import 'package:nostr_video/services/nostr/relay_service.dart';
import 'package:nostr_video/services/queue/action_queue.dart';
import 'package:nostr_video/services/queue/action_queue_memory.dart';
import 'package:nostr_video/state/feed_controller.dart';
import 'package:nostr_video/ui/sheets/quote_sheet.dart';

import '../test_utils/test_services.dart';

class _FailingQuoteRelay extends RelayServiceFake {
  @override
  Future<void> quote({required String eventId, required String content}) async {
    throw Exception('offline');
  }
}

class _RecordingQuoteRelay extends RelayServiceFake {
  String? lastEventId;
  String? lastContent;

  @override
  Future<void> quote({required String eventId, required String content}) async {
    lastEventId = eventId;
    lastContent = content;
  }
}

void main() {
  setUp(() {
    Locator.I.remove<FeedController>();
  });

  testWidgets('queues quote when relay call fails', (tester) async {
    final controller = FeedController(MockFeedRepository(count: 0));
    final queue = ActionQueueMemory();
    await queue.init();
    controller.bindQueue(queue);
    Locator.I.put<FeedController>(controller);

    addTearDown(() {
      controller.dispose();
      Locator.I.remove<FeedController>();
    });

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: QuoteSheet(eventId: 'evt-1', relay: _FailingQuoteRelay()),
      ),
    ));

    await tester.enterText(find.byType(TextField), 'hello offline');
    await tester.tap(find.text('Post quote'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    final actions = await queue.all();
    expect(actions, hasLength(1));
    expect(actions.first.type, ActionType.quote);
    expect(actions.first.payload['eventId'], 'evt-1');
    expect(actions.first.payload['content'], 'hello offline');
    expect(find.text('Quote queued for retry'), findsOneWidget);
  });

  testWidgets('invokes relay quote directly when successful', (tester) async {
    final relay = _RecordingQuoteRelay();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: QuoteSheet(eventId: 'evt-2', relay: relay),
      ),
    ));

    await tester.enterText(find.byType(TextField), 'gm');
    await tester.tap(find.text('Post quote'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(relay.lastEventId, 'evt-2');
    expect(relay.lastContent, 'gm');
    expect(find.byType(SnackBar), findsNothing);
  });
}
