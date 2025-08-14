import 'package:bech32/bech32.dart' as b32;
import 'hex.dart';

class Nip19 {
  static String encodeNpub(String pubkeyHex) {
    final words = b32.toWords(fromHex(pubkeyHex));
    return b32.encode(b32.Bech32('npub', words));
  }

  static String encodeNsec(String privHex) {
    final words = b32.toWords(fromHex(privHex));
    return b32.encode(b32.Bech32('nsec', words));
  }

  static String decode(String bech) {
    final dec = b32.decode(bech);
    final data = b32.fromWords(dec.data);
    return toHex(data);
  }

  static String maybeDecodeNsecToHex(String input) {
    if (input.startsWith('nsec1')) {
      return decode(input);
    }
    // assume hex
    return input;
  }
}
