import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/core/di/locator.dart';
import 'package:nostr_video/data/models/author.dart';
import 'package:nostr_video/data/models/post.dart';
import 'package:nostr_video/data/repos/feed_repository.dart';
import 'package:nostr_video/services/nostr/metadata_service.dart';
import 'package:nostr_video/services/nostr/relay_service.dart';
import 'package:nostr_video/services/queue/action_queue.dart';
import 'package:nostr_video/services/queue/action_queue_memory.dart';
import 'package:nostr_video/state/feed_controller.dart';
import 'package:nostr_video/ui/sheets/comments_sheet.dart';

import '../test_utils/test_services.dart';

class _ReplyFailureRelay extends RelayServiceFake {
  @override
  Future<void> reply({
    required String parentId,
    required String content,
    String? parentPubkey,
    String? rootId,
    String? rootPubkey,
  }) async {
    throw Exception('network unavailable');
  }
}

void main() {
  setUp(() {
    Locator.I.remove<FeedController>();
    Locator.I.remove<RelayService>();
    Locator.I.remove<MetadataService>();
  });

  testWidgets('queues reply on failure and increments comment count', (tester) async {
    final controller = FeedController(MockFeedRepository(count: 0));
    final post = Post(
      id: 'root',
      author: const Author(pubkey: 'pk', name: 'Author', avatarUrl: ''),
      caption: 'caption',
      tags: const [],
      url: 'https://example.com/video.mp4',
      thumb: '',
      mime: 'video/mp4',
      width: 1,
      height: 1,
      duration: 1,
      createdAt: DateTime.now(),
    );
    controller.setPosts([post]);
    final queue = ActionQueueMemory();
    await queue.init();
    controller.bindQueue(queue);

    Locator.I.put<FeedController>(controller);
    Locator.I.put<RelayService>(_ReplyFailureRelay());
    Locator.I.put<MetadataService>(MetadataService());

    addTearDown(() {
      Locator.I.remove<FeedController>();
      Locator.I.remove<RelayService>();
      Locator.I.remove<MetadataService>();
      controller.dispose();
    });

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: CommentsSheet(post: post))));

    await tester.enterText(find.byType(TextField).first, 'hello world');
    await tester.tap(find.text('Send'));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();

    final actions = await queue.all();
    expect(actions.length, 1);
    expect(actions.first.type, ActionType.reply);
    expect(actions.first.payload['content'], 'hello world');
    expect(controller.posts.first.commentCount, 1);
    expect(find.text('Reply queued for retry'), findsOneWidget);
  });
}
