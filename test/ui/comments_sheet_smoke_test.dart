import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:nostr_video/ui/sheets/comments_sheet.dart';
import 'package:nostr_video/data/models/post.dart';
import 'package:nostr_video/data/models/author.dart';
import 'package:nostr_video/core/di/locator.dart';
import 'package:nostr_video/services/nostr/metadata_service.dart';
import '../test_utils/test_services.dart';

void main() {
  testWidgets('CommentsSheet renders', (tester) async {
    await setupTestLocator();
    Locator.I.put<MetadataService>(MetadataService());
    final p = Post(
        id: 'root',
        author: const Author(pubkey: 'pk', name: 'Name', avatarUrl: ''),
        caption: '',
        tags: const [],
        url: 'u',
        thumb: 't',
        mime: 'video/mp4',
        width: 1,
        height: 1,
        duration: 1,
        createdAt: DateTime.now());
    await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: CommentsSheet(post: p))));
    expect(find.textContaining('Comments'), findsOneWidget);
  });
}
