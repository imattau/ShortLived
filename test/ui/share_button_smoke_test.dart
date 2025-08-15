import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nostr_video/ui/pages/event_view_page.dart';
import 'package:nostr_video/state/feed_controller.dart';
import 'package:nostr_video/data/repos/feed_repository.dart';
import 'package:nostr_video/core/di/locator.dart';

void main() {
  testWidgets('event page renders share icon', (tester) async {
    final fc = FeedController(MockFeedRepository(count: 1));
    Locator.I.put<FeedController>(fc);
    await fc.connect();
    await tester.pumpWidget(const MaterialApp(home: EventViewPage(encoded: 'evt_0')));
    expect(find.byIcon(Icons.share), findsOneWidget);
  });
}
