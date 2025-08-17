import 'dart:async';
import 'demo_feed.dart';
import '../nostr/nostr_repo.dart';
import '../nostr/nostr_repo_ws.dart';
import '../nostr/mapper.dart';
import '../config/app_config.dart';

abstract class FeedDataSource {
  Stream<List<FeedItem>> streamInitial();
  Future<void> dispose();
}

class DemoFeedDataSource implements FeedDataSource {
  @override
  Stream<List<FeedItem>> streamInitial() async* {
    yield demoFeed;
  }

  @override
  Future<void> dispose() async {}
}

class NostrFeedDataSource implements FeedDataSource {
  final NostrRepo _repo;
  NostrFeedDataSource({List<String>? relays})
    : _repo = NostrRepoWebSocket(
        relays: relays ?? kDefaultRelays,
        limit: kNostrInitialLimit,
      );

  @override
  Stream<List<FeedItem>> streamInitial() {
    final items = <FeedItem>[];
    final controller = StreamController<List<FeedItem>>();

    final sub = _repo
        .streamRecent(limit: kNostrInitialLimit)
        .listen(
          (e) {
            final m = mapEventToFeedItem(
              e,
              preferredExts: const ['mp4', 'webm', 'm3u8'],
            );
            if (m != null) {
              items.add(m);
              if (items.length == 1) {
                controller.add(
                  List<FeedItem>.from(items),
                ); // show first quickly
              }
              if (items.length % 5 == 0) {
                controller.add(List<FeedItem>.from(items));
              }
            }
          },
          onDone: () {
            controller.add(items);
            controller.close();
          },
          onError: (_) {
            controller.add(items);
            controller.close();
          },
        );

    controller.onCancel = sub.cancel;

    // Time out to ensure we emit something even if relays quiet
    Future.delayed(kNostrLoadTimeout, () {
      if (!controller.isClosed) controller.add(items);
    });

    return controller.stream;
  }

  @override
  Future<void> dispose() => _repo.dispose();
}
