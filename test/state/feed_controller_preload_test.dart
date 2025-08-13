import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/state/feed_controller.dart';
import 'package:nostr_video/data/repos/feed_repository.dart';

void main() {
  test('preloadCandidates returns ±1 within bounds', () async {
    final c = FeedController(MockFeedRepository(count: 5));
    await c.loadInitial();
    // index 0 -> {1}
    expect(c.index, 0);
    expect(c.preloadCandidates, {1});
    // move to 2 -> {1,3}
    c.onPageChanged(2);
    expect(c.preloadCandidates, {1, 3});
    // last index -> {3}
    c.onPageChanged(4);
    expect(c.preloadCandidates, {3});
  });
}
