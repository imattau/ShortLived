import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/data/repos/feed_repository.dart';
import 'package:nostr_video/data/models/post.dart';

void main() {
  test('parses NIP-94 tags into Post', () {
    final evt = {
      'id': 'abc',
      'kind': 1,
      'pubkey': 'pk123456789',
      'created_at': 1700000000,
      'content': 'Hello',
      'tags': [
        ['t', 'video/mp4'],
        ['url', 'https://cdn/x.mp4'],
        ['thumb', 'https://cdn/x.jpg'],
        ['dim', '1080x1920'],
        ['dur', '21.4'],
      ],
    };
    final p = RealFeedRepository.postFromEvent(evt);
    expect(p, isA<Post>());
    expect(p!.mime, 'video/mp4');
    expect(p.url, 'https://cdn/x.mp4');
    expect(p.width, 1080);
    expect(p.height, 1920);
    expect(p.duration, 21.4);
  });

  test('returns null when url or mime missing', () {
    final evt = {'kind': 1, 'tags': [
      ['url', 'u']
    ]};
    expect(RealFeedRepository.postFromEvent(evt), isNull);
  });
}
