import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/nostr/mapper.dart';
import 'package:nostr_video/nostr/nostr_repo.dart';

void main() {
  test('mapEventToFeedItem returns null when no video url found', () {
    final e = NostrEvent(
      id: 'x',
      pubkey: 'abc123',
      createdAt: 0,
      kind: 1,
      content: 'hello world',
      tags: const [],
    );
    expect(mapEventToFeedItem(e), isNull);
  });

  test('mapEventToFeedItem prefers video tag', () {
    final e = NostrEvent(
      id: 'y',
      pubkey: 'abc123',
      createdAt: 0,
      kind: 1,
      content: 'check this out https://example.com/clip.mp4',
      tags: const [
        ['video', 'https://cdn.example.com/a.mp4']
      ],
    );
    final item = mapEventToFeedItem(e)!;
    expect(item.url, 'https://cdn.example.com/a.mp4');
  });
}
