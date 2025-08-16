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
            relays: relays ?? kDefaultRelays, limit: kNostrInitialLimit);

  @override
  Stream<List<FeedItem>> streamInitial() {
    final items = <FeedItem>[];
    final controller = StreamController<List<FeedItem>>();
    _repo.streamRecent(limit: kNostrInitialLimit).listen((e) {
      final m = mapEventToFeedItem(e);
      if (m != null) {
        items.add(m);
        if (items.length >= 10) {
          controller.add(List<FeedItem>.from(items));
        }
      }
    }, onError: (_) {
      controller.add(items);
    }, onDone: () {
      controller.add(items);
      controller.close();
    });
    return controller.stream;
  }

  @override
  Future<void> dispose() => _repo.dispose();
}
