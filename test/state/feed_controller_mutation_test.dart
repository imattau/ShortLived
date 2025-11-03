import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/state/feed_controller.dart';
import 'package:nostr_video/data/models/post.dart';
import 'package:nostr_video/data/models/author.dart';
import 'package:nostr_video/data/repos/feed_repository.dart';

void main() {
  group('FeedController safe helpers', () {
    test('applyOptimisticPost prepends the post and resets index', () {
      final controller = FeedController(MockFeedRepository(count: 0));
      final original = Post(
        id: 'a',
        author: const Author(pubkey: 'pub-a', name: 'Author A', avatarUrl: ''),
        caption: 'first',
        tags: const [],
        url: 'https://example.com/a.mp4',
        thumb: '',
        mime: 'video/mp4',
        width: 1,
        height: 1,
        duration: 1,
        createdAt: DateTime.now(),
      );
      controller.setPosts([original]);

      final optimistic = Post(
        id: 'b',
        author: const Author(pubkey: 'pub-b', name: 'Author B', avatarUrl: ''),
        caption: 'second',
        tags: const [],
        url: 'https://example.com/b.mp4',
        thumb: '',
        mime: 'video/mp4',
        width: 1,
        height: 1,
        duration: 1,
        createdAt: DateTime.now(),
      );
      controller.applyOptimisticPost(optimistic);

      expect(controller.index, 0);
      expect(controller.posts.first.id, 'b');
      controller.dispose();
    });

    test('increment/decrement comment count adjust safely', () {
      final controller = FeedController(MockFeedRepository(count: 0));
      final post = Post(
        id: 'root',
        author: const Author(pubkey: 'pub', name: 'Author', avatarUrl: ''),
        caption: 'caption',
        tags: const [],
        url: 'https://example.com/root.mp4',
        thumb: '',
        mime: 'video/mp4',
        width: 1,
        height: 1,
        duration: 1,
        createdAt: DateTime.now(),
      );
      controller.setPosts([post]);

      expect(controller.incrementCommentCount('root'), isTrue);
      expect(controller.posts.first.commentCount, 1);

      expect(controller.decrementCommentCount('root'), isTrue);
      expect(controller.posts.first.commentCount, 0);

      expect(controller.decrementCommentCount('missing'), isFalse);
      controller.dispose();
    });
  });
}
