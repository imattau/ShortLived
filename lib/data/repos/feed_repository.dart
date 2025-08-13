import '../models/post.dart';
import '../models/author.dart';

abstract class FeedRepository {
  Stream<List<Post>> watchFeed();
  Future<List<Post>> fetchInitial();
}

/// Mock implementation for development and tests
class MockFeedRepository implements FeedRepository {
  final int count;
  MockFeedRepository({this.count = 10});

  @override
  Future<List<Post>> fetchInitial() async {
    return List.generate(
        count,
        (i) => Post(
              id: 'evt_\$i',
              author: const Author(
                  pubkey: 'pk',
                  name: 'Creator',
                  avatarUrl: 'https://picsum.photos/64'),
              caption: 'Sample video #\$i',
              tags: const ['demo'],
              url:
                  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
              thumb: 'https://picsum.photos/seed/\$i/300/533',
              mime: 'video/mp4',
              width: 1080,
              height: 1920,
              duration: 10 + i.toDouble(),
              createdAt: DateTime.now().subtract(Duration(minutes: i)),
            ));
  }

  @override
  Stream<List<Post>> watchFeed() async* {
    yield await fetchInitial();
  }
}
