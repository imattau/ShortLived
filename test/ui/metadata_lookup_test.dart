import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/core/di/locator.dart';
import 'package:nostr_video/data/models/author.dart';
import 'package:nostr_video/data/models/post.dart';
import 'package:nostr_video/data/repos/feed_repository.dart';
import 'package:nostr_video/services/nostr/metadata_service.dart';
import 'package:nostr_video/state/feed_controller.dart';
import 'package:nostr_video/ui/sheets/comments_sheet.dart';
import 'package:nostr_video/ui/sheets/zap_sheet.dart';

import '../test_utils/test_services.dart';

void main() {

  testWidgets('CommentsSheet uses MetadataService values when registered', (tester) async {
    await setupTestLocator();
    final meta = Locator.I.get<MetadataService>();
    meta.handleEvent({
      'kind': 0,
      'pubkey': 'pk',
      'content': jsonEncode({'name': 'Alice', 'picture': 'https://img'}),
    });

    final post = Post(
      id: 'evt',
      author: const Author(pubkey: 'pk', name: 'pk', avatarUrl: ''),
      caption: '',
      tags: const [],
      url: 'u',
      thumb: 't',
      mime: 'video/mp4',
      width: 1,
      height: 1,
      duration: 1,
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CommentsSheet(post: post),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Comments • Alice'), findsOneWidget);
  });

  testWidgets('ZapSheet shows metadata name for current post', (tester) async {
    await setupTestLocator();
    final meta = Locator.I.get<MetadataService>();
    meta.handleEvent({
      'kind': 0,
      'pubkey': 'pk',
      'content': jsonEncode({'name': 'Alice'}),
    });

    final post = Post(
      id: 'evt',
      author: const Author(pubkey: 'pk', name: 'pk', avatarUrl: ''),
      caption: '',
      tags: const [],
      url: 'u',
      thumb: 't',
      mime: 'video/mp4',
      width: 1,
      height: 1,
      duration: 1,
      createdAt: DateTime.now(),
    );

    final previous = Locator.I.tryGet<FeedController>();
    final controller = FeedController(MockFeedRepository(count: 0));
    controller.setPosts([post]);
    Locator.I.put<FeedController>(controller);
    addTearDown(() {
      if (previous != null) {
        Locator.I.put<FeedController>(previous);
      } else {
        Locator.I.remove<FeedController>();
      }
      controller.dispose();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => const ZapSheet(),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Zap Alice'), findsOneWidget);
  });
}
