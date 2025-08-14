import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/crypto/nostr_event.dart';

void main() {
  test('kind 6 repost event canonical id is deterministic', () {
    const pub = '02' 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
    const priv = '11' '11' '11' '11' '11' '11' '11' '11' '11' '11' '11' '11' '11' '11' '11' '11'
        '11' '11' '11' '11' '11' '11' '11' '11' '11' '11' '11' '11' '11' '11' '11' '11';
    final e = NostrEvent(kind: 6, createdAt: 1700000000, content: '', tags: const [["e","evt1"]]);
    final idA = NostrEvent.idFor(pub, e);
    final idB = NostrEvent.idFor(pub, e);
    expect(idA, idB);
  });
}
