import 'package:flutter_test/flutter_test.dart';
import 'package:nostr_video/crypto/nip19.dart';

void main() {
  test('npub/nsec roundtrip', () {
    const hex = '1f' '2e' '3d' '4c' '5b' '6a' '79' '88' '97' 'a6' 'b5' 'c4' 'd3' 'e2' 'f1' '00'
                '11' '22' '33' '44' '55' '66' '77' '88' '99' 'aa' 'bb' 'cc' 'dd' 'ee' 'ff' '00';
    final npub = Nip19.encodeNpub(hex);
    final back = Nip19.decode(npub);
    expect(back, hex);
    final nsec = Nip19.encodeNsec(hex);
    expect(Nip19.decode(nsec), hex);
  });
}
