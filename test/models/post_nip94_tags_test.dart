import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/data/models/author.dart';
import 'package:nostr_video/data/models/post.dart';

void main() {
  test('Post.toNip94Tags emits correct tags', () {
    final post = Post(
      id: 'evt1',
      author: const Author(pubkey: 'pk', name: 'Alice', avatarUrl: 'https://x/y.jpg'),
      caption: 'hello',
      tags: const ['fun'],
      url: 'https://cdn.example/v.mp4',
      thumb: 'https://cdn.example/v.jpg',
      mime: 'video/mp4',
      width: 1080,
      height: 1920,
      duration: 21.4,
      createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    );

    final tags = post.toNip94Tags();
    expect(tags, containsAllInOrder([
      ['t', 'video/mp4'],
      ['url', 'https://cdn.example/v.mp4'],
      ['dim', '1080x1920'],
      ['dur', '21.4'],
      ['thumb', 'https://cdn.example/v.jpg'],
    ]));
  });
}
