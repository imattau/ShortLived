import 'dart:convert';
import 'package:crypto/crypto.dart' as c;
import 'package:elliptic/elliptic.dart' as ec;
import 'package:ecdsa/ecdsa.dart' as ecdsa;
import 'hex.dart';

class NostrEvent {
  final int kind;
  final int createdAt; // seconds
  final String content;
  final List<List<String>> tags;

  NostrEvent({required this.kind, required this.createdAt, required this.content, required this.tags});

  /// Canonical serialised array per NIP-01: [0, pubkey, created_at, kind, tags, content]
  static List canonicalPayload(String pubkeyHex, NostrEvent e) =>
    [0, pubkeyHex, e.createdAt, e.kind, e.tags, e.content];

  static String idFor(String pubkeyHex, NostrEvent e) {
    final json = jsonEncode(canonicalPayload(pubkeyHex, e));
    return c.sha256.convert(utf8.encode(json)).toString();
  }

  static Map<String, dynamic> sign(String privHex, String pubHex, NostrEvent e) {
    final curve = ec.getSecp256k1();
    final priv = ec.PrivateKey.fromHex(curve, privHex);
    final id = idFor(pubHex, e);
    final sig = ecdsa.signature(priv, fromHex(id)).toCompactHex();
    return {
      'id': id,
      'pubkey': pubHex,
      'created_at': e.createdAt,
      'kind': e.kind,
      'tags': e.tags,
      'content': e.content,
      'sig': sig,
    };
  }
}
