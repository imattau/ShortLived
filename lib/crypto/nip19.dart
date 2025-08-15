import 'package:bech32/bech32.dart' as b32;

import 'hex.dart';

class _Tlv {
  final int t;
  final List<int> v;
  _Tlv(this.t, this.v);
  List<int> bytes() => [t, v.length, ...v];
}

List<int> _hexToBytes(String hex) => fromHex(hex);
// ignore: unused_element
String _bytesToHex(List<int> b) => toHex(b);

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

  static String encodeNote(String eventIdHex) {
    final words = _convertBits(fromHex(eventIdHex), 8, 5, pad: true);
    return b32.Bech32Codec().encode(b32.Bech32('note', words));
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

String npubEncode(String pubkeyHex) => Nip19.encodeNpub(pubkeyHex);
String nsecEncode(String privHex) => Nip19.encodeNsec(privHex);
String? nip19Decode(String bech) {
  try {
    return Nip19.decode(bech);
  } catch (_) {
    return null;
  }
}
bool isNpub(String s) => s.toLowerCase().startsWith('npub1');
bool isNsec(String s) => s.toLowerCase().startsWith('nsec1');

String neventEncode({
  required String eventIdHex,
  String? authorPubkeyHex,
  List<String> relays = const [],
}) {
  final items = <_Tlv>[
    _Tlv(0x00, _hexToBytes(eventIdHex)),
    if (authorPubkeyHex != null && authorPubkeyHex.isNotEmpty)
      _Tlv(0x02, _hexToBytes(authorPubkeyHex)),
    for (final r in relays) _Tlv(0x01, r.codeUnits),
  ];
  final body = items.expand((e) => e.bytes()).toList();
  final words = Nip19._convertBits(body, 8, 5, pad: true);
  return b32.Bech32Codec().encode(b32.Bech32('nevent', words));
}

String nprofileEncode({
  required String pubkeyHex,
  List<String> relays = const [],
}) {
  final items = <_Tlv>[
    _Tlv(0x00, _hexToBytes(pubkeyHex)),
    for (final r in relays) _Tlv(0x01, r.codeUnits),
  ];
  final body = items.expand((e) => e.bytes()).toList();
  final words = Nip19._convertBits(body, 8, 5, pad: true);
  return b32.Bech32Codec().encode(b32.Bech32('nprofile', words));
}
