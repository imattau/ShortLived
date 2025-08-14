import 'package:bech32/bech32.dart' as b32;
import 'hex.dart';

class Nip19 {
  static String encodeNpub(String pubkeyHex) {
    final words = b32.convertBits(fromHex(pubkeyHex), 8, 5, true);
    return b32.bech32('npub', words).toString();
  }

  static String encodeNsec(String privHex) {
    final words = b32.convertBits(fromHex(privHex), 8, 5, true);
    return b32.bech32('nsec', words).toString();
  }

  static String decode(String bech) {
    final dec = b32.Bech32Decoder().convert(bech);
    final data = b32.convertBits(dec.data, 5, 8, false);
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
