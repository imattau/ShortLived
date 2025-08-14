import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:elliptic/elliptic.dart' as ec;
import '../../crypto/nip19.dart';
import 'key_service.dart';

class KeyServiceSecure implements KeyService {
  static const _kPriv = 'nostr_priv_hex';
  static const _kPub  = 'nostr_pub_hex';
  final FlutterSecureStorage _store;
  KeyServiceSecure(this._store);

  @override
  Future<String?> getPubkey() => _store.read(key: _kPub);

  @override
  Future<String?> getPrivkey() => _store.read(key: _kPriv);

  @override
  Future<String> generate() async {
    final curve = ec.getSecp256k1();
    final priv = curve.generatePrivateKey();
    final privHex = priv.toHex();
    final pubHex = priv.publicKey.toCompressedHex().substring(2);
    await _store.write(key: _kPriv, value: privHex);
    await _store.write(key: _kPub, value: pubHex);
    return pubHex;
  }

  @override
  Future<String> importSecret(String nsecOrHex) async {
    final privHex = Nip19.maybeDecodeNsecToHex(nsecOrHex.trim());
    final curve = ec.getSecp256k1();
    final pk = ec.PrivateKey.fromHex(curve, privHex);
    final pubHex = pk.publicKey.toCompressedHex().substring(2);
    await _store.write(key: _kPriv, value: privHex);
    await _store.write(key: _kPub, value: pubHex);
    return pubHex;
  }

  @override
  Future<String?> exportNsec() async {
    final hex = await getPrivkey();
    if (hex == null) return null;
    return Nip19.encodeNsec(hex);
  }
}
