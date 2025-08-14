import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/state/feed_controller.dart';
import 'package:nostr_video/data/repos/feed_repository.dart';
import 'package:nostr_video/data/models/author.dart';

void main() {
  test('muted authors are filtered from feed', () async {
    final c = FeedController(MockFeedRepository(count: 3));
    await c.connect();
    final pk = c.posts.first.author.pubkey;
    final Author a = c.posts.first.author;
    expect(a.pubkey, pk);
    c.setMuted({pk});
    expect(c.posts.any((p) => p.author.pubkey == pk), false);
  });
}
