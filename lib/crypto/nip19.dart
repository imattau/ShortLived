import 'package:bech32/bech32.dart' as b32;

import 'hex.dart';

class Nip19 {
  static String encodeNpub(String pubkeyHex) {
    final words = _convertBits(fromHex(pubkeyHex), 8, 5, pad: true);
    return b32.Bech32Codec().encode(b32.Bech32('npub', words));
  }

  static String encodeNsec(String privHex) {
    final words = _convertBits(fromHex(privHex), 8, 5, pad: true);
    return b32.Bech32Codec().encode(b32.Bech32('nsec', words));
  }

  static String decode(String bech) {
    final dec = b32.Bech32Codec().decode(bech);
    final data = _convertBits(dec.data, 5, 8, pad: false);
    return toHex(data);
  }

  static String maybeDecodeNsecToHex(String input) {
    if (input.startsWith('nsec1')) {
      return decode(input);
    }
    // assume hex
    return input;
  }

  // Borrowed from bech32's Segwit implementation.
  static List<int> _convertBits(List<int> data, int from, int to,
      {required bool pad}) {
    var acc = 0;
    var bits = 0;
    final result = <int>[];
    final maxv = (1 << to) - 1;
    for (final v in data) {
      if (v < 0 || (v >> from) != 0) {
        throw Exception('Invalid value $v');
      }
      acc = (acc << from) | v;
      bits += from;
      while (bits >= to) {
        bits -= to;
        result.add((acc >> bits) & maxv);
      }
    }
    if (pad) {
      if (bits > 0) {
        result.add((acc << (to - bits)) & maxv);
      }
    } else if (bits >= from || ((acc << (to - bits)) & maxv) != 0) {
      throw Exception('Invalid padding');
    }
    return result;
  }
}
