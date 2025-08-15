import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/crypto/nip19.dart';

void main() {
  test('npub/nsec encode/decode roundtrip', () {
    final priv = List.filled(32, '11').join();
    final pub = List.filled(32, '22').join();
    final nsec = nsecEncode(priv);
    final npub = npubEncode(pub);
    expect(nip19Decode(nsec), priv);
    expect(nip19Decode(npub), pub);
    expect(isNsec(nsec), true);
    expect(isNpub(npub), true);
  });
}

