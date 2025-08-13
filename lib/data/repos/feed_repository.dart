import '../models/post.dart';
import '../models/author.dart';

abstract class FeedRepository {
  Stream<List<Post>> watchFeed();
  Future<List<Post>> fetchInitial();
}

class MockFeedRepository implements FeedRepository {
  @override
  Stream<List<Post>> watchFeed() async* {
    yield _posts;
  }

  @override
  Future<List<Post>> fetchInitial() async {
    return _posts;
  }

  static final _author = Author(
    pubkey: 'pub',
    name: 'Alice',
    avatarUrl: 'https://placekitten.com/200/200',
  );

  static final _posts = List.generate(
    10,
    (i) => Post(
      id: '$i',
      author: _author,
      caption: 'Caption $i',
      tags: const [],
      url: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
      thumb: 'https://placekitten.com/200/300',
      mime: 'video/mp4',
      width: 720,
      height: 1280,
      duration: 10.0,
      createdAt: DateTime.now(),
    ),
  );
}
