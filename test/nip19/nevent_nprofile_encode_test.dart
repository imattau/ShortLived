import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/crypto/nip19.dart';

void main() {
  test('nevent/nprofile encode basic', () {
    final ne = neventEncode(
        eventIdHex: List.filled(32, 'a1').join(),
        authorPubkeyHex: List.filled(32, 'b2').join(),
        relays: ['wss://r']);
    final np = nprofileEncode(
        pubkeyHex: List.filled(32, 'b2').join(), relays: ['wss://r']);
    expect(ne.startsWith('nevent1'), true);
    expect(np.startsWith('nprofile1'), true);
  });
}
