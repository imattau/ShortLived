import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/crypto/nostr_event.dart';

void main() {
  test('id is deterministic & signature present', () {
    // Not a real key; just validates shape.
    const priv = '8f' '8f' '8f' '8f' '8f' '8f' '8f' '8f' '8f' '8f' '8f' '8f' '8f' '8f' '8f' '8f'
                 '8f' '8f' '8f' '8f' '8f' '8f' '8f' '8f' '8f' '8f' '8f' '8f' '8f' '8f' '8f' '8f';
    // Derive pub from priv via elliptic (quick check done in service tests ideally)
    // For unit simplicity, assume a fixed pub (same pair each run).
    const pub = '02' 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'; // placeholder length ok in test
    final e = NostrEvent(kind: 1, createdAt: 1700000000, content: 'hi', tags: const []);
    final a = NostrEvent.sign(priv, pub, e);
    final b = NostrEvent.sign(priv, pub, e);
    expect(a['id'], b['id']);
    expect((a['sig'] as String).length >= 128, true); // 64-byte hex
  });
}
